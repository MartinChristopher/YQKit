//
//  YQButton.h
//  YQActionSheet
//
//  Created by Apple on 2021/7/2.
//

#import <UIKit/UIKit.h>

typedef void (^ClickActionBlock) (id obj);

@interface YQButton : UIButton

@property (nonatomic,strong) ClickActionBlock caBlock;

- (void)initWithBlock:(ClickActionBlock)clickBlock for:(UIControlEvents)event;

@end
