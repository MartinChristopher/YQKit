//
//  YQFlowLayoutMacro.h
//
//  Created by xuyefeng on 17/5/17.
//

#ifndef YQFlowLayoutMacro_h
#define YQFlowLayoutMacro_h

/*!** 
 左对齐布局时：左上角第一个item 距离四周的距离
 右对齐布局时：右上角第一个item 距离四周的距离
  ***/
typedef struct FlowLayoutItemEdgeInsets {
    float top, left, bottom, right;  // specify amount to inset (positive) for each of the edges. values can be negative to 'outset'
} FlowLayoutItemEdgeInsets;

/*!** item所属的组section 距离四周的距离 ***/
typedef struct FlowLayoutSectionEdgeInsets {
    float top, left, bottom, right;  // specify amount to inset (positive) for each of the edges. values can be negative to 'outset'
} FlowLayoutSectionEdgeInsets;

#endif /* YQFlowLayoutMacro_h */
