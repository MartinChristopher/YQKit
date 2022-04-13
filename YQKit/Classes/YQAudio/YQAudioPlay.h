//
//  YQAudioPlay.h
//  YQAudio
//
//  Created by Apple on 16/11/18.
//

#import <Foundation/Foundation.h>
#import "YQAudioProtocol.h"

@interface YQAudioPlay : NSObject

@property (nonatomic, weak) id<YQAudioDelegate> delegate;

- (void)playerStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete;

- (void)playerStart;

- (void)playerPause;

- (void)playerStop;

@end
