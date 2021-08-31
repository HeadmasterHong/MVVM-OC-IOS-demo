//
//  RowCell.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/18.
//

#import <UIKit/UIKit.h>
#import "Protocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RowCell : UICollectionViewCell <CellProtocol>
@property(nonatomic ,strong)UIImageView *imgView;
+ (CGSize)sizeForCell;

@end

NS_ASSUME_NONNULL_END
