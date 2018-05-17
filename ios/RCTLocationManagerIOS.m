#import "RCTLocationManagerIOS.h"

#import <CoreLocation/CLError.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

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
  /*CLLocation *location = locations.lastObject;
  NSDictionary<NSString *, id> *json = @{
                                      @"altitude": @(location.altitude),
                                      @"horizontalAccuracy": @(location.horizontalAccuracy),
                                      @"verticalAccuracy": @(location.verticalAccuracy),
                                      @"speed": @(location.speed),
                                      @"course": @(location.course),
                                      @"timestamp": @(location.timestamp)
                                      @"coordinate": @{
                                          @"latitude": @(location.coordinate.latitude),
                                          @"longitude": @(location.coordinate.longitude)
                                          }
                                      };*/

  [self sendEventWithName:@"DidUpdateLocations" body:locations];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
  if (!hasListeners) return;
  /*NSDictionary<NSString *, id> *err = @{
    @"code": @(error.code),
    @"domain": error.domain,
    @"userInfo": error.userInfo
  };*/

  [self sendEventWithName:@"DidFailWithError" body:error];
}

#pragma mark API

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"DidUpdateLocations", @"DidFailWithError"];
}

#pragma mark Class Methods

RCT_EXPORT_METHOD(authorizationStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject) {
  resolve(@([CLLocationManager authorizationStatus]));
}

RCT_EXPORT_METHOD(locationServicesEnabled:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject) {
  resolve(@([CLLocationManager locationServicesEnabled]));
}

RCT_EXPORT_METHOD(deferredLocationUpdatesAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject) {
  resolve(@([CLLocationManager deferredLocationUpdatesAvailable]));
}

RCT_EXPORT_METHOD(significantLocationChangeMonitoringAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject) {
  resolve(@([CLLocationManager significantLocationChangeMonitoringAvailable]));
}

RCT_EXPORT_METHOD(headingAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject) {
  resolve(@([CLLocationManager headingAvailable]));
}

RCT_EXPORT_METHOD(isRangingAvailable:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock) reject) {
  resolve(@([CLLocationManager isRangingAvailable]));
}


#pragma mark Instance Methods

RCT_EXPORT_METHOD(requestWhenInUseAuthorization) {
  [locationManager requestWhenInUseAuthorization];
}

RCT_EXPORT_METHOD(requestAlwaysAuthorization) {
  [locationManager requestAlwaysAuthorization];
}

RCT_EXPORT_METHOD(startUpdatingLocation) {
  [locationManager startUpdatingLocation];
}

RCT_EXPORT_METHOD(stopUpdatingLocation) {
  [locationManager stopUpdatingLocation];
}

RCT_EXPORT_METHOD(requestLocation) {
  [locationManager requestLocation];
}

RCT_EXPORT_METHOD(startMonitoringSignificantLocationChanges) {
  [locationManager startMonitoringSignificantLocationChanges];
}

RCT_EXPORT_METHOD(stopMonitoringSignificantLocationChanges) {
  [locationManager stopMonitoringSignificantLocationChanges];
}

RCT_EXPORT_METHOD(startUpdatingHeading) {
  [locationManager startUpdatingHeading];
}

RCT_EXPORT_METHOD(stopUpdatingHeading) {
  [locationManager stopUpdatingHeading];
}

@end
