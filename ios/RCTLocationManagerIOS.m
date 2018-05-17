#import "RCTLocationManagerIOS.h"

#import <CoreLocation/CLError.h>
#import <CoreLocation/CLHeading.h>
#import <CoreLocation/CLVisit.h>
#import <CoreLocation/CLRegion.h>
#import <CoreLocation/CLCircularRegion.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLLocationManager+CLVisitExtensions.h>

#import <React/RCTConvert.h>


@implementation RCTConvert (CLRegion)

+ (CLRegion *)CLRegion:(id)json
{
  NSDictionary<NSString *, id> *region = [RCTConvert NSDictionary:json];
  double radius = [RCTConvert double:region[@"radius"]];
  CLLocationDegrees latitude = [RCTConvert double:region[@"latitude"]];
  CLLocationDegrees longitude = [RCTConvert double:region[@"longitude"]];
  CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);

  return [[CLCircularRegion alloc] initWithCenter: center
                                           radius: radius
                                       identifier: region[@"identifier"]];
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
  [self sendEventWithName:@"didFailWithError" body:error];
}

- (void)locationManager:(CLLocationManager *)manager
               didVisit:(CLVisit *)visit
{
  if (!hasListeners) return;
  [self sendEventWithName:@"didVisit" body:visit];
}


#pragma mark API

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"didUpdateLocations", @"didFailWithError", @"didVisit"];
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
           };
}


#pragma mark Class Methods

RCT_EXPORT_METHOD(authorizationStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager authorizationStatus]));
}

RCT_EXPORT_METHOD(locationServicesEnabled:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager locationServicesEnabled]));
}

RCT_EXPORT_METHOD(deferredLocationUpdatesAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager deferredLocationUpdatesAvailable]));
}

RCT_EXPORT_METHOD(significantLocationChangeMonitoringAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager significantLocationChangeMonitoringAvailable]));
}

RCT_EXPORT_METHOD(headingAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(@([CLLocationManager headingAvailable]));
}

RCT_EXPORT_METHOD(isRangingAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
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

RCT_EXPORT_METHOD(allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)distance timeout:(NSTimeInterval) timeout)
{
  [locationManager allowDeferredLocationUpdatesUntilTraveled: distance
                                                     timeout: timeout];
}

RCT_EXPORT_METHOD(disallowDeferredLocationUpdates)
{
  [locationManager disallowDeferredLocationUpdates];
}


#pragma mark Getters

RCT_EXPORT_METHOD(maximumRegionMonitoringDistance:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(@(locationManager.maximumRegionMonitoringDistance));
}

RCT_EXPORT_METHOD(monitoredRegions:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  // TODO
  resolve(locationManager.monitoredRegions);
}

RCT_EXPORT_METHOD(rangedRegions:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  // TODO
  resolve(locationManager.rangedRegions);
}

RCT_EXPORT_METHOD(location:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONLocation(locationManager.location));
}

RCT_EXPORT_METHOD(heading:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject)
{
  resolve(JSONHeading(locationManager.heading));
}


#pragma mark Setters

RCT_EXPORT_METHOD(pausesLocationUpdatesAutomatically:(BOOL) value)
{
  locationManager.pausesLocationUpdatesAutomatically = value;
}

RCT_EXPORT_METHOD(allowsBackgroundLocationUpdates:(BOOL) value)
{
  locationManager.allowsBackgroundLocationUpdates = value;
}

RCT_EXPORT_METHOD(showsBackgroundLocationIndicator:(BOOL) value)
{
  locationManager.showsBackgroundLocationIndicator = value;
}

RCT_EXPORT_METHOD(distanceFilter:(CLLocationDistance) distance)
{
  locationManager.distanceFilter = distance;
}

RCT_EXPORT_METHOD(desiredAccuracy:(CLLocationAccuracy) accuracy)
{
  locationManager.desiredAccuracy = accuracy;
}

RCT_EXPORT_METHOD(activityType:(CLActivityType) activityType)
{
  locationManager.activityType = activityType;
}

RCT_EXPORT_METHOD(headingFilter:(CLLocationDegrees) headingFilter)
{
  locationManager.headingFilter = headingFilter;
}

RCT_EXPORT_METHOD(headingOrientation:(CLDeviceOrientation) headingOrientation)
{
  locationManager.headingOrientation = headingOrientation;
}



#pragma mark - Converters

static NSDictionary<NSString*, id> *JSONLocation(CLLocation *location)
{
  return @{
           @"altitude": @(location.altitude),
           @"horizontalAccuracy": @(location.horizontalAccuracy),
           @"verticalAccuracy": @(location.verticalAccuracy),
           @"speed": @(location.speed),
           @"course": @(location.course),
           @"timestamp": @([location.timestamp timeIntervalSince1970] * 1000), // ms
           @"coordinate": @{
               @"latitude": @(location.coordinate.latitude),
               @"longitude": @(location.coordinate.longitude)
               }
           };
}

static NSArray<NSDictionary<NSString*, id>*> *JSONLocationArray(NSArray<CLLocation*> *locations)
{
  NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:locations.count];
  for (CLLocation *location in locations) {
    [arr addObject:JSONLocation(location)];
  }

  return [arr copy];
}

static NSDictionary<NSString*, id> *JSONHeading(CLHeading *heading)
{
  return @{
           @"magneticHeading": @(heading.magneticHeading),
           @"trueHeading": @(heading.trueHeading),
           @"headingAccuracy": @(heading.headingAccuracy),
           @"timestamp": @([heading.timestamp timeIntervalSince1970] * 1000), // ms
           @"x": @(heading.x),
           @"y": @(heading.y),
           @"z": @(heading.z),
           };
}

@end
