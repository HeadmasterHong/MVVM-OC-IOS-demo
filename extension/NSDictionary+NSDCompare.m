//
//  NSDictionary+NSDCompare.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/30.
//

#import "NSDictionary+NSDCompare.h"

@implementation NSDictionary (NSDCompare)
- (NSComparisonResult)compare: (NSDictionary *)otherDictionary
{
    NSDictionary *tempDictionary = (NSDictionary *)self;
//    NSLog(@"%@",self);
    NSString *d1 = [tempDictionary objectForKey:@"name"];
    NSString *d2 = [otherDictionary objectForKey:@"name"];
    
    NSComparisonResult result = [d1 compare:d2];
    
    return result == NSOrderedDescending; // 升序
//    return result == NSOrderedAscending;  // 降序
}
@end
