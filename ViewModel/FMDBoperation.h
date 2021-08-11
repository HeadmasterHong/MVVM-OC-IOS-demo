//
//  FMDBoperation.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/4.
//

#import <Foundation/Foundation.h>
#import "Person.h"
NS_ASSUME_NONNULL_BEGIN

@interface FMDBoperation : NSObject

-(Person *)findPersonByID:(NSInteger)sear_id;

@end

NS_ASSUME_NONNULL_END
