//
//  SMPlaySound.m
//  Common
//
//  Created by QFITS－iOS on 16/1/15.
//  Copyright © 2016年 Smartmovt. All rights reserved.
//

#import "SMPlaySound.h"

@implementation SMPlaySound

- (instancetype) init
{
    if(self = [super init])
    {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        /*
         Adding the above line of code made it so my audio would start even if the app was in the background.
         */
        
        NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"findphone" ofType:@"caf"]];
        
        _audioSession = [AVAudioSession sharedInstance];
        [_audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [_audioSession setActive:YES error:nil];
        
        if(!staticAudioPlayer)
        {
            staticAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            [staticAudioPlayer prepareToPlay];
        }
        
    }
    return self;
}

- (void) playAlertSound
{
    staticAudioPlayer.volume = 10;
    if(!staticAudioPlayer.play)
    [staticAudioPlayer play];
}

- (void) stopAlertSound
{
    staticAudioPlayer.currentTime = 0;
    [staticAudioPlayer stop];
}

- (void) pauseAlertSound
{
    [staticAudioPlayer pause];
}

#pragma mark AVAudioPlayerDelegate


@end
