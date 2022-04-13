//
//  YQAudio.m
//  YQAudio
//
//  Created by Apple on 13/11/7.
//

#import "YQAudio.h"

@interface YQAudio ()

@end

@implementation YQAudio

#pragma mark - 初始化

+ (YQAudio *)shared {
    static YQAudio *audio;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        audio = [[self alloc] init];
    });
    return audio;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%@ 已释放", self);
}

#pragma mark - setter

- (YQAudioPlay *)player {
    if (!_player) {
        _player = [[YQAudioPlay alloc] init];
    }
    return _player;
}

@end
