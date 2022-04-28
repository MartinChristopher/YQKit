//
//  MJAudio.h
//  MJAudio
//
//  Created by Apple on 13/11/7.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "MJAudioFile.h"
#import "MJAudioTimer.h"

#import "MJAudioRecord.h"

#pragma mark - 录音功能

@interface MJAudio : NSObject

+ (MJAudio *)shared;

@property (nonatomic, strong) MJAudioRecord *recorder;

@end
