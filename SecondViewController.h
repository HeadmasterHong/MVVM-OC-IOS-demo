//
//  SecondViewController.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^blockName)(NSString *text);

//第三种方法：利用delegate实现传值
//step：1 委托者声明delegate
@protocol VcBDelegate
- (void) sendValue:(NSString *)value;
@end

@interface SecondViewController : UIViewController

@property (nonatomic, copy) blockName  block;
@property (nonatomic, weak) id  delegate;

NS_ASSUME_NONNULL_END

@end


