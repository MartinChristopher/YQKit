//
//  MJAudioProtocol.h
//  MJAudio
//
//  Created by Apple on 16/11/18.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MJAudioDelegate <NSObject>

@optional
// 开始录音
- (void)recordBegined;
// 停止录音
- (void)recordFinshed;
// 正在录音中，录音音量监测
- (void)recordingUpdateVoice:(double)metering;
// 正中录音中，是否录音倒计时、录音剩余时长
- (void)recordingWithResidualTime:(NSTimeInterval)time timer:(BOOL)isTimer;

// 开始压缩录音
- (void)recordBeginConvert;
// 结束压缩录音
- (void)recordFinshConvert:(NSString *)filePath;

@end
