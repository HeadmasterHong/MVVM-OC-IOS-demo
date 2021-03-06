//
//  Cell.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import <UIKit/UIKit.h>
#import "Protocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface Cell : UICollectionViewCell  <CellProtocol>

@property(nonatomic ,strong)UIImageView *imgView;

@property(nonatomic ,strong)UILabel *textLabel;

+ (CGSize)sizeForCell:(BOOL)isSelected;
@end

NS_ASSUME_NONNULL_END
