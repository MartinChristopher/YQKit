//
//  MJAudioFile.m
//  MJAudio
//
//  Created by Apple on 16/11/18.
//

#import "MJAudioFile.h"

@implementation MJAudioFile

// 录音文件保存路径（fileName 如：20180722.aac，或20180722.caf）
+ (NSString *)audioDefaultFilePath:(NSString *)fileName {
    NSString *fileNameTmp = fileName;
    if (!fileNameTmp || fileNameTmp.length <= 0) {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        // 文件名称（aac, caf）
        fileNameTmp = [dateFormatter stringFromDate:currentDate];
        fileNameTmp = [NSString stringWithFormat:@"%@.caf", fileNameTmp];
    }
    NSString *tempPath = NSTemporaryDirectory();
    NSString *filePath = [tempPath stringByAppendingFormat:@"/%@", fileNameTmp];
    return filePath;
}

// MP3文件路径（fileName 如：2015875.mp3）
+ (NSString *)audioMP3FilePath:(NSString *)fileName {
    NSString *fileNameTmp = fileName;
    if (!fileNameTmp || fileNameTmp.length <= 0) {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        // 文件名称（mp3）
        fileNameTmp = [dateFormatter stringFromDate:currentDate];
        fileNameTmp = [NSString stringWithFormat:@"%@.mp3", fileNameTmp];
    }
    NSString *mp3FilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if (![[NSFileManager defaultManager] fileExistsAtPath:mp3FilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:mp3FilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    mp3FilePath = [mp3FilePath stringByAppendingPathComponent:fileNameTmp];
    return mp3FilePath;
}

// 获取文件名（包含后缀，如：xxx.acc；不包含文件类型，如xxx）
+ (NSString *)audioGetFileNameWithFilePath:(NSString *)filePath type:(BOOL)hasFileType {
    NSString *fileName = [filePath stringByDeletingLastPathComponent];
    if (hasFileType) {
        fileName = [filePath lastPathComponent];
    }
    return fileName;
}

// 获取文件大小
+ (long long)audioGetFileSizeWithFilePath:(NSString *)filePath {
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist) {
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        long long fileSize = fileDict.fileSize;
        return fileSize;
    }
    return 0.0;
}

// 删除文件
+ (void)audioDeleteFileWithFilePath:(NSString *)filePath {
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
