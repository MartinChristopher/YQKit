//
//  Attribute.h
//
//  Created by zhoufei on 2017/5/19.
//

#import <Foundation/Foundation.h>

@interface Attribute : NSObject

@property (assign, nonatomic) int   index;
@property (assign, nonatomic) float width;

+ (instancetype)AttributeWithIndex:(int)index width:(float)width;

@end
