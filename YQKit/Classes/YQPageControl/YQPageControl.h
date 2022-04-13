//
//  YQPageControl.h
//  YQPageControl
//
//  Created by Jh on 2018/11/7.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, YQPageControlContentMode){
    
    YQPageControlContentModeLeft=0,
    YQPageControlContentModeCenter,
    YQPageControlContentModeRight,
};

typedef NS_ENUM(NSInteger, YQPageControlStyle)
{
    /** 默认按照 controlSize 设置的值,如果controlSize未设置 则按照大小为5的小圆点 */
    YQPageControlStyelDefault = 0,
    /** 长条样式 */
    YQPageControlStyelRectangle,
    /** 圆点 + 长条 样式 */
    YQPageControlStyelDotAndRectangle,
    
};


@class YQPageControl;
@protocol YQPageControlDelegate <NSObject>

-(void)YQPageControlClick:(YQPageControl*_Nonnull)pageControl index:(NSInteger)clickIndex;

@end


@interface YQPageControl : UIControl


/** 位置 默认居中 */
@property(nonatomic) YQPageControlContentMode PageControlContentMode;

/** 滚动条样式 默认按照 controlSize 设置的值,如果controlSize未设置 则为大小为5的小圆点 */
@property(nonatomic) YQPageControlStyle PageControlStyle;

@property(nonatomic) NSInteger numberOfPages;          // default is 0
@property(nonatomic) NSInteger currentPage;            // default is 0. value pinned to 0..numberOfPages-1

/** 距离初始位置 间距  默认10 */
@property (nonatomic) CGFloat marginSpacing;
/** 间距 默认3 */
@property (nonatomic) CGFloat controlSpacing;

/** 大小 默认(5,5) 如果设置PageControlStyle,则失效 */
@property (nonatomic) CGSize controlSize;

/** 其他page颜色 */
@property(nullable, nonatomic,strong) UIColor *otherColor;

/** 当前page颜色 */
@property(nullable, nonatomic,strong) UIColor *currentColor;

/** 设置图片 */
@property(nonatomic,strong) UIImage * _Nullable currentBkImg;

@property(nonatomic,weak)id<YQPageControlDelegate> _Nullable delegate;


@end


