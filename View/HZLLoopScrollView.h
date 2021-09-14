//
//  HZLLoopScrollView.h
//  NoStoryBoard2
//
//  Created by 阿泽(洪泽林)[运营中心] on 2021/9/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HZLLoopScrollViewDidSelectItemBlock)(NSInteger atIndex);

@interface HZLLoopScrollView : UIView

@property (nonatomic, strong)NSArray *imgUrls;

@property (nonatomic, strong)NSArray *imgTitles;

//@property (nonatomic, strong)

+ (instancetype) loopScrollViewWithFrame:(CGRect)frame imgUrls:(NSArray *)imgUrls titles:(NSArray *)titles timeInterval:(NSTimeInterval)timeInterval selectIndex:(NSInteger)index didSelect:(HZLLoopScrollViewDidSelectItemBlock)didSelect;

@end

NS_ASSUME_NONNULL_END
