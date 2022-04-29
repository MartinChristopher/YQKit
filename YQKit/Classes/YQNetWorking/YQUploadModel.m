//
//  YQUploadModel.m
//
//  Created by Apple on 2021/9/23.
//

#import "YQUploadModel.h"

@implementation YQUploadModel

- (instancetype)initWithType:(YQUploadType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

@end
