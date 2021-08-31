//
//  Protocol.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol CellModelProtocol <NSObject>
@property (nonatomic,copy) NSString *eventName;
@property (nonatomic,copy) NSString *imgPath;
@property (nonatomic,copy) NSString *cellIdentifier;
@property (nonatomic,assign) BOOL isSelected;
@end

@protocol CellProtocol <NSObject>

@optional
- (void)configureByModel:(id<CellModelProtocol>)cellModel;
- (void)setCollectionView:(UICollectionView *)collectionView;

@end
NS_ASSUME_NONNULL_END
