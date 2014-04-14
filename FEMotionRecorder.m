//
//  FEMotionRecorder.m
//  Feesic
//
//  Created by Takeru Yoshihara on 2014/04/12.
//  Copyright (c) 2014年 Takeru Yoshihara. All rights reserved.
//

#import "FEMotionRecorder.h"

@interface FEMotionRecorder()
{
    FEMotionRecorder *_motionRecorder;
}

@end

static FEMotionRecorder *_sharedRecorder = nil;
@implementation FEMotionRecorder


+ (FEMotionRecorder*)sharedRecorder{
    
    if (_sharedRecorder == nil) {
        
        _sharedRecorder = [FEMotionRecorder new];
        
        //motion_recorder 準備
        _sharedRecorder.motion_manager = [CMMotionManager new];

        
        //移動量初期化
        _sharedRecorder.sum_motion = 0;
        _sharedRecorder.sum_x      = 0;
        _sharedRecorder.sum_y      = 0;
        _sharedRecorder.sum_z      = 0;
        
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
    //加速度取得開始
    if (_motion_manager.accelerometerAvailable) {
        
        //更新間隔
        _motion_manager.accelerometerUpdateInterval = 1/100;
        
        // ハンドラを指定
        CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error)
        {
            //フィルタリング
            float accelX, accelY, accelZ;
            float kFilteringFactor = 0.8;
            
            // はじめにローパスの値を求める
            accelX = data.acceleration.x * kFilteringFactor + accelX * (1.0 - kFilteringFactor);
            accelY = data.acceleration.y * kFilteringFactor + accelY * (1.0 - kFilteringFactor);
            accelZ = data.acceleration.z * kFilteringFactor + accelZ * (1.0 - kFilteringFactor);
            
            // ハイパスフィルター(重力の影響が取り除かれる=瞬間的な加速度がわかる)
            UIAccelerationValue highX, highY, highZ;
            highX = data.acceleration.x - accelX;
            highY = data.acceleration.y - accelY;
            highZ = data.acceleration.z - accelZ;
            
            
            //移動量を加算
            _sum_x += fabs(highX);
            _sum_y += fabs(highY);
            _sum_z += fabs(highZ);
            _sum_motion = _sum_x + _sum_y;
            
            //NSLog(@"sum_x:%f",_sum_x);
            //NSLog(@"sum_y:%f",_sum_y);
            //NSLog(@"sum_z:%f",_sum_z);
            //NSLog(@"sum_motion:%f",_sum_motion);
        };
        
        // 加速度の取得開始
        [_motion_manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        
        _isRecording = YES;
    }
}


- (void)stopRecording
{
    if (_motion_manager.accelerometerActive) {
        [_motion_manager stopAccelerometerUpdates];
        _sum_motion = 0;
        _sum_x = 0;
        _sum_y = 0;
        _sum_z = 0;
        
        _isRecording = NO;
    }
}

@end
