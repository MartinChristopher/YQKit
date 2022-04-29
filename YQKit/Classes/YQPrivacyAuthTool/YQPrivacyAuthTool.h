//
//  YQPrivacyAuthTool.h
//
//  Created by Apple on 2018/12/18.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AVPrivacyType) {
    AVPrivacyTypePhotos                = 0,    // 照片
    AVPrivacyTypeMicrophone               ,    // 麦克风
    AVPrivacyTypeCamera                   ,    // 相机
};

//对应类型权限状态，参考PHAuthorizationStatus等
typedef NS_ENUM(NSInteger, AVAuthStatus) {
    /** 用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权 */
    AVAuthStatusNotDetermined  = 0,
    /** 已授权 */
    AVAuthStatusAuthorized     = 1,
    /** 拒绝 */
    AVAuthStatusDenied         = 2,
    /** 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制 */
    AVAuthStatusRestricted     = 3,
    /** 硬件等不支持 */
    AVAutStatus_NotSupport      = 4,
};

//定位权限状态，参考CLAuthorizationStatus
typedef NS_ENUM(NSUInteger, AVLocationAuthStatus) {
    AVLocationAuthStatusNotDetermined         = 0, // 用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
    AVLocationAuthStatusAuthorized            = 1, // 一直允许获取定位 ps：< iOS8用
    AVLocationAuthStatusDenied                = 2, // 拒绝
    AVLocationAuthStatusRestricted            = 3, // 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制
    AVLocationAuthStatusNotSupport            = 4, // 硬件等不支持
    AVLocationAuthStatusAuthorizedAlways      = 5, // 一直允许获取定位
    AVLocationAuthStatusAuthorizedWhenInUse   = 6, // 在使用时允许获取定位
};

/**
 对应类型隐私权限状态回调block
 
 @param granted 是否授权
 @param status 授权的具体状态
 */
typedef void (^ResultBlock) (BOOL granted, AVAuthStatus status);

/**
 定位状态回调block
 
 @param status 授权的具体状态
 */
typedef void(^LocationResultBlock)(AVLocationAuthStatus status);

@interface YQPrivacyAuthTool : NSObject

+ (instancetype)shared;

@property (nonatomic, assign) AVPrivacyType PrivacyType;
@property (nonatomic, assign) AVAuthStatus AuthStatus;

/**
 检查和请求对应类型的隐私权限（定位、蓝牙不通过这个方法，单独调用）
 
 @param type 类型
 @param isPushSetting 当拒绝时是否跳转设置界面开启权限 (为NO时 只提示信息)
 @param block 对应类型状态回调
 */
- (void)checkPrivacyAuthWithType:(AVPrivacyType)type
                   isPushSetting:(BOOL)isPushSetting
                           block:(ResultBlock)block;

/**
 检查和请求 定位权限
 
 @param isPushSetting 当拒绝时是否跳转设置界面开启权限 (为NO时 只提示信息)
 @param block 定位状态回调
 */
- (void)checkLocationAuth:(BOOL)isPushSetting
                    block:(LocationResultBlock)block;

/**
 检测通知权限状态
 
 @param isPushSetting 当拒绝时是否跳转设置界面开启权限 (为NO时 只提示信息)
 @param block 回调
 */
- (void)checkNotificationAuth:(BOOL)isPushSetting
                        block:(ResultBlock)block;

/** 注册通知  */
+ (void)requestNotificationAuth;

@end

NS_ASSUME_NONNULL_END

/**
 Info.plist 隐私权限配置
 
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>APP需要您的同意，才能在使用时获取位置信息，以便于搜索附近的xxx位置</string>
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>App需要您的同意，才能访问位置信息，以便于搜索附近的xxx位置</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>App需要您的同意，才能始终访问位置信息，以便于搜索附近的xxx位置</string>
 <key>NSLocationUsageDescription</key>
 <string>APP需要您的同意，才能访问位置信息，以便于搜索附近的xxx位置</string>
 <key>NSContactsUsageDescription</key>
 <string>APP需要您的同意，才能访问通讯录 (通讯录信息仅用于查找联系人，并会得到严格保密)</string>
 <key>NSCalendarsUsageDescription</key>
 <string>APP需要您的同意，才能访问日历，以便于获取更好的使用体验</string>
 <key>NSRemindersUsageDescription</key>
 <string>APP需要您的同意，才能访问提醒事项，以便于获取更好的使用体验</string>
 <key>NSPhotoLibraryUsageDescription</key>
 <string>APP需要您的同意，才能访问相册，以便于图片选取、上传、发布</string>
 <key>NSPhotoLibraryAddUsageDescription</key>
 <string>APP需要您的同意，才能访问相册，以便于保存图片</string>
 <key>NSBluetoothPeripheralUsageDescription</key>
 <string>APP需要您的同意，才能使用蓝牙</string>
 <key>NSBluetoothAlwaysUsageDescription</key>
 <string>APP需要您的同意，才能始终使用蓝牙</string>
 <key>NSLocalNetworkUsageDescription</key>
 <string>App不会连接到您所用网络上的设备，只会检测与您本地网关的连通性。用户也可以在 iOS 设备的设置-隐私-本地网络界面修改此App的权限设置。</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>APP需要您的同意，才能使用麦克风，以便于视频录制、语音识别、语音聊天</string>
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>APP需要您的同意，才能进行语音识别，以便于获取更好的使用体验</string>
 <key>NSCameraUsageDescription</key>
 <string>APP需要您的同意，才能使用摄像头，以便于相机拍摄，上传、发布照片</string>
 
 <key>NSFaceIDUsageDescription</key>
 <string>APP需要您的同意，才能获取人脸识别权限</string>
 <key>NSSiriUsageDescription</key>
 <string>APP需要您的同意，才能获取Siri使用权限</string>
 
 <key>NSHealthClinicalHealthRecordsShareUsageDescription</key>
 <string>APP需要您的同意，才能获取健康记录权限</string>
 <key>NSHealthShareUsageDescription</key>
 <string>APP需要您的同意，才能获取健康分享权限</string>
 <key>NSHealthUpdateUsageDescription</key>
 <string>APP需要您的同意，才能获取健康更新权限</string>
 <key>NSHomeKitUsageDescription</key>
 <string>APP需要您的同意，才能获取HomeKit权限</string>
 <key>NSMotionUsageDescription</key>
 <string>APP需要您的同意，才能获取运动与健身权限</string>
 <key>kTCCServiceMediaLibrary</key>
 <string>APP需要您的同意，才能获取音乐权限</string>
 <key>NSAppleMusicUsageDescription</key>
 <string>APP需要您的同意，才能获取媒体库权限权限</string>
 <key>NSVideoSubscriberAccountUsageDescription</key>
 <string>APP需要您的同意，才能获取AppleTV使用权限</string>
 
 */
