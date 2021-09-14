//
//  CustomFlowLayout.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/25.
//

#import "CustomFlowLayout.h"

@implementation CustomFlowLayout
- (void)prepareLayout{
    [super prepareLayout];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

//- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
//    NSArray *array = [[super layoutAttributesForElementsInRect:rect] copy];
//    CGFloat targetX = self.collectionView.contentOffset.x+self.collectionView.frame.size.width*0.1;
//    for (UICollectionViewLayoutAttributes *attrs in array) {
//
//        CGFloat delta = ABS(attrs.center.x-targetX);
//        CGFloat scale = 0.5;
//        scale = 1 - delta/self.collectionView.frame.size.width*0.2;
//        attrs.transform = CGAffineTransformMakeScale(scale, scale);
//
//    }
//    return array;
//}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;

    NSArray *array = [[super layoutAttributesForElementsInRect:rect] copy];

    CGFloat targetX = proposedContentOffset.x;
    CGFloat minDelta = MAXFLOAT;
    for(UICollectionViewLayoutAttributes *attrs in array){
        if (ABS(minDelta) > ABS(attrs.frame.origin.x - targetX)) {
            minDelta = attrs.frame.origin.x - targetX;
        }
    }
    
    proposedContentOffset.x += minDelta ;
    
    
    return proposedContentOffset;
}
@end
