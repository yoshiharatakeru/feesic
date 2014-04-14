//
//  FESoundRecorder.h
//  Feesic
//
//  Created by Takeru Yoshihara on 2014/04/12.
//  Copyright (c) 2014年 Takeru Yoshihara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FESoundRecorder : NSObject

@property CGFloat level_max;
@property CGFloat level_ava;
@property BOOL isRecording;


+ (FESoundRecorder*)sharedRecorder;
- (void)startRecording;
- (void)stopRecording;


@end
