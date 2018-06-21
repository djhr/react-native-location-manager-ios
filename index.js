/**
 * Copyright (c) 2018-present, Daniel Rosa.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import { NativeModules, NativeEventEmitter } from 'react-native';

const NativeModule = NativeModules.LocationManagerIOS;

const Emitter = new NativeEventEmitter(NativeModule);

export default class LocationManagerIOS {

    static Events = {
        didUpdateLocations: 'didUpdateLocations',
        didFailWithError: 'didFailWithError',
        didFinishDeferredUpdatesWithError: 'didFinishDeferredUpdatesWithError',
        didPauseLocationUpdates: 'didPauseLocationUpdates',
        didResumeLocationUpdates: 'didResumeLocationUpdates',
        didUpdateHeading: 'didUpdateHeading',
        didEnterRegion: 'didEnterRegion',
        didExitRegion: 'didExitRegion',
        didDetermineStateForRegion: 'didDetermineStateForRegion',
        monitoringDidFailForRegion: 'monitoringDidFailForRegion',
        didStartMonitoringForRegion: 'didStartMonitoringForRegion',
        didRangeBeaconsInRegion: 'didRangeBeaconsInRegion',
        rangingBeaconsDidFailForRegion: 'rangingBeaconsDidFailForRegion',
        didVisit: 'didVisit',
        didChangeAuthorizationStatus: 'didChangeAuthorizationStatus',
    };


    // enums

    static AuthorizationStatus = {
        NotDetermined: NativeModule.AuthorizationStatusNotDetermined,
        Restricted: NativeModule.AuthorizationStatusRestricted,
        Denied: NativeModule.AuthorizationStatusDenied,
        AuthorizedAlways: NativeModule.AuthorizationStatusAuthorizedAlways,
        AuthorizedWhenInUse: NativeModule.AuthorizationStatusAuthorizedWhenInUse,
    };

    static LocationAccuracy = {
        BestForNavigation: NativeModule.LocationAccuracyBestForNavigation,
        Best: NativeModule.LocationAccuracyBest,
        NearestTenMeters: NativeModule.LocationAccuracyNearestTenMeters,
        HundredMeters: NativeModule.LocationAccuracyHundredMeters,
        Kilometer: NativeModule.LocationAccuracyKilometer,
        ThreeKilometers: NativeModule.LocationAccuracyThreeKilometers,
    };

    static DistanceFilter = {
        None: NativeModule.DistanceFilterNone,
    };

    static ActivityType = {
        Other: NativeModule.ActivityTypeOther,
        AutomotiveNavigation: NativeModule.ActivityTypeAutomotiveNavigation,
        Fitness: NativeModule.ActivityTypeFitness,
        OtherNavigation: NativeModule.ActivityTypeOtherNavigation,
    };

    static DeviceOrientation = {
        Unknown: NativeModule.DeviceOrientationUnknown,
        Portrait: NativeModule.DeviceOrientationPortrait,
        PortraitUpsideDown: NativeModule.DeviceOrientationPortraitUpsideDown,
        LandscapeLeft: NativeModule.DeviceOrientationLandscapeLeft,
        LandscapeRight: NativeModule.DeviceOrientationLandscapeRight,
        FaceUp: NativeModule.DeviceOrientationFaceUp,
        FaceDown: NativeModule.DeviceOrientationFaceDown,
    };

    static RegionState = {
        Unknown: NativeModule.RegionStateUnknown,
        Inside: NativeModule.RegionStateInside,
        Outside: NativeModule.RegionStateOutside,
    };

    static Proximity = {
        Unknown: NativeModule.ProximityUnknown,
        Immediate: NativeModule.ProximityImmediate,
        Near: NativeModule.ProximityNear,
        Far: NativeModule.ProximityFar,
    };

    static Error = {
        LocationUnknown: NativeModule.ErrorLocationUnknown,
        Denied: NativeModule.ErrorDenied,
        Network: NativeModule.ErrorNetwork,
        HeadingFailure: NativeModule.ErrorHeadingFailure,
        RegionMonitoringDenied: NativeModule.ErrorRegionMonitoringDenied,
        RegionMonitoringFailure: NativeModule.ErrorRegionMonitoringFailure,
        RegionMonitoringSetupDelayed: NativeModule.ErrorRegionMonitoringSetupDelayed,
        RegionMonitoringResponseDelayed: NativeModule.ErrorRegionMonitoringResponseDelayed,
        GeocodeFoundNoResult: NativeModule.ErrorGeocodeFoundNoResult,
        GeocodeFoundPartialResult: NativeModule.ErrorGeocodeFoundPartialResult,
        GeocodeCanceled: NativeModule.ErrorGeocodeCanceled,
        DeferredFailed: NativeModule.ErrorDeferredFailed,
        DeferredNotUpdatingLocation: NativeModule.ErrorDeferredNotUpdatingLocation,
        DeferredAccuracyTooLow: NativeModule.ErrorDeferredAccuracyTooLow,
        DeferredDistanceFiltered: NativeModule.ErrorDeferredDistanceFiltered,
        DeferredCanceled: NativeModule.ErrorDeferredCanceled,
        RangingUnavailable: NativeModule.ErrorRangingUnavailable,
        RangingFailure: NativeModule.ErrorRangingFailure,
    };


    // getters & setters

    static get pausesLocationUpdatesAutomatically() {
        return NativeModule.getPausesLocationUpdatesAutomatically();
    }

    static set pausesLocationUpdatesAutomatically(value) {
        NativeModule.setPausesLocationUpdatesAutomatically(!!value);
    }

    static get allowsBackgroundLocationUpdates() {
        return NativeModule.getAllowsBackgroundLocationUpdates();
    }

    static set allowsBackgroundLocationUpdates(value) {
        NativeModule.setAllowsBackgroundLocationUpdates(!!value);
    }

    static get showsBackgroundLocationIndicator() {
        return NativeModule.getShowsBackgroundLocationIndicator();
    }

    static set showsBackgroundLocationIndicator(value) {
        NativeModule.setShowsBackgroundLocationIndicator(!!value);
    }

    static get distanceFilter() {
        return NativeModule.getDistanceFilter();
    }

    static set distanceFilter(distance) {
        if (typeof(distance) !== 'number') throw new TypeError('Invalid distanceFilter');

        NativeModule.setDistanceFilter(distance);
    }

    static get desiredAccuracy() {
        return NativeModule.getDesiredAccuracy();
    }

    static set desiredAccuracy(accuracy) {
        if (typeof(accuracy) !== 'number') throw new TypeError('Invalid desiredAccuracy');

        NativeModule.setDesiredAccuracy(accuracy);
    }

    static get activityType() {
        return NativeModule.getActivityType();
    }

    static set activityType(activityType) {
        const valid = Object.values(LocationManagerIOS.ActivityType);
        if (!valid.includes(activityType)) throw new TypeError(`Invalid activityType, must be one of ${valid.join(', ')}`);

        NativeModule.setActivityType(activityType);
    }

    static get headingFilter() {
        return NativeModule.getHeadingFilter();
    }

    static set headingFilter(heading) {
        if (typeof(heading) !== 'number') throw new TypeError('Invalid headingFilter');

        NativeModule.setHeadingFilter(heading);
    }

    static get headingOrientation() {
        return NativeModule.getHeadingOrientation();
    }

    static set headingOrientation(orientation) {
        const valid = Object.values(LocationManagerIOS.DeviceOrientation);
        if (!valid.includes(orientation)) throw new TypeError(`Invalid headingOrientation, must be one of ${valid.join(', ')}`);

        NativeModule.setHeadingOrientation(orientation);
    }

    static get maximumRegionMonitoringDistance() {
        return NativeModule.getMaximumRegionMonitoringDistance();
    }

    static get monitoredRegions() {
        return NativeModule.getMonitoredRegions();
    }

    static get rangedRegions() {
        return NativeModule.getRangedRegions();
    }

    static get location() {
        return NativeModule.getLocation();
    }

    static get heading() {
        return NativeModule.getHeading();
    }


    // methods

    static addListener(evt, fn) {
        const valid = Object.values(LocationManagerIOS.Events);
        if (!valid.includes(evt)) throw new TypeError(`Invalid event, must be one of ${valid.join(', ')}`);

        return Emitter.addListener(evt, fn);
    }

    static authorizationStatus() {
        return NativeModule.authorizationStatus();
    }

    static locationServicesEnabled() {
        return NativeModule.locationServicesEnabled();
    }

    static deferredLocationUpdatesAvailable() {
        return NativeModule.deferredLocationUpdatesAvailable();
    }

    static significantLocationChangeMonitoringAvailable() {
        return NativeModule.significantLocationChangeMonitoringAvailable();
    }

    static headingAvailable() {
        return NativeModule.headingAvailable();
    }

    static isRangingAvailable() {
        return NativeModule.isRangingAvailable();
    }

    static requestWhenInUseAuthorization() {
        NativeModule.requestWhenInUseAuthorization();
    }

    static requestAlwaysAuthorization() {
        NativeModule.requestAlwaysAuthorization();
    }

    static startUpdatingLocation() {
        NativeModule.startUpdatingLocation();
    }

    static stopUpdatingLocation() {
        NativeModule.stopUpdatingLocation();
    }

    static requestLocation() {
        NativeModule.requestLocation();
    }

    static startMonitoringSignificantLocationChanges() {
        NativeModule.startMonitoringSignificantLocationChanges();
    }

    static stopMonitoringSignificantLocationChanges() {
        NativeModule.stopMonitoringSignificantLocationChanges();
    }

    static startUpdatingHeading() {
        NativeModule.startUpdatingHeading();
    }

    static stopUpdatingHeading() {
        NativeModule.stopUpdatingHeading();
    }

    static dismissHeadingCalibrationDisplay() {
        NativeModule.dismissHeadingCalibrationDisplay();
    }

    static startMonitoringForRegion(identifier, latitude, longitude, radius, notifyOnEntry, notifyOnExit) {
        const center = CLFactory.makeCoordinate(latitude, longitude);
        const region = CLFactory.makeCircularRegion(identifier, center, radius, notifyOnEntry, notifyOnExit);

        NativeModule.startMonitoringForRegion(region);
    }

    static stopMonitoringForRegion(identifier) {
        if (typeof(identifier) !== 'string') throw new TypeError('Invalid region identifier');

        NativeModule.stopMonitoringForRegion(identifier);
    }

    static stopMonitoringForAllRegions() {
        NativeModule.stopMonitoringForAllRegions();
    }

    static startRangingBeaconsInRegion(identifier, proximityUUID, major, minor, notifyOnEntry, notifyOnExit) {
        const region = CLFactory.makeBeaconRegion(identifier, proximityUUID, major, minor, notifyOnEntry, notifyOnExit);

        NativeModule.startRangingBeaconsInRegion(region);
    }

    static stopRangingBeaconsInRegion(identifier) {
        if (typeof(identifier) !== 'string') throw new TypeError('Invalid region identifier');

        NativeModule.stopRangingBeaconsInRegion(identifier);
    }

    static stopRangingBeaconsInAllRegions() {
        NativeModule.stopRangingBeaconsInAllRegions();
    }

    static requestStateForRegion(identifier) {
        if (typeof(identifier) !== 'string') throw new TypeError('Invalid region identifier');

        NativeModule.requestStateForRegion(identifier);
    }

    static startMonitoringVisits() {
        NativeModule.startMonitoringVisits();
    }

    static stopMonitoringVisits() {
        NativeModule.stopMonitoringVisits();
    }

    static allowDeferredLocationUpdatesUntilTraveled(distance, timeout) {
        if (typeof(distance) !== 'number') throw new TypeError('Invalid distance');
        if (typeof(timeout) !== 'number') throw new TypeError('Invalid timeout');

        NativeModule.allowDeferredLocationUpdatesUntilTraveled(distance, timeout);
    }

    static disallowDeferredLocationUpdates() {
        NativeModule.disallowDeferredLocationUpdates();
    }
}


class CLFactory {

    static makeCoordinate(latitude, longitude) {
        if (typeof(latitude) !== 'number') throw new TypeError('Invalid latitude');
        if (typeof(longitude) !== 'number') throw new TypeError('Invalid longitude');

        return { latitude, longitude };
    }

    static makeCircularRegion(identifier, center, radius, notifyOnEntry, notifyOnExit) {
        if (typeof(identifier) !== 'string') throw new TypeError('Invalid identifier');
        if (typeof(radius) !== 'number') throw new TypeError('Invalid radius');

        return { identifier, radius, center, notifyOnEntry, notifyOnExit };
    }

    static makeBeaconRegion(identifier, proximityUUID, major, minor, notifyOnEntry, notifyOnExit) {
        if (typeof(identifier) !== 'string') throw new TypeError('Invalid identifier');
        if (typeof(proximityUUID) !== 'string') throw new TypeError('Invalid proximityUUID');

        return { identifier, proximityUUID, major, minor, notifyOnEntry, notifyOnExit };
    }
}
