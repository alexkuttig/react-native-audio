'use strict';

/**
 * This module is a thin layer over the native module. It's aim is to obscure
 * implementation details for registering callbacks, changing settings, etc.
*/

var React, {NativeModules, NativeAppEventEmitter, DeviceEventEmitter} = require('react-native');

var AudioPlayerManager = NativeModules.AudioPlayerManager;
var AudioRecorderManager = NativeModules.AudioRecorderManager;

var AudioPlayer = {

  startPlaying: function(path) {
      return new Promise(async function(resolve, reject){
        try{
        console.log(path);
            let success = await AudioPlayerManager.startPlaying(path);
            resolve(success);
        } catch(e){
            reject(e);
        }
      });
  },
  stopPlaying: function() {
    AudioPlayerManager.stopPlaying();
  },
  setFinishedSubscription: function() {
    if (this.finishedSubscription) this.finishedSubscription.remove();
    this.finishedSubscription = NativeAppEventEmitter.addListener('playerFinished',
      (data) => {
        if (this.onFinished) {
          this.onFinished(data);
        }
      }
    );
  }
};

var AudioRecorder = {

  startRecording: function(path) {
      return new Promise(async function(resolve, reject){
        try{
            let success = await AudioRecorderManager.startRecording(path);
            resolve(success);
        } catch(e){
            reject(e);
        }
      });
  },
  stopRecording: function() {
    AudioRecorderManager.stopRecording();
  }
};

var AudioUtils = {
  DocumentDirectoryPath: AudioPlayerManager.DocumentDirectoryPath,
};

module.exports = {AudioPlayer, AudioRecorder, AudioUtils};
