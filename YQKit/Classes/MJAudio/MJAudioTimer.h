//
//  MJAudioTimer.h
//  MJAudio
//
//  Created by Apple on 16/11/18.
//

#import <Foundation/Foundation.h>

@interface MJAudioTimer : NSObject

NSTimer *MJAudioTimerInitialize(NSTimeInterval timeElapsed, id userInfo, BOOL isRepeat, id target, SEL action);

void MJAudioTimerStart(NSTimer *timer);

void MJAudioTimerStop(NSTimer *timer);

void MJAudioTimerKill(NSTimer *timer);

@end
