//
//  YQPrivacyAuthTool.m
//
//  Created by Apple on 2018/12/18.
//

#import "YQPrivacyAuthTool.h"
#import <CoreLocation/CoreLocation.h>            //定位
#import <CoreLocation/CLLocationManager.h>
#import <AVFoundation/AVFoundation.h>            //相机/麦克风
#import <Photos/Photos.h>                        //相册
#import <UserNotifications/UserNotifications.h>  //通知

@interface YQPrivacyAuthTool () <UNUserNotificationCenterDelegate, CLLocationManagerDelegate>
//隐私权限状态回调block
@property (nonatomic,   copy) ResultBlock block;
//定位
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSOperationQueue *motionActivityQueue;
//定位状态回调block
@property (nonatomic,   copy) LocationResultBlock locationResultBlock;
@property (nonatomic,   copy) void (^CLCallBackBlock)(CLAuthorizationStatus state);
//提示
@property (nonatomic, strong) NSString *tipStr;

@end

@implementation YQPrivacyAuthTool

static YQPrivacyAuthTool *tool = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!tool) {
            tool = [[YQPrivacyAuthTool alloc] init];
        }
    });
    return tool;
}

/**
 获取权限
 
 @param type 类型
 @param isPushSetting 是否跳转设置界面开启权限 (为NO时 只提示信息)
 @param block 回调
 */
- (void)checkPrivacyAuthWithType:(AVPrivacyType)type isPushSetting:(BOOL)isPushSetting block:(ResultBlock)block {
    self.block = block;
    switch (type) {
        case AVPrivacyTypePhotos:
        {   // 相册
            _tipStr = @"Turn on the iPhone's Settings - Privacy - Albums option";
            [self Auth_Photos:isPushSetting];
        }
            break;
        case AVPrivacyTypeMicrophone:
        {   // 麦克风
            _tipStr = @"Turn on the iPhone's Settings - Privacy - Microphone option";
            [self Auth_Microphone:isPushSetting];
        }
            break;
        case AVPrivacyTypeCamera:
        {   // 相机
            _tipStr = @"Turn on the iPhone's Settings - Privacy - Camera option";
            [self Auth_Camera:isPushSetting];
        }
            break;
        default:
            break;
    }
}

#pragma mark - <相册权限>

- (void)Auth_Photos:(BOOL)isPushSetting {
    __weak typeof(self) weakSelf = self;
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined:
        {   //第一次进来
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    weakSelf.block(YES, AVAuthStatusAuthorized);
                } else {
                    weakSelf.block(NO, AVAuthStatusDenied);
                    [self pushSetting:isPushSetting]; //拒绝时跳转或提示
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        {    //未授权，家长限制
            weakSelf.block(NO, AVAuthStatusRestricted);
            [self pushSetting:isPushSetting]; //拒绝时跳转或提示
        }
            break;
        case PHAuthorizationStatusDenied:
        {   //拒绝
            weakSelf.block(NO, AVAuthStatusDenied);
            [self pushSetting:isPushSetting]; //拒绝时跳转或提示
        }
            break;
        case PHAuthorizationStatusAuthorized:
        {   //已授权
            weakSelf.block(YES, AVAuthStatusAuthorized);
        }
            break;
        default:
            break;
    }
}

#pragma mark - <麦克风权限>

- (void)Auth_Microphone:(BOOL)isPushSetting {
    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {   //第一次进来
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted == YES) {
                    weakSelf.block(YES, AVAuthStatusAuthorized);
                } else {
                    weakSelf.block(NO, AVAuthStatusDenied);
                    [self pushSetting:isPushSetting]; //拒绝时跳转或提示
                }
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        {   //未授权，家长限制
            weakSelf.block(NO, AVAuthStatusRestricted);
            [self pushSetting:isPushSetting]; //拒绝时跳转或提示
        }
            break;
        case AVAuthorizationStatusDenied:
        {   //拒绝
            weakSelf.block(NO, AVAuthStatusDenied);
            [self pushSetting:isPushSetting]; //拒绝时跳转或提示
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {   //已授权
            weakSelf.block(YES, AVAuthStatusAuthorized);
        }
            break;
        default:
            break;
    }
}

#pragma mark - <相机权限>

- (void)Auth_Camera:(BOOL)isPushSetting {
    __weak typeof(self) weakSelf = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusNotDetermined:
            {   //第一次进来
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted == YES) {
                        weakSelf.block(YES, AVAuthStatusAuthorized);
                    } else {
                        weakSelf.block(NO, AVAuthStatusDenied);
                        [self pushSetting:isPushSetting]; //拒绝时跳转或提示
                    }
                }];
            }
                break;
            case AVAuthorizationStatusRestricted:
            {   //未授权，家长限制
                weakSelf.block(NO, AVAuthStatusRestricted);
                [self pushSetting:isPushSetting]; //拒绝时跳转或提示
            }
                break;
            case AVAuthorizationStatusDenied:
            {   //拒绝
                weakSelf.block(NO, AVAuthStatusDenied);
                [self pushSetting:isPushSetting]; //拒绝时跳转或提示
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {   //已授权
                weakSelf.block(YES, AVAuthStatusAuthorized);
            }
                break;
            default:
                break;
        }
    } else {
        //硬件不支持
        weakSelf.block(NO, AVAutStatus_NotSupport);
        NSLog(@" 硬件不支持 ");
        //         [JhProgressHUD showText:@"硬件不支持"];
    }
}

#pragma mark - <定位权限>

- (void)checkLocationAuth:(BOOL)isPushSetting block:(LocationResultBlock)block {
    self.locationResultBlock = block;
    __weak typeof(self) weakSelf = self;
    BOOL isLocationServicesEnabled = [CLLocationManager locationServicesEnabled];
    if (!isLocationServicesEnabled) {
        NSLog(@"定位服务不可用，例如定位没有打开...");
        weakSelf.locationResultBlock(AVLocationAuthStatusNotSupport);
        //        [JhProgressHUD showText:@"定位服务不可用"];
    } else {
        _tipStr = @"Turn on the iPhone's Settings - Privacy - Location Services option";
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        switch (authStatus) {
            case kCLAuthorizationStatusNotDetermined:
            {   //第一次进来
                self.locationManager = [[CLLocationManager alloc] init];
                self.locationManager.delegate = self;
                // 两种定位模式：
                [self.locationManager requestAlwaysAuthorization];
                [self.locationManager requestWhenInUseAuthorization];
                [self setCLCallBackBlock:^(CLAuthorizationStatus state){
                    if (authStatus == kCLAuthorizationStatusNotDetermined) {
                        weakSelf.locationResultBlock(AVLocationAuthStatusNotDetermined);
                    }else if (authStatus == kCLAuthorizationStatusRestricted) {
                        //未授权，家长限制
                        weakSelf.locationResultBlock(AVLocationAuthStatusRestricted);
                        [weakSelf pushSetting:isPushSetting]; //拒绝时跳转或提示
                    }else if (authStatus == kCLAuthorizationStatusDenied) {
                        //拒绝
                        weakSelf.locationResultBlock(AVLocationAuthStatusDenied);
                        [weakSelf pushSetting:isPushSetting]; //拒绝时跳转或提示
                    }else if (authStatus == kCLAuthorizationStatusAuthorizedAlways) {
                        //总是
                        weakSelf.locationResultBlock(AVLocationAuthStatusAuthorizedAlways);
                    }else if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                        //使用期间
                        weakSelf.locationResultBlock(AVLocationAuthStatusAuthorizedWhenInUse);
                    }
                }];
            }
                break;
            case kCLAuthorizationStatusRestricted:
            {   //未授权，家长限制
                weakSelf.locationResultBlock(AVLocationAuthStatusRestricted);
                [self pushSetting:isPushSetting]; //拒绝时跳转或提示
            }
                break;
            case kCLAuthorizationStatusDenied:
            {   //拒绝
                [self pushSetting:isPushSetting]; //拒绝时跳转或提示
                weakSelf.locationResultBlock(AVLocationAuthStatusDenied);
            }
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            {   //总是
                weakSelf.locationResultBlock(AVLocationAuthStatusAuthorizedAlways);
            }
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            {   //使用期间
                weakSelf.locationResultBlock(AVLocationAuthStatusAuthorizedWhenInUse);
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.CLCallBackBlock) {
        self.CLCallBackBlock(status);
    }
}

#pragma mark - <通知权限>

- (void)checkNotificationAuth:(BOOL)isPushSetting block:(ResultBlock)block {
    self.block = block;
    __weak typeof(self) weakSelf = self;
    _tipStr = @"Please enable notification rights in the Settings - Notifications - option on the iPhone";
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        //已授权
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            weakSelf.block(YES, AVAuthStatusAuthorized);
        } else {
            weakSelf.block(NO, AVAuthStatusDenied);
            [self pushSetting:isPushSetting];
        }
    }];
}

#pragma mark - <注册通知>

+ (void)requestNotificationAuth {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //必须写代理，不然无法监听通知的接收与点击事件
    center.delegate = (id)self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error && granted) {
            //用户点击允许
//            NSLog(@"注册通知成功");
        } else {
            //用户点击不允许
//            NSLog(@"注册通知失败");
        }
    }];
    // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
    //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//        NSLog(@"========%@",settings);
    }];
}

#pragma mark - <跳转设置>

- (void)pushSetting:(BOOL)isPushSetting {
    if (isPushSetting == YES) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Authorization" message:[NSString stringWithFormat:@"%@",_tipStr] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication]openURL:url options:@{}completionHandler:^(BOOL success) {
                }];
            }
        }];
        [alert addAction:okAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[YQPrivacyAuthTool getCurrentVC] presentViewController:alert animated:YES completion:nil];
        });
        
    } else {
        NSLog(@" 可以添加弹框,弹框的提示信息: %@ ",_tipStr);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Authorization" message:[NSString stringWithFormat:@"%@",_tipStr] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:cancelAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[YQPrivacyAuthTool getCurrentVC] presentViewController:alert animated:YES completion:nil];
        });
    }
}

#pragma mark - <获取当前VC>

+ (UIViewController *)getCurrentVC {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

@end
