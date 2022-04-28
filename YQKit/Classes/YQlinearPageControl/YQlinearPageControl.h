//
//  YQlinearPageControl.h
//
//  Created by Apple on 2021/7/2.
//

#import <UIKit/UIKit.h>

@interface YQlinearPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *otherDotColor;
@property (nonatomic, strong) UIColor *currentDotColor;
@property (nonatomic, assign) CGFloat dotCornerRadius;
@property (nonatomic, assign) CGFloat currentDotWidth;
@property (nonatomic, assign) CGFloat otherDotWidth;
@property (nonatomic, assign) CGFloat dotHeight;
@property (nonatomic, assign) CGFloat dotSpace;

@end
