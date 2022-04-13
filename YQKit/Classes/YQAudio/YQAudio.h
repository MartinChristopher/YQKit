//
//  YQAudio.h
//  YQAudio
//
//  Created by Apple on 13/11/7.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "YQAudioPlay.h"

#pragma mark - 录音功能

@interface YQAudio : NSObject

+ (YQAudio *)shared;

@property (nonatomic, strong) YQAudioPlay *player;

@end
