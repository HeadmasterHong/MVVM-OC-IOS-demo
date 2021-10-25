//
//  SecondViewModel.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Protocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface SecondViewModel : NSObject
@property (nonatomic, strong) NSMutableArray *cellModelArry;
- (instancetype)initSelf;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSInteger)section;
- (id<CellModelProtocol>)cellModelAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)changeLayout:(NSInteger)flag;
+ (void)enumerateCellClassNamesUsingBlock:(void (^)(NSString *cellClassName))block;
@end

NS_ASSUME_NONNULL_END
