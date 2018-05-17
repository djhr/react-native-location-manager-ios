import { NativeModules, NativeEventEmitter } from 'react-native';

const Emitter = new NativeEventEmitter(NativeModules.LocationManagerIOS);

export default {
    ...NativeModules.LocationManagerIOS,
    addListener: (evt, fn) => Emitter.addListener(evt, fn),
    Events: {
        didUpdateLocations: 'didUpdateLocations',
        didFailWithError: 'didFailWithError',
        didUpdateHeading: 'didUpdateHeading',
        didEnterRegion: 'didEnterRegion',
        didExitRegion: 'didExitRegion',
        monitoringDidFailForRegion: 'monitoringDidFailForRegion',
        didRangeBeaconsInRegion: 'didRangeBeaconsInRegion',
        rangingBeaconsDidFailForRegion: 'rangingBeaconsDidFailForRegion',
        didDetermineStateForRegion: 'didDetermineStateForRegion',
        didVisit: 'didVisit',
        didFinishDeferredUpdatesWithError: 'didFinishDeferredUpdatesWithError',
    },
};
