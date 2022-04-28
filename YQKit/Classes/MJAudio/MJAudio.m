//
//  MJAudio.m
//  MJAudio
//
//  Created by Apple on 13/11/7.
//

#import "MJAudio.h"

@interface MJAudio ()

@end

@implementation MJAudio

static MJAudio *audio;
+ (MJAudio *)shared {
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

- (MJAudioRecord *)recorder {
    if (!_recorder) {
        _recorder = [[MJAudioRecord alloc] init];
    }
    return _recorder;
}

@end
