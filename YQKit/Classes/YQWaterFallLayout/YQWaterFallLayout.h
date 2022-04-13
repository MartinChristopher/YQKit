//
//  YQWaterFallLayout.h
//
//  Created by Apple on 2021/2/3.
//

#import <UIKit/UIKit.h>
@class YQWaterFallLayout;

@protocol YQWaterFallLayoutDelegate <NSObject>

@required
/**
 每一列的宽度
 */
- (CGFloat)waterFallLayout:(YQWaterFallLayout *_Nonnull)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth ;

@optional
/**
 一共有多少列
 */
- (NSInteger)columnCountWaterFallLayout:(YQWaterFallLayout *_Nonnull)waterFallLayout;
/**
 每一列的间距
 */
- (CGFloat)columnMarginWaterFallLayout:(YQWaterFallLayout *_Nonnull)waterFallLayout;
/**
 每一行的间距
 */
- (CGFloat)rowMarginWaterFallLayout:(YQWaterFallLayout *_Nonnull)waterFallLayout;
/**
 每一个Item的内间距
 */
- (UIEdgeInsets)edgeInsetsInWaterFallLayout:(YQWaterFallLayout *_Nonnull)waterFallLayout;

@end

NS_ASSUME_NONNULL_BEGIN

@interface YQWaterFallLayout : UICollectionViewLayout

- (NSUInteger)colunmCount;
- (CGFloat)columnMargin;
- (CGFloat)rowMargin;
- (UIEdgeInsets)edgeInsets;

@property (nonatomic, weak) id<YQWaterFallLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
