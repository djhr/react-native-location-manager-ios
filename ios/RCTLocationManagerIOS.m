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

#import <React/RCTConvert.h>


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
  NSDictionary<NSString *, id> *region = [RCTConvert NSDictionary:json];

  return [[CLCircularRegion alloc] initWithCenter: [RCTConvert CLLocationCoordinate2D:region[@"center"]]
                                           radius: [RCTConvert double:region[@"radius"]]
                                       identifier: region[@"identifier"]];
}

+ (CLBeaconRegion *)CLBeaconRegion:(id)json
{
  NSDictionary<NSString *, id> *beacon = [RCTConvert NSDictionary:json];

  return [[CLBeaconRegion alloc] initWithProximityUUID: beacon[@"proximityUUID"]
                                                 major: [RCTConvert uint64_t:beacon[@"major"]]
                                                 minor: [RCTConvert uint64_t:beacon[@"minor"]]
                                            identifier: beacon[@"identifier"]];
}

@end


@interface RCTLocationManagerIOS () <CLLocationManagerDelegate>

@end


@implementation RCTLocationManagerIOS

CLLocationManager *locationManager;
bool hasListeners;


#pragma mark Lifecycle

- (id)init
{
  self = [super init];
  if (self != nil) {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
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


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didUpdateLocations" body:JSONLocationArray(locations)];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didFailWithError" body:JSONError(error)];
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
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error
{
  if (!hasListeners) return;
  [self sendEventWithName:@"monitoringDidFailForRegion" body:@{@"region": JSONRegion(region), @"error": JSONError(error)}];
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
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didDetermineStateForRegion" body:@{@"state": @(state), @"region": JSONRegion(region)}];
}

- (void)locationManager:(CLLocationManager *)manager
               didVisit:(CLVisit *)visit
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didVisit" body:JSONVisit(visit)];
}

- (void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(NSError *)error
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didFinishDeferredUpdatesWithError" body:JSONError(error)];
}


#pragma mark API

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"didUpdateLocations",
           @"didFailWithError",
           @"didUpdateHeading",
           @"didEnterRegion",
           @"didExitRegion",
           @"monitoringDidFailForRegion",
           @"didRangeBeaconsInRegion",
           @"rangingBeaconsDidFailForRegion",
           @"didDetermineStateForRegion",
           @"didVisit",
           @"didFinishDeferredUpdatesWithError"];
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
}

RCT_EXPORT_METHOD(stopUpdatingLocation)
{
  [locationManager stopUpdatingLocation];
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
  [locationManager startMonitoringForRegion: region];
}

RCT_EXPORT_METHOD(stopMonitoringForRegion:(CLRegion *) region)
{
  [locationManager stopMonitoringForRegion: region];
}

RCT_EXPORT_METHOD(startRangingBeaconsInRegion:(CLBeaconRegion *) region)
{
  [locationManager startRangingBeaconsInRegion: region];
}

RCT_EXPORT_METHOD(stopRangingBeaconsInRegion:(CLBeaconRegion *) region)
{
  [locationManager stopRangingBeaconsInRegion: region];
}

RCT_EXPORT_METHOD(requestStateForRegion:(CLRegion *) region)
{
  [locationManager requestStateForRegion: region];
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
  resolve(JSONRegionArray(locationManager.monitoredRegions));
}

RCT_EXPORT_METHOD(getRangedRegions:(RCTPromiseResolveBlock)resolve
                      withRejecter:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONRegionArray(locationManager.rangedRegions));
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

static NSArray<NSDictionary<NSString*, id>*> *JSONRegionArray(NSSet<__kindof CLRegion *> *regions)
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

  return @{@"identifier": region.identifier};
}

static NSDictionary<NSString*, id> *JSONCircularRegion(CLCircularRegion *region)
{
  return @{
           @"identifier": region.identifier,
           @"radius": @(region.radius),
           @"center": JSONCoordinate(region.center)
           };
}

static NSDictionary<NSString*, id> *JSONBeaconRegion(CLBeaconRegion *region)
{
  return @{
           @"identifier": region.identifier,
           @"proximityUUID": region.proximityUUID,
           @"major": region.major,
           @"minor": region.minor
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
           @"domain": error.domain,
           @"userInfo": error.userInfo
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
