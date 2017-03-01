//
//  AudioPlayerManager.m
//  AudioPlayerManager
//
//  Created by Joshua Sierles on 15/04/15.
//  Copyright (c) 2015 Joshua Sierles. All rights reserved.
//

#import "AudioPlayerManager.h"
#import <React/RCTConvert.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <AVFoundation/AVFoundation.h>

NSString *const AudioPlayerEventFinished = @"playerFinished";

@implementation AudioPlayerManager {

  AVAudioPlayer *_audioPlayer;

  NSURL *_audioFileURL;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)recorder successfully:(BOOL)flag {

  //Stop progress when finished...
  if (_audioPlayer.playing) {
    [_audioPlayer stop];
  }

  [_bridge.eventDispatcher sendDeviceEventWithName:AudioPlayerEventFinished body:@{
      @"finished": flag ? @"true" : @"false"
    }];
}

RCT_REMAP_METHOD(startPlaying, path:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  NSError *error;

    path = [NSString stringWithFormat:@"%@%@", path, @".acc"];

  _audioFileURL = [NSURL fileURLWithPath:path];

  _audioPlayer = [[AVAudioPlayer alloc]
    initWithContentsOfURL:_audioFileURL
    error:&error];
  _audioPlayer.delegate = self;

    if (error) {
        reject(@"error:", @"player prepare failed", error);
  } else {
      [_audioPlayer play];
      resolve(@"started playing");
  }
}

RCT_EXPORT_METHOD(stopPlaying)
{
  if (_audioPlayer.playing) {
    [_audioPlayer stop];
  }
}

- (NSString *)getPathForDirectory:(int)directory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
  return [paths firstObject];
}

- (NSDictionary *)constantsToExport
{
  return @{
    @"DocumentDirectoryPath": [self getPathForDirectory:NSDocumentDirectory]
  };
}
@end
