//
//  YQLocationManager.m
//
//  Created by Apple on 2021/7/2.
//

#import "YQLocationManager.h"

@interface YQLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation YQLocationManager

+ (instancetype)shared {
    static YQLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startLocation {
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
        // 开启定位
        [self.locationManager startUpdatingLocation];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Authorization" message:@"[Location service] is not enabled. Please manually enable the location system Settings." preferredStyle:UIAlertControllerStyleAlert];
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
            [[YQLocationManager getCurrentVC] presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (void)stopLocation {
    // 结束定位
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Getters and setters

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        // 创建CoreLocation管理对象
        _locationManager = [[CLLocationManager alloc] init];
        // 定位权限检查
        [_locationManager requestWhenInUseAuthorization];
        // 设定定位精准度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
        // 设置代理
        _locationManager.delegate = self;
        
        _locationManager.distanceFilter = 5;
    }
    return _locationManager;
}

#pragma mark - <CLLocationManagerDelegate>
// 定位授权
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            NSLog(@"用户还未决定授权");
            // 主动获得授权
            [self.locationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            NSLog(@"访问受限");
            // 主动获得授权
            [self.locationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusDenied:{
            // 此时使用主动获取方法也不能申请定位权限
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            NSLog(@"获得前后台授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            NSLog(@"获得前台授权");
            break;
        }
        default:
            break;
    }
}
// 获取位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    // 判空处理
    if (newLocation.horizontalAccuracy < 0) {
        NSLog(@"定位失败，请检查手机网络以及定位");
        return;
    }
    //停止定位
    [self.locationManager stopUpdatingLocation];
    // 获取定位经纬度
    CLLocationCoordinate2D coor2D = newLocation.coordinate;
    NSLog(@"纬度 = %f, 经度 = %f", coor2D.latitude, coor2D.longitude);
    
    // 创建编码对象，获取所在城市
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    // 反地理编码
    __weak typeof(self) weakSelf = self;
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error != nil || placemarks.count == 0) {
            return ;
        }
        // 获取地标
        CLPlacemark *placeMark = [placemarks firstObject];
        NSLog(@"获取地标 = %@,", placeMark);
        if (strongSelf.sendCompletion) {
            strongSelf.sendCompletion(newLocation.coordinate, [NSString stringWithFormat:@"%@, %@", placeMark.administrativeArea, placeMark.locality]);
        }
    }];
}
// 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败，请检查手机网络以及定位");
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
