//
//  LoopPageView.h
//  NoStoryBoard2
//
//  Created by 阿泽(洪泽林)[运营中心] on 2021/9/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^loopResultBlock)(NSInteger index);

@interface LoopPageView : UIView
-(instancetype)initWithFrame:(CGRect)frame imgArr:(NSArray *)imgArr preSetIndex:(NSInteger)index loopCallBack:(loopResultBlock)loopCallBack;
-(void)openAuto;
-(void)closeAuto;

@end

NS_ASSUME_NONNULL_END
