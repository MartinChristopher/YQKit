//
//  YQActionSheet.h
//  YQActionSheet
//
//  Created by Apple on 2021/7/2.
//

#import <UIKit/UIKit.h>

typedef void(^xmActionHandler)(NSUInteger index);

@interface YQActionSheet : NSObject

/**
 *  底部ActionSheet
 *
 *  @param actionTitle      按钮标题，数组
 *  @param actionHandler    按钮响应事件
 */
+ (void)YQ_actionSheetWithActionTitles:(NSArray *)actionTitle
                          actionHander:(xmActionHandler)actionHandler;

@end

