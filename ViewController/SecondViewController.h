//
//  SecondViewController.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import <UIKit/UIKit.h>
#import "SecondViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VcBDelegate
- (void) receiveValue:(NSString *)value;
@end

@interface SecondViewController : UIViewController
@property (nonatomic, strong) SecondViewModel *viewModel;

@property (nonatomic, weak) id  delegate;

NS_ASSUME_NONNULL_END

@end


