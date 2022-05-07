//
//  YQLocationManager.h
//
//  Created by Apple on 2021/7/2.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YQLocationManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)shared;
- (void)startLocation;
- (void)stopLocation;

@property (nonatomic, copy) void (^sendCompletion)(CLLocationCoordinate2D coordinate, CLPlacemark *placemark);

@end

NS_ASSUME_NONNULL_END
