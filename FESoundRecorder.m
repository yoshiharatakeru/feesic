//
//  FESoundRecorder.m
//  Feesic
//
//  Created by Takeru Yoshihara on 2014/04/12.
//  Copyright (c) 2014年 Takeru Yoshihara. All rights reserved.
//

#import "FESoundRecorder.h"
#import <AudioToolbox/AudioToolbox.h>

@interface FESoundRecorder()
{
    AudioQueueRef _queue;
    NSTimer       *_timer;
}
@end


static FESoundRecorder *_sharedRecorder = nil;
@implementation FESoundRecorder

+ (FESoundRecorder*)sharedRecorder{
    
    if (_sharedRecorder == nil) {
        
        _sharedRecorder = [FESoundRecorder new];
        
        //初期設定
        _sharedRecorder.isRecording = NO;
        _sharedRecorder.level_ava = -100;
        _sharedRecorder.level_max = -100;
    }
    return _sharedRecorder;
}


+ (id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (_sharedRecorder == nil) {
            _sharedRecorder = [super allocWithZone:zone];
            return _sharedRecorder;
        }
    }
    return nil;
}


- (id)copyWithZone:(NSZone*)zone{
    
    return self;
}


- (void)startRecording
{
    [_sharedRecorder initDataFormat];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(updateLevel:)
                                            userInfo:nil
                                             repeats:YES];
    _isRecording = YES;
    
}


- (void)updateLevel:(NSTimer*)timer
{
    // レベルを取得
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(_queue, kAudioQueueProperty_CurrentLevelMeterDB, &levelMeter, &levelMeterSize);
    
    // 最大レベル、平均レベルを更新
    /*
    _level_max = levelMeter.mPeakPower;
    _level_ava = levelMeter.mAveragePower;
     */
    
    //平均値をその時の最大値として扱う方がよさそう
    if (_level_ava < levelMeter.mAveragePower) {
        _level_ava = levelMeter.mAveragePower;
    }
    
    //NSLog(@"level_max:%f", _level_max);
    NSLog(@"level_ava:%f", _level_ava);
}


- (void)stopRecording
{
    [_timer invalidate];
    AudioQueueFlush(_queue);
    AudioQueueStop(_queue, NO);
    AudioQueueDispose(_queue, YES);
    
    _level_ava = -100;
    _level_max = -100;
    
    _isRecording = NO;
}


- (void)initDataFormat
{
    AudioStreamBasicDescription dataFormat;
    dataFormat.mSampleRate = 44100.0f;
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    dataFormat.mBytesPerPacket = 2;
    dataFormat.mFramesPerPacket = 1;
    dataFormat.mBytesPerFrame = 2;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mReserved = 0;
    
    AudioQueueNewInput(&dataFormat, AudioInputCallback, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_queue);
    AudioQueueStart(_queue, NULL);
    
    UInt32 enabledLevelMeter = true;
    AudioQueueSetProperty(_queue, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, sizeof(UInt32));
    
}


static void AudioInputCallback(
                               void* inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumberPacketDescriptions,
                               const AudioStreamPacketDescription *inPacketDescs)
{
}

@end
