//
//  LightArtSectionListLayout.m
//  lightart
//
//  Created by 彭利章 on 2018/5/14.
//  Copyright © 2018年 bingwu. All rights reserved.
//

#import "LightArtSectionListLayout.h"
#import "LightArtDocument.h"
#import "LightArtUIView.h"
#import <objc/runtime.h>

static char sectionBottomKey;
static char originalFrameKey;

@interface UICollectionViewLayoutAttributes (LightArt)

@end

@implementation UICollectionViewLayoutAttributes (LightArt)

- (void)setOriginalFrame:(CGRect)originalFrame {
    NSValue *value = [NSValue valueWithCGRect:originalFrame];
    objc_setAssociatedObject(self, &originalFrameKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)originalFrame {
    NSValue *value = objc_getAssociatedObject(self, &originalFrameKey);
    return [value CGRectValue];
}

- (void)setSectionBottom:(CGFloat)sectionBottom {
    objc_setAssociatedObject(self, &sectionBottomKey, @(sectionBottom), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)sectionBottom {
    NSNumber *num = objc_getAssociatedObject(self, &sectionBottomKey);
    return [num floatValue];
}

@end

@interface LightArtSectionListLayout ()

@property (nonatomic, strong) NSMutableArray *layoutAttributesArray;
@property (nonatomic, strong) NSMutableArray *sectionHeaderAttributesArray;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation LightArtSectionListLayout

- (void)prepareLayout {
    if (nil == self.layoutAttributesArray) {
        [self caculateLayout];
    }
}

- (void)caculateLayout {
    self.layoutAttributesArray = [NSMutableArray array];
    self.sectionHeaderAttributesArray = [NSMutableArray array];
    CGFloat vgap = [Bounds pixelWithString:self.sectionList.v_gap screenWidth:self.sectionList.screenWidth];
    CGFloat hgap = [Bounds pixelWithString:self.sectionList.h_gap screenWidth:self.sectionList.screenWidth];
    CGFloat top = 0;
    CGFloat contentWidth = self.collectionView.la_width;
    if (nil != self.sectionList.content_width) {
        CGFloat width = [Bounds pixelWithString:self.sectionList.content_width parent:self.collectionView.la_width screenWidth:self.sectionList.screenWidth];
        if (width < contentWidth) {
            contentWidth = width;
        }
    }
    CGFloat contentLeft = (self.collectionView.la_width - contentWidth) / 2;
    for (int i = 0; i < self.sectionList.sections.count + (nil != self.sectionList.tail_tab ? 1 : 0); i++) {
        LightArtSection *lightArtSection = nil;
        LightArtUIComponent *header = nil;
        if (i < self.sectionList.sections.count) {
            lightArtSection = self.sectionList.sections[i];
            header = lightArtSection.header;
        } else {
            LightArtTailTab *tailTab = self.sectionList.tail_tab;
            lightArtSection = tailTab.sections[tailTab.segment.selected_index];
            header = tailTab.segment;
        }
        if (0 != lightArtSection.v_gap.length) {
            vgap = [Bounds pixelWithString:lightArtSection.v_gap screenWidth:self.sectionList.screenWidth];
        }
        if (0 != lightArtSection.h_gap) {
            hgap = [Bounds pixelWithString:lightArtSection.h_gap screenWidth:self.sectionList.screenWidth];
        }
        UIEdgeInsets inset = UIEdgeInsetsZero;
        if (nil != lightArtSection.content_insets) {
            inset = [lightArtSection.content_insets insetWithScreenWidth:self.sectionList.screenWidth];
        } else if (nil != self.sectionList.content_insets) {
            inset = [self.sectionList.content_insets insetWithScreenWidth:self.sectionList.screenWidth];
        }
        UICollectionViewLayoutAttributes *sectionAttributes = nil;
        if (nil != header) {
            CGFloat height = 0;
            if (0 == header.bounds.h.length) {
                LightArtUIView *v = [LightArtUIView viewWithModel:header];
                height = v.la_height;
            } else {
                height = [Bounds pixelWithString:header.bounds.h parent:self.collectionView.la_height screenWidth:self.sectionList.screenWidth];
            }
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            ;
            CGRect frame = CGRectMake(contentLeft, top, contentWidth, height);
            attributes.frame = frame;
            [attributes setOriginalFrame:frame];
            [self.layoutAttributesArray addObject:attributes];
            top += height;
            sectionAttributes = attributes;
            [self.sectionHeaderAttributesArray addObject:sectionAttributes];
        }
        top += inset.top;
        if (lightArtSection.column <= 1) {
            CGFloat itemX = contentLeft + inset.left;
            CGFloat itemWidth = contentWidth - inset.left - inset.right;
            itemWidth = round(itemWidth * 2) / 2;
            for (int j = 0; j < lightArtSection.components.count; j++) {
                LightArtUIComponent *component = lightArtSection.components[j];
                CGFloat itemY = top + (0 != j ? vgap : 0);
                CGFloat height = 0;
                if (0 == component.bounds.h.length) {
                    LightArtUIView *v = [LightArtUIView viewWithModel:component];
                    [v refreshFrameWithParentSize:CGSizeMake(itemWidth, 0)];
                    height = v.la_height;
                } else {
                    height = [Bounds pixelWithString:component.bounds.h parent:self.collectionView.la_height screenWidth:self.sectionList.screenWidth];
                }
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:j inSection:i]];
                attributes.frame = CGRectMake(itemX, itemY, itemWidth, height);
                [self.layoutAttributesArray addObject:attributes];
                top = itemY + height;
            }
            top += inset.bottom;
        } else {
            CGFloat itemWidth = (contentWidth - inset.left - inset.right - hgap * (lightArtSection.column - 1)) / lightArtSection.column;
            itemWidth = round(itemWidth * 2) / 2;
            CGFloat columnHeight[lightArtSection.column];
            NSInteger columnItemCount[lightArtSection.column];
            for (int j = 0; j < lightArtSection.column; j++) {
                columnHeight[j] = top;
                columnItemCount[j] = 0;
            }
            for (int j = 0; j < lightArtSection.components.count; j++) {
                LightArtUIComponent *component = lightArtSection.components[j];
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:j inSection:i]];
                // 找出最短列号
                NSInteger column = [self shortestColumn:columnHeight columnCount:lightArtSection.column];
                
                CGFloat itemX = contentLeft + inset.left + (itemWidth + hgap) * column;
                CGFloat itemY = columnHeight[column] + (0 != columnItemCount[column] ? vgap : 0);
                CGFloat height = 0;
                if (0 == component.bounds.h.length) {
                    LightArtUIView *v = [LightArtUIView viewWithModel:component];
                    height = v.la_height;
                } else {
                    height = [Bounds pixelWithString:component.bounds.h parent:self.collectionView.la_height screenWidth:self.sectionList.screenWidth];
                }
                attributes.frame = CGRectMake(itemX, itemY, itemWidth, height);
                [self.layoutAttributesArray addObject:attributes];
                
                // 数据追加在最短列
                columnItemCount[column]++;
                columnHeight[column] = itemY + height;
            }
            // 找出最高列列号
            NSInteger column = [self highestColumn:columnHeight columnCount:lightArtSection.column];
            top = columnHeight[column] + inset.bottom;
        }
        [sectionAttributes setSectionBottom:top];
    }
    self.contentSize = CGSizeMake(self.collectionView.la_width, top);
}

- (NSInteger)shortestColumn:(CGFloat *)columnHeight columnCount:(int)columnCount {
    
    CGFloat max = CGFLOAT_MAX;
    NSInteger column = 0;
    for (int i = 0; i < columnCount; i++) {
        if (columnHeight[i] < max) {
            max = columnHeight[i];
            column = i;
        }
    }
    return column;
}

- (NSInteger)highestColumn:(CGFloat *)columnHeight columnCount:(int)columnCount {
    CGFloat min = 0;
    NSInteger column = 0;
    for (int i = 0; i < columnCount; i++) {
        if (columnHeight[i] > min) {
            min = columnHeight[i];
            column = i;
        }
    }
    return column;
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (!self.sectionList.sticky_header && nil == self.sectionList.tail_tab) {
        return self.layoutAttributesArray;
    }
    for (UICollectionViewLayoutAttributes *sectionAttributes in self.sectionHeaderAttributesArray) {
        CGRect frame = [sectionAttributes originalFrame];
        CGFloat offset = self.collectionView.contentOffset.y;
        CGFloat sectionTop = frame.origin.y;
        CGFloat sectionBottom = [sectionAttributes sectionBottom];
        BOOL sticky = (self.sectionList.sticky_header && sectionAttributes.indexPath.section < self.sectionList.sections.count) || (sectionAttributes.indexPath.section >= self.sectionList.sections.count && nil != self.sectionList.tail_tab);
        if (sticky && offset > sectionTop && offset < sectionBottom) {
            if (offset < (sectionBottom - frame.size.height)) {
                frame.origin.y = offset;
            } else {
                frame.origin.y = sectionBottom - frame.size.height;
            }
            sectionAttributes.frame = frame;
            sectionAttributes.zIndex = 1024;
        } else {
            sectionAttributes.frame = frame;
        }
    }
    return self.layoutAttributesArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
