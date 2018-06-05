# react-native-location-manager-ios
React Native Location Manager Bridge for iOS

## Installation
`yarn add react-native-location-manager-ios`

### Automatic linking
`react-native link react-native-location-manager-ios`

### Manual linking
1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-location-manager-ios` ➜ `ios` and add `RCTLocationManagerIOS.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRCTLocationManagerIOS.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`

### Usage Description
Add to your `Info.plist` apropriate `*UsageDescription` keys with a string value explaining to the
user how the app uses location data. Please see [official documentation](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Some description</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Some description</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Some description</string>
```

## Usage

```js
import LocationManagerIOS from 'react-native-location-manager-ios';
```

## API

### Events

Event names are available under `LocationManagerIOS.Events` object.
```js
const subscription = LocationManagerIOS.addListener(LocationManagerIOS.Events.didUpdateLocations, console.log);
// ...
subscription.remove();
```

See [`CLLocationManagerDelegate`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate) for in-depth details.

| Event | Listener Arguments | Notes
|---|---|---|
| [`didUpdateLocations`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager) | `locations: Array<Location>` |
| [`didFailWith`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423786-locationmanager) | `error: Error` |
| [`didFinishDeferredUpdatesWithError`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423537-locationmanager) | `error: Error` |
| [`didPauseLocationUpdates`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1621553-locationmanagerdidpauselocationu) |  |
| [`didResumeLocationUpdates`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1621512-locationmanagerdidresumelocation) |  |
| [`didUpdateHeading`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1621555-locationmanager) | `heading: Heading` |
| [`didEnterRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423560-locationmanager) | `region: Region` |
| [`didExitRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423630-locationmanager) | `region: Region` |
| [`didDetermineStateForRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423570-locationmanager) | `{ region: Region, state: RegionState }` |
| [`monitoringDidFailForRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423720-locationmanager) | `{ region: Region, error: Error }` |
| [`didStartMonitoringForRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423842-locationmanager) | `region: Region` |
| [`didRangeBeaconsInRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1621501-locationmanager) | `{ beacons: Array<Beacon>, region: BeaconRegion }` |
| [`rangingBeaconsDidFailForRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1621483-locationmanager) | `{ region: BeaconRegion, error: Error }` |
| [`didVisit`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1621529-locationmanager) | `visit: Visit` |
| [`didChangeAuthorizationStatus`](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423701-locationmanager) | `status: AuthorizationStatus` |


### Enumerations

```js
LocationManagerIOS.addListener(LocationManagerIOS.Events.didFailWithError, (err) => {
  if (err.code === LocationManagerIOS.Error.LocationUnknown) {
    // ...
  }
});
```

| Enumeration | Values
|---|---|
| [`AuthorizationStatus`](https://developer.apple.com/documentation/corelocation/clauthorizationstatus) | `NotDetermined`, `Restricted`, `Denied`, `AuthorizedAlways`, `AuthorizedWhenInUse`
| [`LocationAccuracy`](https://developer.apple.com/documentation/corelocation/cllocationaccuracy) | `BestForNavigation`, `Best`, `NearestTenMeters`, `HundredMeters`, `Kilometer`, `ThreeKilometers`
| [`DistanceFilter`](https://developer.apple.com/documentation/corelocation/kcldistancefilternone) | `None`
| [`ActivityType`](https://developer.apple.com/documentation/corelocation/clactivitytype) | `Other`, `AutomotiveNavigation`, `Fitness`, `OtherNavigation`
| [`DeviceOrientation`](https://developer.apple.com/documentation/uikit/uideviceorientation) | `Unknown`, `Portrait`, `PortraitUpsideDown`, `LandscapeLeft`, `LandscapeRight`, `FaceUp`, `FaceDown`
| [`RegionState`](https://developer.apple.com/documentation/corelocation/clregionstate) | `Unknown`, `Inside`, `Outside`
| [`Proximity`](https://developer.apple.com/documentation/corelocation/clproximity) | `Unknown`, `Immediate`, `Near`, `Far`
| [`Error`](https://developer.apple.com/documentation/corelocation/clerror?language=objc) | `LocationUnknown`, `Denied`, `Network`, `HeadingFailure`, `RegionMonitoringDenied`, `RegionMonitoringFailure`, `RegionMonitoringSetupDelayed`, `RegionMonitoringResponseDelayed`, `GeocodeFoundNoResult`, `GeocodeFoundPartialResult`, `GeocodeCanceled`, `DeferredFailed`, `DeferredNotUpdatingLocation`, `DeferredAccuracyTooLow`, `DeferredDistanceFiltered`, `DeferredCanceled`, `RangingUnavailable`, `RangingFailure`


### Properties

Property getters return a promise resolved with the property value.

See [`CLLocationManager`](https://developer.apple.com/documentation/corelocation/cllocationmanager) for in-depth details.

```js
const monitoredRegions = await LocationManagerIOS.monitoredRegions;
monitoredRegions.forEach(console.log)

const distanceFilter = await LocationManagerIOS.distanceFilter;
if (distanceFilter === LocationManagerIOS.DistanceFilter.None) {
  LocationManagerIOS.distanceFilter = 3;
}

LocationManagerIOS.desiredAccuracy = LocationManagerIOS.LocationAccuracy.BestForNavigation;

LocationManagerIOS.activityType = LocationManagerIOS.ActivityType.AutomotiveNavigation;
```

| Property | Type | Notes
|---|---|---|
| [`pausesLocationUpdatesAutomatically`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620553-pauseslocationupdatesautomatical) | `bool` |
| [`allowsBackgroundLocationUpdates`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620568-allowsbackgroundlocationupdates) | `bool` |
| [`showsBackgroundLocationIndicator`](https://developer.apple.com/documentation/corelocation/cllocationmanager/2923541-showsbackgroundlocationindicator) | `bool` |
| [`distanceFilter`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423500-distancefilter) | `double` |
| [`desiredAccuracy`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423836-desiredaccuracy) | `double` |
| [`activityType`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620567-activitytype) | `LocationManagerIOS.ActivityType` |
| [`headingFilter`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620550-headingfilter) | `double` |
| [`headingOrientation`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620556-headingorientation) | `LocationManagerIOS.DeviceOrientation` |
| [`maximumRegionMonitoringDistance`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423740-maximumregionmonitoringdistance) | `double` | `readonly`
| [`monitoredRegions`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423790-monitoredregions) |  `Array<CircularRegion>` | `readonly`
| [`gpsMonitoredRegions`](#custom) | `Array<CircularRegion>` | `readonly`, `custom`
| [`rangedRegions`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620552-rangedregions) | `Array<BeaconRegion>` | `readonly`
| [`location`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423687-location) | `Location` | `readonly`
| [`heading`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620555-heading) | `Heading` | `readonly`


### Methods

Non `void` methods return a promise which will resolve to the according type.

See [`CLLocationManager`](https://developer.apple.com/documentation/corelocation/cllocationmanager) for in-depth details.

| Method | Arguments | Return | Notes
|---|---|---|---|
| `addListener` | `event: string`, `listener: function` | `{ remove: function }` | `custom`
| [`authorizationStatus`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423523-authorizationstatus) | | `LocationManagerIOS.AuthorizationStatus` |
| [`locationServicesEnabled`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423648-locationservicesenabled) | | `bool` |
| [`deferredLocationUpdatesAvailable`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423830-deferredlocationupdatesavailable) | | `bool` |
| [`significantLocationChangeMonitoringAvailable`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423677-significantlocationchangemonitor) | | `bool` |
| [`headingAvailable`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423502-headingavailable) | | `bool` |
| [`isRangingAvailable`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620549-israngingavailable) | | `bool` |
| [`requestWhenInUseAuthorization`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620562-requestwheninuseauthorization) | | `void` |
| [`requestAlwaysAuthorization`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620551-requestalwaysauthorization) | | `void` |
| [`startUpdatingLocation`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423750-startupdatinglocation) | | `void` |
| [`stopUpdatingLocation`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423695-stopupdatinglocation) | | `void` |
| [`requestLocation`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620548-requestlocation) | | `void` |
| [`startMonitoringSignificantLocationChanges`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati) | | `void` |
| [`stopMonitoringSignificantLocationChanges`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423679-stopmonitoringsignificantlocatio) | | `void` |
| [`startUpdatingHeading`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620558-startupdatingheading) | | `void` |
| [`stopUpdatingHeading`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620569-stopupdatingheading) | | `void` |
| [`dismissHeadingCalibrationDisplay`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620563-dismissheadingcalibrationdisplay) | | `void` |
| [`startMonitoringForRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423656-startmonitoringforregion) | `identifier: string`, `latitude: double`, `longitude: double`, `radius: double`, `notifyOnEntry: bool`, `notifyOnExit: bool` | `void` |
| [`stopMonitoringForRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423840-stopmonitoringforregion) | `identifier: string` | `void` |
| [`stopMonitoringForAllRegions`](#custom) | | `void` | `custom`
| [`startRangingBeaconsInRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620554-startrangingbeaconsinregion) | `identifier: string`, `proximityUUID: string`, `major: int`, `minor: int`, `notifyOnEntry: bool`, `notifyOnExit: bool` | `void` |
| [`stopRangingBeaconsInRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620559-stoprangingbeaconsinregion) | `identifier: string` | `void` |
| [`stopRangingBeaconsInAllRegions`](#custom) | | `void` | `custom`
| [`requestStateForRegion`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423804-requeststateforregion) | `identifier: string` | `void` |
| [`startMonitoringVisits`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1618692-startmonitoringvisits) | | `void` |
| [`stopMonitoringVisits`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1618693-stopmonitoringvisits) | | `void` |
| [`allowDeferredLocationUpdatesUntilTraveled`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620547-allowdeferredlocationupdatesunti) | `distance: double`, `timeout: double` | `void` |
| [`disallowDeferredLocationUpdates`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620565-disallowdeferredlocationupdates) | | `void` |


### Types

```js
type Error {
  code: int,
  domain: string,
}
```

```js
type Location {
  altitude: double,
  horizontalAccuracy: double,
  verticalAccuracy: double,
  speed: double,
  course: double,
  timestamp: double, // precision is to the millisecond
  coordinate: Coordinate,
}
```

```js
type Coordinate {
  latitude: double,
  longitude: double,
}
```

```js
type Region {
  identifier: string,
  notifyOnEntry: bool,
  notifyOnExit: bool,
}
```

```js
type CircularRegion {
  identifier: string,
  radius: double,
  center: Coordinate,
  notifyOnEntry: bool,
  notifyOnExit: bool,
}
```

```js
type BeaconRegion {
  identifier: string,
  proximityUUID: string,
  major: int,
  minor: int,
  notifyOnEntry: bool,
  notifyOnExit: bool,
}
```

```js
type Beacon {
  proximityUUID: string,
  major: int,
  minor: int,
  proximity: LocationManagerIOS.Proximity,
  accuracy: double,
  rssi: long,
}
```

```js
type Visit {
  horizontalAccuracy: double,
  arrivalDate: double, // precision is to the millisecond
  departureDate: double, // precision is to the millisecond
  coordinate: Coordinate,
}
```

```js
type Heading {
  magneticHeading: double,
  trueHeading: double,
  headingAccuracy: double,
  timestamp: double, // precision is to the millisecond
  x: double,
  y: double,
  z: double,
}
```


### Custom

#### LocationManagerIOS.stopMonitoringForAllRegions()
Native implementation for:
```js
const monitoredRegions = await LocationManagerIOS.monitoredRegions;
const gpsMonitoredRegions = await LocationManagerIOS.gpsMonitoredRegions;

gpsMonitoredRegions.concat(monitoredRegions)
  .map(r => r.identifier)
  .forEach(LocationManagerIOS.stopMonitoringForRegion);
```


#### LocationManagerIOS.stopRangingBeaconsInAllRegions()
Native implementation for:
```js
const rangedRegions = await LocationManagerIOS.rangedRegions;
rangedRegions.map(r => r.identifier)
  .forEach(LocationManagerIOS.stopRangingBeaconsInRegion);
```


#### LocationManagerIOS.gpsMonitoredRegions
to be continued...