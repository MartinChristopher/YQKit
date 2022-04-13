//
//  YQAudioProtocol.h
//  YQAudio
//
//  Created by Apple on 16/11/18.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol YQAudioDelegate <NSObject>

@optional
/// 开始播放音频
- (void)audioPlayBegined:(AVPlayerItemStatus)state;
/// 正在播放音频
- (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime;
/// 结束播放音频
- (void)audioPlayFinished;

@end
