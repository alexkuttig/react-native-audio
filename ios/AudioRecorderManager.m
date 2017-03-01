//
//  AudioRecorderManager.m
//  AudioRecorderManager
//
//  Created by Joshua Sierles on 15/04/15.
//  Copyright (c) 2015 Joshua Sierles. All rights reserved.
//

#import "AudioRecorderManager.h"
#import <React/RCTConvert.h>
#import <React/RCTBridge.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>
#import <AVFoundation/AVFoundation.h>

NSString *const AudioRecorderEventProgress = @"recordingProgress";
NSString *const AudioRecorderEventFinished = @"recordingFinished";

@implementation AudioRecorderManager {

  AVAudioRecorder *_audioRecorder;

  NSURL *_audioFileURL;
  NSNumber *_audioQuality;
  NSNumber *_audioEncoding;
  NSNumber *_audioChannels;
  NSNumber *_audioSampleRate;
  AVAudioSession *_recordSession;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
  [self.bridge.eventDispatcher sendAppEventWithName:AudioRecorderEventFinished body:@{
      @"status": flag ? @"OK" : @"ERROR",
      @"audioFileURL": [_audioFileURL absoluteString]
    }];
}

- (NSString *) applicationDocumentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
}

RCT_REMAP_METHOD(startRecording, path:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{

  if (!_audioRecorder.recording) {
    path = [NSString stringWithFormat:@"%@%@", path, @".acc"];

    
  _audioFileURL = [NSURL fileURLWithPath:path];

  // Default options
  _audioQuality = [NSNumber numberWithInt:AVAudioQualityHigh];
  _audioEncoding = [NSNumber numberWithInt:kAudioFormatAppleIMA4];
  _audioChannels = [NSNumber numberWithInt:2];
  _audioSampleRate = [NSNumber numberWithFloat:44100.0];


  NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
          _audioQuality, AVEncoderAudioQualityKey,
          _audioEncoding, AVFormatIDKey,
          _audioChannels, AVNumberOfChannelsKey,
          _audioSampleRate, AVSampleRateKey,
          nil];

  NSError *error = nil;

  _recordSession = [AVAudioSession sharedInstance];
  [_recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

  _audioRecorder = [[AVAudioRecorder alloc]
                initWithURL:_audioFileURL
                settings:recordSettings
                error:&error];

  _audioRecorder.delegate = self;

  if (error) {
      reject(@"error:", @"recorder prepare failed", error);

    } else {
      [_audioRecorder prepareToRecord];
    [_recordSession setActive:YES error:nil];
    [_audioRecorder record];
      resolve(@"started recording");
  }
  }
}

RCT_EXPORT_METHOD(stopRecording)
{
  if (_audioRecorder.recording) {
    [_audioRecorder stop];
    [_recordSession setActive:NO error:nil];
  }
}

RCT_REMAP_METHOD(checkAuthorizationStatus, resolver:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject)
{
  AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
  switch (permissionStatus) {
    case AVAudioSessionRecordPermissionUndetermined:
      resolve(@("undetermined"));
    break;
    case AVAudioSessionRecordPermissionDenied:
      resolve(@("denied"));
      break;
    case AVAudioSessionRecordPermissionGranted:
      resolve(@("granted"));
      break;
    default:
      reject(RCTErrorUnspecified, nil, RCTErrorWithMessage(@("Error checking device authorization status.")));
      break;
  }
}

RCT_REMAP_METHOD(requestAuthorization, resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(__unused RCTPromiseRejectBlock)reject)
{
  [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
    if(granted) {
      resolve(@YES);
    } else {
      resolve(@NO);
    }
  }];
}

@end
