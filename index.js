import { NativeModules, NativeEventEmitter } from 'react-native';

const Emitter = new NativeEventEmitter(NativeModules.LocationManagerIOS);

export default {
    ...NativeModules.LocationManagerIOS,
    addListener: (evt, fn) => Emitter.addListener(evt, fn),
    Events: {
        didUpdateLocations: 'didUpdateLocations',
        didFailWithError: 'didFailWithError',
        didVisit: 'didVisit',
    },
};
