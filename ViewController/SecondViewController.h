//
//  SecondViewController.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VcBDelegate
- (void) sendValue:(NSString *)value;
@end

@interface SecondViewController : UIViewController

@property (nonatomic, weak) id  delegate;

NS_ASSUME_NONNULL_END

@end


