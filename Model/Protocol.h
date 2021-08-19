//
//  Protocol.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CellModelProtocol <NSObject>
@property (nonatomic,copy) NSString *eventName;
@property (nonatomic,copy) NSString *imgPath;
@property (nonatomic,copy) NSString *cellIdentifier;
@end

@protocol CellProtocol <NSObject>
- (void)configureByModel:(id<CellModelProtocol>)cellModel;
@end
NS_ASSUME_NONNULL_END
