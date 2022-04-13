//
//  YQWaterFallLayout.m
//
//  Created by Apple on 2021/2/3.
//

#import "YQWaterFallLayout.h"
/** 默认的列数    */
static const CGFloat DefaultColunmCount = 2;
/** 每一列之间的间距    */
static const CGFloat DefaultColunmMargin = 10;
/** 每一行之间的间距    */
static const CGFloat DefaultRowMargin = 10;
/** 内边距    */
static const UIEdgeInsets DefaultEdgeInsets = {5, 30, 5, 30};

@interface YQWaterFallLayout ()
/** 存放所有的布局属性 */
@property (nonatomic, strong) NSMutableArray *attrsArr;
/** 存放所有列的当前高度 */
@property (nonatomic, strong) NSMutableArray *columnHeights;
/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;

@end

@implementation YQWaterFallLayout

- (NSMutableArray *)attrsArr {
    if (!_attrsArr) {
        _attrsArr = [NSMutableArray array];
    }
    return _attrsArr;
}

- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

#pragma mark - 数据处理
/**
 * 列数
 */
- (NSUInteger)colunmCount {
    if ([self.delegate respondsToSelector:@selector(columnCountWaterFallLayout:)]) {
        return [self.delegate columnCountWaterFallLayout:self] ;
    }else{
        return DefaultColunmCount ;
    }
}

/**
 * 行间距
 */
- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginWaterFallLayout:)]) {
        return [self.delegate rowMarginWaterFallLayout:self];
    }else{
        return DefaultRowMargin;
    }
}

/**
 * 列间距
 */
- (CGFloat)columnMargin {
    if ([self.delegate respondsToSelector:@selector(columnMarginWaterFallLayout:)]) {
        return [self.delegate columnMarginWaterFallLayout:self];
    }else{
        return DefaultColunmMargin;
    }
}

/**
 * item的内边距
 */
- (UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInWaterFallLayout:)]) {
        return [self.delegate edgeInsetsInWaterFallLayout:self];
    }else{
        return DefaultEdgeInsets;
    }
}

/**
 * 初始化
 */
- (void)prepareLayout {
    [super prepareLayout];
    //内容的高度
    self.contentHeight = 0;
    // 清除之前计算的所有高度
    [self.columnHeights removeAllObjects];
    // 设置每一列默认的高度
    for (NSInteger i = 0; i < DefaultColunmCount ; i ++) {
        [self.columnHeights addObject:@(DefaultEdgeInsets.top)];
    }
    // 清楚之前所有的布局属性
    [self.attrsArr removeAllObjects];
    // 开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0] ;
    
    for (int i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0] ;
        // 获取indexPath位置上cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath] ;
        [self.attrsArr addObject:attrs] ;
    }
}

/**
 * 返回indexPath位置cell对应的布局属性
 Attributes ：属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 创建布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    //collectionView的宽度
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    // 设置布局属性的frame
    CGFloat cellW = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right - (self.colunmCount - 1) * self.columnMargin) / self.colunmCount ;
    
    CGFloat cellH = [self.delegate waterFallLayout:self heightForItemAtIndexPath:indexPath.item itemWidth:cellW];
    // 找出最短的那一列
    NSInteger destColumn = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    
    for (int i = 1; i < DefaultColunmCount; i++) {
        // 取得第i列的高度
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        //判断是否替换最小的列宽
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    CGFloat cellX = self.edgeInsets.left + destColumn * (cellW + self.columnMargin);
    CGFloat cellY = minColumnHeight;
    if (cellY != self.edgeInsets.top) {
        
        cellY += self.rowMargin;
    }
    attrs.frame = CGRectMake(cellX, cellY, cellW, cellH);
    // 更新最短那一列的高度
    self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
    // 记录内容的高度 - 即最长那一列的高度
    CGFloat maxColumnHeight = [self.columnHeights[destColumn] doubleValue];
    if (self.contentHeight < maxColumnHeight) {
        self.contentHeight = maxColumnHeight;
    }
    return attrs;
}

/**
 * 决定cell的高度
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArr;
}

/**
 * 内容的高度
 */
- (CGSize)collectionViewContentSize {
        CGFloat maxColumnHeight = [self.columnHeights[0] doubleValue];
        for (int i = 0; i < DefaultColunmCount; i++) {
            // 取得第i列的高度
            CGFloat columnHeight = [self.columnHeights[i] doubleValue];
    
            if (maxColumnHeight < columnHeight) {
                maxColumnHeight = columnHeight;
            }
        }
    return CGSizeMake(0, self.contentHeight + self.edgeInsets.bottom);
}

@end
