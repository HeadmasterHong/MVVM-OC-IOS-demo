//
//  NSDictionary+NSDCompare.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (NSDCompare)
- (NSComparisonResult)compare: (NSDictionary *)otherDictionary;
@end

NS_ASSUME_NONNULL_END
