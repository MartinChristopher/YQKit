//
//  AVAudioRecord.m
//  AVAudio
//
//  Created by Apple on 16/11/18.
//

#import "MJAudioRecord.h"
#import <UIKit/UIKit.h>

#import "lame.h"
#import "MJAudioFile.h"
#import "MJAudioTimer.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface MJAudioRecord () <AVAudioRecorderDelegate>

@property (nonatomic, strong) NSMutableDictionary *recorderDict; // 录音设置
@property (nonatomic, strong) AVAudioRecorder *recorder; // 录音
@property (nonatomic, strong) NSString *recorderFilePath;

@property (nonatomic, strong) NSTimer *voiceTimer; // 录音音量计时器

@property (nonatomic, strong) NSTimer *timecountTimer; // 录音倒计时计时器
@property (nonatomic, assign) NSTimeInterval timecountTime; // 录音倒计时时间

@property (nonatomic, strong) UIView *hudView;        // 录音音量图像父视图
@property (nonatomic, strong) UIImageView *voiceView; // 录音音量图像

@end

@implementation MJAudioRecord

- (instancetype)init {
    self = [super init];
    if (self) {
        self.monitorVoice = NO;
    }
    return self;
}

- (void)dealloc {
    [self recorderStop];
    [self stopVoiceTimer];
    [self stopTimecountTimer];
    
    if (self.recorderDict) {
        self.recorderDict = nil;
    }
    
    if (self.recorder) {
        self.recorder.delegate = nil;
        self.recorder = nil;
    }
}

#pragma mark - getter

- (NSMutableDictionary *)recorderDict {
    if (!_recorderDict) {
        // 参数设置 格式、采样率、录音通道、线性采样位数、录音质量
        _recorderDict = [NSMutableDictionary dictionary];
        // kAudioFormatMPEG4AAC ：xxx.acc；kAudioFormatLinearPCM ：xxx.caf
        [_recorderDict setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [_recorderDict setValue:[NSNumber numberWithInt:16000] forKey:AVSampleRateKey];
        [_recorderDict setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [_recorderDict setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [_recorderDict setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    }
    return _recorderDict;
}

#pragma mark - 录音
// 开始录音
- (void)recorderStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete {
    if (!filePath || filePath.length <= 0) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    
    // 强转音频格式为xx.caf
    BOOL isCaf = [filePath hasSuffix:@".caf"];
    if (isCaf) {
        self.recorderFilePath = filePath;
    } else {
        NSRange range = [filePath rangeOfString:@"." options:NSBackwardsSearch];
        NSString *filePathTmp = [filePath substringToIndex:(range.location + range.length)];
        self.recorderFilePath = [NSString stringWithFormat:@"%@caf", filePathTmp];
    }
    
    // 生成录音文件
    NSURL *urlAudioRecorder = [NSURL fileURLWithPath:filePath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:urlAudioRecorder settings:self.recorderDict error:nil];
    
    // 开启音量检测
    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    
    if (self.recorder) {
        // 录音时设置audioSession属性，否则不兼容Ios7
        AVAudioSession *recordSession = [AVAudioSession sharedInstance];
        [recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [recordSession setActive:YES error:nil];
        
        if ([self.recorder prepareToRecord])
        {
            [self.recorder record];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordBegined)]) {
                [self.delegate recordBegined];
                
                if (self.monitorVoice) {
                    // 录音音量显示 75*111
                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                    //
                    self.hudView = [[UIView alloc] initWithFrame:CGRectMake((window.frame.size.width - 120) / 2, (window.frame.size.height - 120) / 2, 120, 120)];
                    [window addSubview:self.hudView];
                    [self.hudView.layer setCornerRadius:10.0];
                    [self.hudView.layer setBackgroundColor:[UIColor blackColor].CGColor];
                    [self.hudView setAlpha:0.8];
                    //
                    self.voiceView = [[UIImageView alloc] initWithFrame:CGRectMake((self.hudView.frame.size.width - 60) / 2, (self.hudView.frame.size.height - 60 * 111 / 75) / 2, 60, 60 * 111 / 75)];
                    [self.hudView addSubview:self.voiceView];
                    [self.voiceView setImage:[UIImage imageNamed:@"record_01.png"]];
                    [self.voiceView setBackgroundColor:[UIColor clearColor]];
                }
            }
            
            [self startVoiceTimer];
            [self startTimecountTimer];
        }
    }
}
// 停止录音
- (void)recorderStop {
    if (self.recorder) {
        if ([self.recorder isRecording])
        {
            [self.recorder stop];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshed)]) {
                [self.delegate recordFinshed];
                
                // 移除音量图标
                if (self.voiceView && self.monitorVoice)
                {
                    [self.voiceView setHidden:YES];
                    [self.voiceView setImage:nil];
                    [self.voiceView removeFromSuperview];
                    self.voiceView = nil;
                    
                    [self.hudView removeFromSuperview];
                    self.hudView = nil;
                }
            }
            
            NSLog(@"File size = %lld", [MJAudioFile audioGetFileSizeWithFilePath:self.recorderFilePath]);
            
            [self audioConvertMP3];
            
            // 停止录音后释放掉
            self.recorder.delegate = nil;
            self.recorder = nil;
        }
    }
    
    [self stopVoiceTimer];
    [self stopTimecountTimer];
}
// 异常时停止
- (void)recorderStopWhileError {
    if (self.recorder) {
        if ([self.recorder isRecording])
        {
            [self.recorder stop];
            
            [self.recorder deleteRecording];
            
            // 停止录音后释放掉
            self.recorder.delegate = nil;
            self.recorder = nil;
        }
    }
    
    [self stopVoiceTimer];
    [self stopTimecountTimer];
}
// 录音时长
- (NSTimeInterval)recorderDurationWithFilePath:(NSString *)filePath {
    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFile error:nil];
    NSTimeInterval time = audioPlayer.duration;
    audioPlayer = nil;
    return time;
}

#pragma mark 录音计时器

- (void)startVoiceTimer {
    if (self.monitorVoice) {
        self.voiceTimer = MJAudioTimerInitialize(0.0, nil, YES, self, @selector(detectionVoice));
        MJAudioTimerStart(self.voiceTimer);
        NSLog(@"开始检测音量");
    }
}

- (void)stopVoiceTimer {
    if (self.voiceTimer) {
        MJAudioTimerStop(self.voiceTimer);
        MJAudioTimerKill(self.voiceTimer);
        NSLog(@"停止检测音量");
    }
}
// 录音音量显示
- (void)detectionVoice {
    // 刷新音量数据
    [self.recorder updateMeters];
    
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingUpdateVoice:)]) {
        [self.delegate recordingUpdateVoice:lowPassResults];
        
        if (0 < lowPassResults <= 0.06)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_01.png"]];
        }
        else if (0.06 < lowPassResults <= 0.13)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_02.png"]];
        }
        else if (0.13 < lowPassResults <= 0.20)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_03.png"]];
        }
        else if (0.20 < lowPassResults <= 0.27)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_04.png"]];
        }
        else if (0.27 < lowPassResults <= 0.34)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_05.png"]];
        }
        else if (0.34 < lowPassResults <= 0.41)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_06.png"]];
        }
        else if (0.41 < lowPassResults <= 0.48)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_07.png"]];
        }
        else if (0.48 < lowPassResults <= 0.55)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_08.png"]];
        }
        else if (0.55 < lowPassResults <= 0.62)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_09.png"]];
        }
        else if (0.62 < lowPassResults <= 0.69)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_10.png"]];
        }
        else if (0.69 < lowPassResults <= 0.76)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_11.png"]];
        }
        else if (0.76 < lowPassResults <= 0.83)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_12.png"]];
        }
        else if (0.83 < lowPassResults <= 0.9)
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_13.png"]];
        }
        else
        {
            [self.voiceView setImage:[UIImage imageNamed:@"record_14.png"]];
        }
    }
    
    NSLog(@"voice: %f", lowPassResults);
}

#pragma mark 倒计时计时器

- (void)startTimecountTimer {
    if (self.totalTime <= 0.0) {
        return;
    }
    
    self.timecountTime = -1.0;
    self.timecountTimer = MJAudioTimerInitialize(1.0, nil, YES, self, @selector(detectionTime));
    MJAudioTimerStart(self.timecountTimer);
    NSLog(@"开始录音倒计时");
}

- (void)stopTimecountTimer {
    if (self.timecountTimer) {
        self.totalTime = 0.0;
        MJAudioTimerStop(self.timecountTimer);
        MJAudioTimerKill(self.timecountTimer);
        NSLog(@"停止录音倒计时");
    }
}

- (void)detectionTime {
    self.timecountTime += 1.0;
    NSTimeInterval time = (self.totalTime - self.timecountTime);
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingWithResidualTime:timer:)]) {
        [self.delegate recordingWithResidualTime:time timer:(self.totalTime > 0.0 ? YES : NO)];
    }
    
    if (time <= 0.0 && self.totalTime > 0.0) {
        [self recorderStop];
    }
}

#pragma mark - 文件压缩

- (void)audioConvertMP3 {
    NSString *cafFilePath = self.recorderFilePath;
    NSString *mp3FilePath = [MJAudioFile audioMP3FilePath:self.filePathMP3];
    
    NSLog(@"MP3转换开始");
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordBeginConvert)]) {
        [self.delegate recordBeginConvert];
    }
    
    @try {
        int read;
        int write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4 * 1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 16000); // 采样率不对，编出来的声音完全不对
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
        mp3FilePath = nil;
    } @finally {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        NSLog(@"MP3转换结束");
        NSLog(@"File size = %lld", [MJAudioFile audioGetFileSizeWithFilePath:mp3FilePath]);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshConvert:)]) {
            [self.delegate recordFinshConvert:mp3FilePath];
        }
    }
}

#pragma mark - 代理

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self recorderStop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshed)]) {
        [self.delegate recordFinshed];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    [self recorderStopWhileError];
}

@end
