//
//  YQPagingEnableLayout.m
//  SoloMe
//
//  Created by Apple on 2022/4/25.
//

#import "YQPagingEnableLayout.h"
#import <objc/message.h>

@implementation YQPagingEnableLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat contentInset = self.collectionView.frame.size.width - self.itemSize.width;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    if ([self.collectionView respondsToSelector:NSSelectorFromString(@"_setInterpageSpacing:")]) {
        ((void(*)(id,SEL,CGSize))objc_msgSend)(self.collectionView, NSSelectorFromString(@"_setInterpageSpacing:"), CGSizeMake(-(contentInset - self.minimumLineSpacing), 0));
    }
    if ([self.collectionView respondsToSelector:NSSelectorFromString(@"_setPagingOrigin:")]) {
        ((void(*)(id,SEL,CGPoint))objc_msgSend)(self.collectionView, NSSelectorFromString(@"_setPagingOrigin:"), CGPointMake(0, 0));
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        float distance = (visibleRect.origin.x + visibleRect.size.width / 2.0) - attributes.center.x;
        float normalizedDistance = fabs(distance / self.itemSize.height);
        float zoom = 1 - self.scaleFactor * normalizedDistance;
        attributes.transform3D = CATransform3DMakeScale(1.0, zoom, 1.0);
    }
    return attributesArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
}

@end
