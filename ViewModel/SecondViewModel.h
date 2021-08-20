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
- (instancetype)initSelf;

- (NSUInteger)numberOfSections:(NSInteger)layoutFlag;
- (NSUInteger)numberOfRowsInSection:(NSInteger)section :(NSInteger)layoutFlag;
- (id<CellModelProtocol>)cellModelAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)changeLayout:(NSInteger)flag;
+ (void)enumerateCellClassNamesUsingBlock:(void (^)(NSString *cellClassName))block;
@end

NS_ASSUME_NONNULL_END
