//
//  YQFlowLayoutProtocol.h
//
//  Created by xuyefeng on 17/5/17.
//

#import <Foundation/Foundation.h>
#import "YQFlowLayoutMacro.h"

@protocol YQFlowLayoutProtocol <NSObject>
/**
 配置布局

 @param itemEdgeInsets 左上角第一个item 距离四周的距离
 @param sectionEdgeInsets item所属的组section 距离四周的距离
 */
- (void)configFlowLayoutWithFlowLayoutItemEdgeInsets:(FlowLayoutItemEdgeInsets)itemEdgeInsets
                                   sectionEdgeInsets:(FlowLayoutSectionEdgeInsets)sectionEdgeInsets;
@end
