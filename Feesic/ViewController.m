//
//  ViewController.m
//  Feesic
//
//  Created by Takeru Yoshihara on 2014/04/12.
//  Copyright (c) 2014年 Takeru Yoshihara. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "FEMotionRecorder.h"
#import "FESoundRecorder.h"

@interface ViewController ()
{
    __weak IBOutlet UILabel *_lb_motion;
    __weak IBOutlet UILabel *_lb_sound;
    
    FEMotionRecorder *_motion_recorder;
    FESoundRecorder  *_sound_recorder;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //motion_recorder
    _motion_recorder = [FEMotionRecorder sharedRecorder];
    
    //sound_reocrder
    _sound_recorder = [FESoundRecorder sharedRecorder];
}


- (IBAction)btPressed:(id)sender
{
    if ([self isRecording]) {
        [self sendData];
        [_motion_recorder stopRecording];
        [_sound_recorder stopRecording];
    
    }else{
        _lb_sound.text = @"sound:記録中";
        _lb_motion.text = @"motion:記録中";
        
        [_motion_recorder startRecording];
        [_sound_recorder startRecording];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)isRecording
{
    return _motion_recorder.isRecording && _sound_recorder.isRecording;
}



- (void)sendData
{
    
    //ラベル更新
    _lb_motion.text = [NSString stringWithFormat:@"motion : %f",_motion_recorder.sum_motion];
    
    _lb_sound.text = [NSString stringWithFormat:@"soud : %f",_sound_recorder.level_ava];
    
    //パラメータ準備
    //uuid
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    //motion合計
    NSString *motion = [NSString stringWithFormat:@"%f",_motion_recorder.sum_motion];
    
    //sound合計
    NSString *sound = [NSString stringWithFormat:@"%f", _sound_recorder.level_ava];
    
    NSDictionary  *param = @{@"uid"     : uuid,
                             @"motion"  : motion,
                             @"sound"   : sound,
                             @"lat"     : @"lat",
                             @"lon"     : @"lon",
                             };
    
    //client準備
    NSURL *url = [NSURL URLWithString:@"http://feesic.cloudapp.net/"];
    NSString *path = @"api/index";
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:url];
    [client postPath:path parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:@"送信完了" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [al show];
        
        
        NSLog(@"成功");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@",error.localizedDescription);
        NSLog(@"statuscode:%d",operation.response.statusCode);
    }];
}


@end
