//
//  YQAudioPlay.m
//  YQAudio
//
//  Created by Apple on 16/11/18.
//

#import "YQAudioPlay.h"
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface YQAudioPlay ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL hasObserver;

@end

@implementation YQAudioPlay

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
    NSLog(@"%@ 已释放", self);
}

- (void)playerStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete {
    if (!filePath || filePath.length <= 0) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    
    // 移除监听
    [self removeObserver];

    // 设置播放的url
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([filePath hasPrefix:@"http://"] || [filePath hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:filePath];
    }
    // 设置播放的项目
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    // 添加监听
    [self addObserver];
}

- (void)playerStart {
    [self.player play];
}

- (void)playerPause {
    [self.player pause];
}

- (void)playerStop {
    
}

#pragma mark - getter

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

#pragma mark - 监听

- (void)addObserver {
    if (!self.hasObserver) {
        self.hasObserver = YES;
        
        // KVO
        // KVO来观察status属性的变化
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        // KVO监测加载情况
        [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        //
        YQAudioPlay __weak *weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioPlaying:time:)]) {
                [weakSelf.delegate audioPlaying:CMTimeGetSeconds(weakSelf.player.currentItem.duration) time:CMTimeGetSeconds(time)];
            }
        }];
        
        // 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
}

- (void)removeObserver {
    if (self.hasObserver) {
        self.hasObserver = NO;
        
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        // 取出status的新值
        AVPlayerItem *item = (AVPlayerItem *)object;
        switch (item.status) {
            case AVPlayerItemStatusFailed: {
                NSLog(@"播放失败");
                if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined:)]) {
                    [self.delegate audioPlayBegined:AVPlayerItemStatusFailed];
                }
            } break;
            case AVPlayerItemStatusReadyToPlay: {
                NSLog(@"准备播放");
                [self.player play];
                if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined:)]) {
                    [self.delegate audioPlayBegined:AVPlayerItemStatusReadyToPlay];
                }
            } break;
            case AVPlayerItemStatusUnknown: {
                NSLog(@"未知错误");
                if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined:)]) {
                    [self.delegate audioPlayBegined:AVPlayerItemStatusUnknown];
                }
            } break;
            default: break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = self.player.currentItem.loadedTimeRanges;
        // 本次缓冲的时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        // 缓冲总长度
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        // 音乐的总时间
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        // 计算缓冲百分比例
        NSTimeInterval scale = totalBuffer / duration;
        //
        NSLog(@"总时长：%.2f, 已缓冲：%.2f, 总进度：%.2f", duration, totalBuffer, scale);
    }
}

- (void)playFinish {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayFinished)]) {
        [self.delegate audioPlayFinished];
    }
}

@end
