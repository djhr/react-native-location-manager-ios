#import "RCTLocationManagerIOS.h"

#import <CoreLocation/CLError.h>
#import <CoreLocation/CLHeading.h>
#import <CoreLocation/CLVisit.h>
#import <CoreLocation/CLRegion.h>
#import <CoreLocation/CLBeaconRegion.h>
#import <CoreLocation/CLCircularRegion.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLLocationManager+CLVisitExtensions.h>

#import <React/RCTLog.h>
#import <React/RCTConvert.h>


static NSString *const StorageDirectory = @"RNLocationManager";
static NSString *const RegionsFileName = @"regions.json";
static NSString *const StateFileName = @"state.json";


@implementation RCTConvert (RCTLocationManagerIOS)

+ (CLLocationDistance)CLLocationDistance:(id)json
{
  return [RCTConvert double:json];
}

+ (CLLocationAccuracy)CLLocationAccuracy:(id)json
{
  return [RCTConvert double:json];
}

+ (CLActivityType)CLActivityType:(id)json
{
  return (CLActivityType)[RCTConvert int:json];
}

+ (CLLocationDegrees)CLLocationDegrees:(id)json
{
  return [RCTConvert double:json];
}

+ (CLDeviceOrientation)CLDeviceOrientation:(id)json
{
  return (CLDeviceOrientation)[RCTConvert int:json];
}

+ (CLLocationCoordinate2D)CLLocationCoordinate2D:(id)json
{
  NSDictionary<NSString *, id> *coordinate = [RCTConvert NSDictionary:json];

  return CLLocationCoordinate2DMake([RCTConvert double:coordinate[@"latitude"]], [RCTConvert double:coordinate[@"longitude"]]);
}

+ (CLRegion *)CLRegion:(id)json
{
  return [RCTConvert CLCircularRegion:json];
}

+ (CLCircularRegion *)CLCircularRegion:(id)json
{
  NSDictionary<NSString *, id> *options = [RCTConvert NSDictionary:json];

  CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter: [RCTConvert CLLocationCoordinate2D:options[@"center"]]
                                                               radius: [RCTConvert double:options[@"radius"]]
                                                           identifier: options[@"identifier"]];

  if (options[@"notifyOnEntry"] != NULL) {
    region.notifyOnEntry = [RCTConvert BOOL:options[@"notifyOnEntry"]];
  }

  if (options[@"notifyOnExit"] != NULL) {
    region.notifyOnExit = [RCTConvert BOOL:options[@"notifyOnExit"]];
  }

  return region;
}

+ (CLBeaconRegion *)CLBeaconRegion:(id)json
{
  NSDictionary<NSString *, id> *options = [RCTConvert NSDictionary:json];
  CLBeaconRegion *region;


  if (options[@"major"] == NULL && options[@"minor"] == NULL) {
    region = [[CLBeaconRegion alloc] initWithProximityUUID: options[@"proximityUUID"]
                                                identifier: options[@"identifier"]];
  } else if (options[@"major"] != NULL && options[@"minor"] == NULL) {
    region = [[CLBeaconRegion alloc] initWithProximityUUID: options[@"proximityUUID"]
                                                     major: [RCTConvert uint64_t:options[@"major"]]
                                                identifier: options[@"identifier"]];
  } else {
    region = [[CLBeaconRegion alloc] initWithProximityUUID: options[@"proximityUUID"]
                                                     major: [RCTConvert uint64_t:options[@"major"]]
                                                     minor: [RCTConvert uint64_t:options[@"minor"]]
                                                identifier: options[@"identifier"]];
  }

  if (options[@"notifyOnEntry"] != NULL) {
    region.notifyOnEntry = [RCTConvert BOOL:options[@"notifyOnEntry"]];
  }

  if (options[@"notifyOnExit"] != NULL) {
    region.notifyOnExit = [RCTConvert BOOL:options[@"notifyOnExit"]];
  }

  return region;
}

@end


@interface RCTLocationManagerIOS () <CLLocationManagerDelegate>

@end


@implementation RCTLocationManagerIOS

CLLocationManager *locationManager;
NSMutableDictionary<NSString*, CLCircularRegion*> *gpsMonitoredRegions;
NSMutableDictionary<NSString*, NSNumber*> *gpsMonitoredRegionsState;
bool isUpdatingLocation;
bool hasListeners;


#pragma mark Lifecycle

- (id)init
{
  self = [super init];
  if (self != nil) {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    isUpdatingLocation = NO;
    hasListeners = NO;
    [self resume];
  }

  return self;
}

- (void)startObserving
{
  hasListeners = YES;
}

- (void)stopObserving
{
  hasListeners = NO;
}

- (void)dealloc
{
  locationManager.delegate = nil;
}


#pragma mark Private methods

-(void)resume
{
  gpsMonitoredRegions = [NSMutableDictionary new];
  NSArray *items = JSONParseFile(RegionsFileName, NSArray.class);

  for (id item in items) {
    CLCircularRegion *region = [RCTConvert CLCircularRegion:item];
    [gpsMonitoredRegions setObject:region forKey:region.identifier];
  }

  NSDictionary *state = JSONParseFile(StateFileName, NSDictionary.class);
  gpsMonitoredRegionsState = [state mutableCopy];
}

-(void)snapshot
{
  JSONWriteFile(RegionsFileName, JSONRegionArray([gpsMonitoredRegions allValues]));
  JSONWriteFile(StateFileName, gpsMonitoredRegionsState);
}

- (void)startGPSMonitoringForRegion:(CLCircularRegion *)region
{
  CLLocationCoordinate2D coords = locationManager.location != nil
    ? locationManager.location.coordinate
    : kCLLocationCoordinate2DInvalid;

  CLRegionState state = CLLocationCoordinate2DIsValid(coords)
    ? [region containsCoordinate:coords] ? CLRegionStateInside : CLRegionStateOutside
    : CLRegionStateUnknown;

  [gpsMonitoredRegions setObject:region
                          forKey:region.identifier];

  [gpsMonitoredRegionsState setObject:[NSNumber numberWithInt:state]
                               forKey:region.identifier];

  [self snapshot];
}

- (void)stopGPSMonitoringForRegion:(CLCircularRegion *)region
{
  [gpsMonitoredRegions removeObjectForKey:region.identifier];
  [gpsMonitoredRegionsState removeObjectForKey:region.identifier];

  [self snapshot];
}

- (void)requestStateForGPSRegion:(CLCircularRegion *)region
{
  [self locationManager:locationManager
      didDetermineState:[self stateForGPSRegion:region]
              forRegion:region];
}

- (CLRegionState) stateForGPSRegion:(CLCircularRegion *)region
{
  NSNumber* state = [gpsMonitoredRegionsState objectForKey:region.identifier];
  return state ? [state intValue] : CLRegionStateUnknown;
}

- (void) setState:(CLRegionState)state forGPSRegion:(CLCircularRegion *)region
{
  [gpsMonitoredRegionsState setObject:[NSNumber numberWithInt:state]
                               forKey:region.identifier];
}

- (BOOL)shouldUseGPSMonitoringForRegion:(CLRegion *)region
{
  return isUpdatingLocation
  && [region isKindOfClass:[CLCircularRegion class]]
  && ((CLCircularRegion *) region).radius < 100;
}

- (void) updateGPSRegionsState:(CLLocation *)location
{
  CLLocationCoordinate2D coords = location.coordinate;

  for (NSString *identifier in gpsMonitoredRegions) {
    CLCircularRegion *region = [gpsMonitoredRegions objectForKey:identifier];
    CLRegionState state = [self stateForGPSRegion:region];
    CLCircularRegion *oRegion = [[CLCircularRegion alloc] initWithCenter:region.center
                                                                  radius:region.radius * 1.25
                                                              identifier:region.identifier];

    if (state == CLRegionStateUnknown) {
      CLRegionState newState = [region containsCoordinate:coords] ? CLRegionStateInside : CLRegionStateOutside;
      [self setState:newState forGPSRegion:region];

    } else if (state == CLRegionStateOutside && [region containsCoordinate:coords]) {
      [self setState:CLRegionStateInside forGPSRegion:region];
      if (region.notifyOnEntry) [self locationManager:locationManager didEnterRegion:region];

    } else if (state == CLRegionStateInside && ![oRegion containsCoordinate:coords]) {
      [self setState:CLRegionStateOutside forGPSRegion:region];
      if (region.notifyOnExit) [self locationManager:locationManager didExitRegion:region];
    }
  }

  [self snapshot];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
  if (hasListeners) [self sendEventWithName:@"didUpdateLocations" body:JSONLocationArray(locations)];
  [self updateGPSRegionsState:locations.lastObject];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didFailWithError" body:JSONError(error)];
}

- (void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(NSError *)error
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didFinishDeferredUpdatesWithError" body:JSONError(error)];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didPauseLocationUpdates" body:nil];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didResumeLocationUpdates" body:nil];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didUpdateHeading" body: JSONHeading(newHeading)];
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didEnterRegion" body:JSONRegion(region)];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didExitRegion" body:JSONRegion(region)];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didDetermineStateForRegion" body:@{@"state": @(state), @"region": JSONRegion(region)}];
}

- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error
{
  if (!hasListeners) return;
  [self sendEventWithName:@"monitoringDidFailForRegion" body:@{@"region": JSONRegion(region), @"error": JSONError(error)}];
}

- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didStartMonitoringForRegion" body:JSONRegion(region)];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons
               inRegion:(CLBeaconRegion *)region
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didRangeBeaconsInRegion" body:@{@"beacons": JSONBeaconArray(beacons), @"region": JSONRegion(region)}];
}

- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error
{
  if (!hasListeners) return;
  [self sendEventWithName:@"rangingBeaconsDidFailForRegion" body:@{@"region": JSONRegion(region), @"error": JSONError(error)}];
}

- (void)locationManager:(CLLocationManager *)manager
               didVisit:(CLVisit *)visit
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didVisit" body:JSONVisit(visit)];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didChangeAuthorizationStatus" body:@(status)];
}


#pragma mark API

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"didUpdateLocations",
           @"didFailWithError",
           @"didFinishDeferredUpdatesWithError",
           @"didPauseLocationUpdates",
           @"didResumeLocationUpdates",
           @"didUpdateHeading",
           @"didEnterRegion",
           @"didExitRegion",
           @"didDetermineStateForRegion",
           @"monitoringDidFailForRegion",
           @"didStartMonitoringForRegion",
           @"didRangeBeaconsInRegion",
           @"rangingBeaconsDidFailForRegion",
           @"didVisit",
           @"didChangeAuthorizationStatus"];
}

- (NSDictionary *)constantsToExport
{
  return @{
           @"AuthorizationStatusNotDetermined": @(kCLAuthorizationStatusNotDetermined),
           @"AuthorizationStatusRestricted": @(kCLAuthorizationStatusRestricted),
           @"AuthorizationStatusDenied": @(kCLAuthorizationStatusDenied),
           @"AuthorizationStatusAuthorizedAlways": @(kCLAuthorizationStatusAuthorizedAlways),
           @"AuthorizationStatusAuthorizedWhenInUse": @(kCLAuthorizationStatusAuthorizedWhenInUse),
           @"DistanceFilterNone": @(kCLDistanceFilterNone),
           @"LocationAccuracyBestForNavigation": @(kCLLocationAccuracyBestForNavigation),
           @"LocationAccuracyBest": @(kCLLocationAccuracyBest),
           @"LocationAccuracyNearestTenMeters": @(kCLLocationAccuracyNearestTenMeters),
           @"LocationAccuracyHundredMeters": @(kCLLocationAccuracyHundredMeters),
           @"LocationAccuracyKilometer": @(kCLLocationAccuracyKilometer),
           @"LocationAccuracyThreeKilometers": @(kCLLocationAccuracyThreeKilometers),
           @"ActivityTypeOther": @(CLActivityTypeOther),
           @"ActivityTypeAutomotiveNavigation": @(CLActivityTypeAutomotiveNavigation),
           @"ActivityTypeFitness": @(CLActivityTypeFitness),
           @"ActivityTypeOtherNavigation": @(CLActivityTypeOtherNavigation),
           @"DeviceOrientationUnknown": @(CLDeviceOrientationUnknown),
           @"DeviceOrientationPortrait": @(CLDeviceOrientationPortrait),
           @"DeviceOrientationPortraitUpsideDown": @(CLDeviceOrientationPortraitUpsideDown),
           @"DeviceOrientationLandscapeLeft": @(CLDeviceOrientationLandscapeLeft),
           @"DeviceOrientationLandscapeRight": @(CLDeviceOrientationLandscapeRight),
           @"DeviceOrientationFaceUp": @(CLDeviceOrientationFaceUp),
           @"DeviceOrientationFaceDown": @(CLDeviceOrientationFaceDown),
           @"RegionStateUnknown": @(CLRegionStateUnknown),
           @"RegionStateInside": @(CLRegionStateInside),
           @"RegionStateOutside": @(CLRegionStateOutside),
           @"ProximityUnknown": @(CLProximityUnknown),
           @"ProximityImmediate": @(CLProximityImmediate),
           @"ProximityNear": @(CLProximityNear),
           @"ProximityFar": @(CLProximityFar),
           @"ErrorLocationUnknown": @(kCLErrorLocationUnknown),
           @"ErrorDenied": @(kCLErrorDenied),
           @"ErrorNetwork": @(kCLErrorNetwork),
           @"ErrorHeadingFailure": @(kCLErrorHeadingFailure),
           @"ErrorRegionMonitoringDenied": @(kCLErrorRegionMonitoringDenied),
           @"ErrorRegionMonitoringFailure": @(kCLErrorRegionMonitoringFailure),
           @"ErrorRegionMonitoringSetupDelayed": @(kCLErrorRegionMonitoringSetupDelayed),
           @"ErrorRegionMonitoringResponseDelayed": @(kCLErrorRegionMonitoringResponseDelayed),
           @"ErrorGeocodeFoundNoResult": @(kCLErrorGeocodeFoundNoResult),
           @"ErrorGeocodeFoundPartialResult": @(kCLErrorGeocodeFoundPartialResult),
           @"ErrorGeocodeCanceled": @(kCLErrorGeocodeCanceled),
           @"ErrorDeferredFailed": @(kCLErrorDeferredFailed),
           @"ErrorDeferredNotUpdatingLocation": @(kCLErrorDeferredNotUpdatingLocation),
           @"ErrorDeferredAccuracyTooLow": @(kCLErrorDeferredAccuracyTooLow),
           @"ErrorDeferredDistanceFiltered": @(kCLErrorDeferredDistanceFiltered),
           @"ErrorDeferredCanceled": @(kCLErrorDeferredCanceled),
           @"ErrorRangingUnavailable": @(kCLErrorRangingUnavailable),
           @"ErrorRangingFailure": @(kCLErrorRangingFailure)
           };
}


#pragma mark Class Methods

RCT_EXPORT_METHOD(authorizationStatus:(RCTPromiseResolveBlock)resolve
                         withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager authorizationStatus]));
}

RCT_EXPORT_METHOD(locationServicesEnabled:(RCTPromiseResolveBlock)resolve
                             withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager locationServicesEnabled]));
}

RCT_EXPORT_METHOD(deferredLocationUpdatesAvailable:(RCTPromiseResolveBlock)resolve
                                      withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager deferredLocationUpdatesAvailable]));
}

RCT_EXPORT_METHOD(significantLocationChangeMonitoringAvailable:(RCTPromiseResolveBlock)resolve
                                                  withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager significantLocationChangeMonitoringAvailable]));
}

RCT_EXPORT_METHOD(headingAvailable:(RCTPromiseResolveBlock)resolve
                      withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager headingAvailable]));
}

RCT_EXPORT_METHOD(isRangingAvailable:(RCTPromiseResolveBlock)resolve
                        withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager isRangingAvailable]));
}


#pragma mark Instance Methods

RCT_EXPORT_METHOD(requestWhenInUseAuthorization)
{
  [locationManager requestWhenInUseAuthorization];
}

RCT_EXPORT_METHOD(requestAlwaysAuthorization)
{
  [locationManager requestAlwaysAuthorization];
}

RCT_EXPORT_METHOD(startUpdatingLocation)
{
  [locationManager startUpdatingLocation];
  isUpdatingLocation = YES;
}

RCT_EXPORT_METHOD(stopUpdatingLocation)
{
  [locationManager stopUpdatingLocation];
  isUpdatingLocation = NO;
}

RCT_EXPORT_METHOD(requestLocation)
{
  [locationManager requestLocation];
}

RCT_EXPORT_METHOD(startMonitoringSignificantLocationChanges)
{
  [locationManager startMonitoringSignificantLocationChanges];
}

RCT_EXPORT_METHOD(stopMonitoringSignificantLocationChanges)
{
  [locationManager stopMonitoringSignificantLocationChanges];
}

RCT_EXPORT_METHOD(startUpdatingHeading)
{
  [locationManager startUpdatingHeading];
}

RCT_EXPORT_METHOD(stopUpdatingHeading)
{
  [locationManager stopUpdatingHeading];
}

RCT_EXPORT_METHOD(dismissHeadingCalibrationDisplay)
{
  [locationManager dismissHeadingCalibrationDisplay];
}

RCT_EXPORT_METHOD(startMonitoringForRegion:(CLRegion *) region)
{
  if ([self shouldUseGPSMonitoringForRegion:region]) {
    [self startGPSMonitoringForRegion:(CLCircularRegion *)region];
  } else {
    [locationManager startMonitoringForRegion: region];
  }
}

RCT_EXPORT_METHOD(stopMonitoringForRegion:(NSString *) identifier)
{
  for (CLRegion *region in [locationManager monitoredRegions]) {
    if ([region.identifier isEqualToString:identifier]) {
      [locationManager stopMonitoringForRegion: region];
      break;
    }
  }

  CLCircularRegion *region = [gpsMonitoredRegions objectForKey:identifier];
  if (region != nil) [self stopGPSMonitoringForRegion: region];
}

RCT_EXPORT_METHOD(stopMonitoringForAllRegions)
{
  for (CLRegion *region in [locationManager monitoredRegions]) {
    [locationManager stopMonitoringForRegion: region];
  }

  [gpsMonitoredRegions removeAllObjects];
  [gpsMonitoredRegionsState removeAllObjects];
  [self snapshot];
}

RCT_EXPORT_METHOD(startRangingBeaconsInRegion:(CLBeaconRegion *) region)
{
  [locationManager startRangingBeaconsInRegion: region];
}

RCT_EXPORT_METHOD(stopRangingBeaconsInRegion:(NSString *) identifier)
{
  for (CLBeaconRegion *region in [locationManager rangedRegions]) {
    if ([region.identifier isEqualToString:identifier]) {
      [locationManager stopRangingBeaconsInRegion: region];
      return;
    }
  }

  RCTLogWarn(@"Couldn't find region '%@' in rangedRegions", identifier);
}

RCT_EXPORT_METHOD(stopRangingBeaconsInAllRegions)
{
  for (CLBeaconRegion *region in [locationManager rangedRegions]) {
    [locationManager stopRangingBeaconsInRegion: region];
  }
}

RCT_EXPORT_METHOD(requestStateForRegion:(NSString *) identifier)
{
  for (CLRegion *region in [locationManager monitoredRegions]) {
    if ([region.identifier isEqualToString:identifier]) {
      [locationManager requestStateForRegion: region];
      break;
    }
  }

  CLCircularRegion *region = [gpsMonitoredRegions objectForKey:identifier];
  if (region != nil) [self requestStateForGPSRegion: region];
}

RCT_EXPORT_METHOD(startMonitoringVisits)
{
  [locationManager startMonitoringVisits];
}

RCT_EXPORT_METHOD(stopMonitoringVisits)
{
  [locationManager stopMonitoringVisits];
}

RCT_EXPORT_METHOD(allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)distance
                                                    timeout:(NSTimeInterval) timeout)
{
  [locationManager allowDeferredLocationUpdatesUntilTraveled: distance
                                                     timeout: timeout];
}

RCT_EXPORT_METHOD(disallowDeferredLocationUpdates)
{
  [locationManager disallowDeferredLocationUpdates];
}


#pragma mark Getters/Setters

RCT_EXPORT_METHOD(getPausesLocationUpdatesAutomatically:(RCTPromiseResolveBlock) resolve
                                           withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.pausesLocationUpdatesAutomatically));
}

RCT_EXPORT_METHOD(setPausesLocationUpdatesAutomatically:(BOOL) value)
{
  locationManager.pausesLocationUpdatesAutomatically = value;
}

RCT_EXPORT_METHOD(getAllowsBackgroundLocationUpdates:(RCTPromiseResolveBlock) resolve
                                        withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.allowsBackgroundLocationUpdates));
}

RCT_EXPORT_METHOD(setAllowsBackgroundLocationUpdates:(BOOL) value)
{
  locationManager.allowsBackgroundLocationUpdates = value;
}

RCT_EXPORT_METHOD(getShowsBackgroundLocationIndicator:(RCTPromiseResolveBlock) resolve
                                         withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.showsBackgroundLocationIndicator));
}

RCT_EXPORT_METHOD(setShowsBackgroundLocationIndicator:(BOOL) value)
{
  locationManager.showsBackgroundLocationIndicator = value;
}

RCT_EXPORT_METHOD(getDistanceFilter:(RCTPromiseResolveBlock) resolve
                       withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.distanceFilter));
}

RCT_EXPORT_METHOD(setDistanceFilter:(CLLocationDistance) distance)
{
  locationManager.distanceFilter = distance;
}

RCT_EXPORT_METHOD(getDesiredAccuracy:(RCTPromiseResolveBlock) resolve
                        withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.desiredAccuracy));
}

RCT_EXPORT_METHOD(setDesiredAccuracy:(CLLocationAccuracy) accuracy)
{
  locationManager.desiredAccuracy = accuracy;
}

RCT_EXPORT_METHOD(getActivityType:(RCTPromiseResolveBlock) resolve
                     withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.activityType));
}

RCT_EXPORT_METHOD(setActivityType:(CLActivityType) activityType)
{
  locationManager.activityType = activityType;
}

RCT_EXPORT_METHOD(getHeadingFilter:(RCTPromiseResolveBlock) resolve
                      withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.headingFilter));
}

RCT_EXPORT_METHOD(setHeadingFilter:(CLLocationDegrees) headingFilter)
{
  locationManager.headingFilter = headingFilter;
}

RCT_EXPORT_METHOD(getHeadingOrientation:(RCTPromiseResolveBlock) resolve
                           withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.headingOrientation));
}

RCT_EXPORT_METHOD(setHeadingOrientation:(CLDeviceOrientation) headingOrientation)
{
  locationManager.headingOrientation = headingOrientation;
}

RCT_EXPORT_METHOD(getMaximumRegionMonitoringDistance:(RCTPromiseResolveBlock)resolve
                                        withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.maximumRegionMonitoringDistance));
}

RCT_EXPORT_METHOD(getMonitoredRegions:(RCTPromiseResolveBlock)resolve
                         withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONRegionArray([locationManager.monitoredRegions allObjects]));
}

RCT_EXPORT_METHOD(getGPSMonitoredRegions:(RCTPromiseResolveBlock)resolve
                            withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONRegionArray([gpsMonitoredRegions allValues]));
}

RCT_EXPORT_METHOD(getRangedRegions:(RCTPromiseResolveBlock)resolve
                      withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONRegionArray([locationManager.rangedRegions allObjects]));
}

RCT_EXPORT_METHOD(getLocation:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONLocation(locationManager.location));
}

RCT_EXPORT_METHOD(getHeading:(RCTPromiseResolveBlock)resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONHeading(locationManager.heading));
}


#pragma mark - IO

static NSString *GetPathForFile(NSString *filename)
{
  NSString *base = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
  NSString *dir = [base stringByAppendingPathComponent:StorageDirectory];

  return filename ? [dir stringByAppendingPathComponent:filename] : dir;
}

static BOOL MKDIR(NSString *path)
{
  return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:nil];
}

static id JSONParseFile(NSString *filename, Class class)
{
  NSString *path = GetPathForFile(filename);
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return [[class alloc] init];

  NSError *error;
  NSData *data = [NSData dataWithContentsOfFile:path];

  id object = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];

  if (error) RCTLogWarn(@"Error parsing JSON: %@", error);

  return error || !object ? [[class alloc] init] : object;
}

static BOOL JSONWriteFile(NSString *filename, id obj)
{
  NSString *home = GetPathForFile(nil);
  if (![[NSFileManager defaultManager] fileExistsAtPath:home]) MKDIR(home);

  NSString *path = GetPathForFile(filename);
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) MKDIR(GetPathForFile(nil));

  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:obj
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:&error];

  if (error) RCTLogWarn(@"Error serializing JSON: %@", error);

  return error ? NO : [data writeToFile:path atomically:YES];
}


#pragma mark - Converters

static NSArray<NSDictionary<NSString*, id>*> *JSONLocationArray(NSArray<CLLocation*> *locations)
{
  NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:locations.count];
  for (CLLocation *location in locations) {
    [arr addObject:JSONLocation(location)];
  }

  return [arr copy];
}

static NSDictionary<NSString*, id> *JSONLocation(CLLocation *location)
{
  return @{
           @"altitude": @(location.altitude),
           @"horizontalAccuracy": @(location.horizontalAccuracy),
           @"verticalAccuracy": @(location.verticalAccuracy),
           @"speed": @(location.speed),
           @"course": @(location.course),
           @"timestamp": @(JSONTimestamp(location.timestamp)),
           @"coordinate": JSONCoordinate(location.coordinate)
           };
}

static NSArray<NSDictionary<NSString*, id>*> *JSONRegionArray(NSArray<__kindof CLRegion *> *regions)
{
  NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:regions.count];
  for (CLRegion *region in regions) {
    [arr addObject:JSONRegion(region)];
  }

  return [arr copy];
}

static NSDictionary<NSString*, id> *JSONRegion(CLRegion *region)
{
  if ([region isKindOfClass:[CLCircularRegion class]]) {
    return JSONCircularRegion((CLCircularRegion *) region);
  } else if ([region isKindOfClass:[CLBeaconRegion class]]) {
    return JSONBeaconRegion((CLBeaconRegion *) region);
  }

  return @{
           @"identifier": region.identifier,
           @"notifyOnEntry": @(region.notifyOnEntry),
           @"notifyOnExit": @(region.notifyOnExit)
           };
}

static NSDictionary<NSString*, id> *JSONCircularRegion(CLCircularRegion *region)
{
  return @{
           @"identifier": region.identifier,
           @"radius": @(region.radius),
           @"center": JSONCoordinate(region.center),
           @"notifyOnEntry": @(region.notifyOnEntry),
           @"notifyOnExit": @(region.notifyOnExit)
           };
}

static NSDictionary<NSString*, id> *JSONBeaconRegion(CLBeaconRegion *region)
{
  return @{
           @"identifier": region.identifier,
           @"proximityUUID": region.proximityUUID,
           @"major": region.major,
           @"minor": region.minor,
           @"notifyOnEntry": @(region.notifyOnEntry),
           @"notifyOnExit": @(region.notifyOnExit)
           };
}

static NSArray<NSDictionary<NSString*, id>*> *JSONBeaconArray(NSArray<CLBeacon *> *beacons)
{
  NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:beacons.count];
  for (CLBeacon *beacon in beacons) {
    [arr addObject:JSONBeacon(beacon)];
  }

  return [arr copy];
}

static NSDictionary<NSString*, id> *JSONBeacon(CLBeacon *beacon)
{
  return @{
           @"proximityUUID": beacon.proximityUUID,
           @"major": beacon.major,
           @"minor": beacon.minor,
           @"proximity": @(beacon.proximity),
           @"accuracy": @(beacon.accuracy),
           @"rssi": @(beacon.rssi)
           };
}

static NSDictionary<NSString*, id> *JSONVisit(CLVisit *visit)
{
  return @{
           @"horizontalAccuracy": @(visit.horizontalAccuracy),
           @"arrivalDate": @(JSONTimestamp(visit.arrivalDate)),
           @"departureDate": @(JSONTimestamp(visit.departureDate)),
           @"coordinate": JSONCoordinate(visit.coordinate)
           };
}

static NSDictionary<NSString*, id> *JSONHeading(CLHeading *heading)
{
  return @{
           @"magneticHeading": @(heading.magneticHeading),
           @"trueHeading": @(heading.trueHeading),
           @"headingAccuracy": @(heading.headingAccuracy),
           @"timestamp": @(JSONTimestamp(heading.timestamp)),
           @"x": @(heading.x),
           @"y": @(heading.y),
           @"z": @(heading.z)
           };
}

static NSDictionary<NSString*, id> *JSONError(NSError *error)
{
  return @{
           @"code": @(error.code),
           @"domain": error.domain
           };
}

static NSDictionary<NSString*, id> *JSONCoordinate(CLLocationCoordinate2D coordinate)
{
  return @{
           @"latitude": @(coordinate.latitude),
           @"longitude": @(coordinate.longitude)
           };
}

static double JSONTimestamp(NSDate *date)
{
  return [date timeIntervalSince1970] * 1000; // ms
}

@end
