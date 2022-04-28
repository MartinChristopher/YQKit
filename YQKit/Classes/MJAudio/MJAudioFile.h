//
//  MJAudioFile.h
//  MJAudio
//
//  Created by Apple on 16/11/18.
//

#import <Foundation/Foundation.h>

@interface MJAudioFile : NSObject

// 录音文件保存路径（fileName 如：20180722.aac）
+ (NSString *)audioDefaultFilePath:(NSString *)fileName;

// MP3文件路径（fileName 如：2015875.mp3）
+ (NSString *)audioMP3FilePath:(NSString *)fileName;

// 获取文件名（包含后缀，如：xxx.acc；不包含文件类型，如xxx）
+ (NSString *)audioGetFileNameWithFilePath:(NSString *)filePath type:(BOOL)hasFileType;

// 获取文件大小
+ (long long)audioGetFileSizeWithFilePath:(NSString *)filePath;

// 删除文件
+ (void)audioDeleteFileWithFilePath:(NSString *)filePath;

@end
