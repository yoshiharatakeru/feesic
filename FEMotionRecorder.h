//
//  FEMotionRecorder.h
//  Feesic
//
//  Created by Takeru Yoshihara on 2014/04/12.
//  Copyright (c) 2014年 Takeru Yoshihara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface FEMotionRecorder : NSObject


@property CGFloat sum_x;
@property CGFloat sum_y;
@property CGFloat sum_z;
@property CGFloat sum_motion;
@property (nonatomic, strong) CMMotionManager *motion_manager;
@property BOOL isRecording;

+ (FEMotionRecorder*)sharedRecorder;
- (void)startRecording;
- (void)stopRecording;



@end
