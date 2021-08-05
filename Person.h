//
//  Person.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
@property (nonatomic, assign) int ID;
@property (nonatomic, copy) NSString  *name;
@property (nonatomic, copy) NSString  *phone;
@property (nonatomic, assign) int  score;

@end

NS_ASSUME_NONNULL_END
