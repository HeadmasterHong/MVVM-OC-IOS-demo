//
//  CollectionDataSource.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Cell.h"
NS_ASSUME_NONNULL_BEGIN

@interface CollectionDataSource : NSObject <UICollectionViewDataSource>
-(instancetype)initWithCellIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
