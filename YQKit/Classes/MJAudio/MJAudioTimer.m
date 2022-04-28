//
//  MJAudioTimer.m
//  MJAudio
//
//  Created by Apple on 16/11/18.
//

#import "MJAudioTimer.h"

@implementation MJAudioTimer

NSTimer *MJAudioTimerInitialize(NSTimeInterval timeElapsed, id userInfo, BOOL isRepeat, id target, SEL action) {
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeElapsed target:target selector:action userInfo:userInfo repeats:isRepeat];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer setFireDate:[NSDate distantFuture]];
    return timer;
}

void MJAudioTimerStart(NSTimer *timer) {
    [timer setFireDate:[NSDate distantPast]];
}

void MJAudioTimerStop(NSTimer *timer) {
    [timer setFireDate:[NSDate distantFuture]];
}

void MJAudioTimerKill(NSTimer *timer) {
    if ([timer isValid]) {
        [timer invalidate];
    }
    timer = nil;
}

@end
