//
//  CellModel.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/19.
//

#import <Foundation/Foundation.h>
#import "Protocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface CellModel : NSObject <CellModelProtocol>
@property (nonatomic,copy) NSString *eventName;
@property (nonatomic,copy) NSString *imgPath;
@property (nonatomic,copy) NSString *cellIdentifier;
@end

NS_ASSUME_NONNULL_END
