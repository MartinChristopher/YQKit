//
//  YQFlowLayout.m
//
//  Created by xuyefeng on 17/5/20.
//

#import "YQFlowLayout.h"
#import "LeftAlignedFlowLayout.h"
#import "RightAlignedFlowLayout.h"

@implementation YQFlowLayout

+ (UICollectionViewFlowLayout *)flowLayoutWithFlowLayoutType:(FlowLayoutType)flowLayoutType {
    UICollectionViewFlowLayout <YQFlowLayoutProtocol> *  flowLayout = nil;
    flowLayout = [self flowLayoutWithFlowLayoutType:flowLayoutType
                                     ItemEdgeInsets:(FlowLayoutItemEdgeInsets){20,10,20,20}
                                  sectionEdgeInsets:(FlowLayoutSectionEdgeInsets){20,10,20,10}];
    
    return flowLayout;
}

+ (UICollectionViewFlowLayout<YQFlowLayoutProtocol> *)flowLayoutWithFlowLayoutType:(FlowLayoutType)flowLayoutType
                                                                    ItemEdgeInsets:(FlowLayoutItemEdgeInsets)itemEdgeInsets
                                                                 sectionEdgeInsets:(FlowLayoutSectionEdgeInsets)sectionEdgeInsets {
    UICollectionViewFlowLayout <YQFlowLayoutProtocol> *  flowLayout = nil;
    if (flowLayoutType == FlowLayoutType_leftAlign) {
        flowLayout =  [LeftAlignedFlowLayout new];
    } else if (flowLayoutType == FlowLayoutType_rightAlign) {
        flowLayout =  [RightAlignedFlowLayout new];
    }
    [flowLayout configFlowLayoutWithFlowLayoutItemEdgeInsets:itemEdgeInsets
                                           sectionEdgeInsets:sectionEdgeInsets];
    
    return flowLayout;
}

@end
