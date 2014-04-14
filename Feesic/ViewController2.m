//
//  ViewController2.m
//  Feesic
//
//  Created by Takeru Yoshihara on 2014/04/12.
//  Copyright (c) 2014年 Takeru Yoshihara. All rights reserved.
//

#import "ViewController2.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController2 ()
{
    //label
    __weak IBOutlet UILabel *_lb_max;
    __weak IBOutlet UILabel *_lb_avarage;
    
    
    AudioQueueRef   _queue;     // 音声入力用のキュー
    NSTimer         *_timer;    // 監視タイマー
    
}

@end

@implementation ViewController2


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
    
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//音量を表示
- (void)detectVolume:(NSTimer*)timer
{
    NSLog(@"timer");
    // レベルを取得
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(_queue, kAudioQueueProperty_CurrentLevelMeterDB, &levelMeter, &levelMeterSize);
    
    // 最大レベル、平均レベルを表示
    _lb_max.text = [NSString stringWithFormat:@"%.2f", levelMeter.mPeakPower];
    _lb_avarage.text = [NSString stringWithFormat:@"%.2f", levelMeter.mAveragePower];
    
    NSLog(@"max:%f",levelMeter.mPeakPower);
    NSLog(@"avarage:%f",levelMeter.mAveragePower);
}



- (void)startRecording
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
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(detectVolume:)
                                            userInfo:nil
                                             repeats:YES];
}


- (void)stopRecording
{
    [_timer invalidate];
    AudioQueueFlush(_queue);
    AudioQueueStop(_queue, NO);
    AudioQueueDispose(_queue, YES);
}


- (IBAction)btPressed:(id)sender {
    
    if ([_timer isValid]) {
        [self stopRecording];
    
    }else{
        [self startRecording];
    }
}




@end
