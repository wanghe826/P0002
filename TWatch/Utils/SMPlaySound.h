//
//  SMPlaySound.h
//  Common
//
//  Created by QFITS－iOS on 16/1/15.
//  Copyright © 2016年 Smartmovt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

static AVAudioPlayer* staticAudioPlayer;

@interface SMPlaySound : NSObject
{
    AVAudioSession* _audioSession;
}

- (void) playAlertSound;

@end
