//
//  YQUploadModel.h
//
//  Created by Apple on 2021/9/23.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//上传数据类型
typedef NS_ENUM(NSInteger, YQUploadType) {
    YQUploadTypeTxt, //文本
    YQUploadTypeImage, //图片
    YQUploadTypeVideo, //视频
};

NS_ASSUME_NONNULL_BEGIN

@interface YQUploadModel : NSObject
/// 文件在表单中的key
@property (nonatomic, copy) NSString *keyName;
/// 上传数据类型
@property (nonatomic, assign) YQUploadType type;
/// 上传数据
@property (nonatomic, strong) NSData * data;
/// 上传图片 (上传图片时可赋值image也可赋值data)
@property (nonnull, strong) UIImage * image;

- (instancetype)initWithType:(YQUploadType)type;

@end

NS_ASSUME_NONNULL_END
