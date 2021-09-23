//
//  LoopPageView.h
//  NoStoryBoard2
//
//  Created by 阿泽(洪泽林)[运营中心] on 2021/9/10.
//

#import <UIKit/UIKit.h>
@class LoopCell;
@class LoopPageView;


typedef void(^loopResultBlock)(NSInteger index);

@protocol LoopScroolViewDatasource <NSObject>
- (LoopCell *)LoopCellForLoopPageView:(LoopPageView *)loopPageView atIndex:(NSUInteger)idx;
- (NSUInteger)numberOfCells;
@required


@end

@interface LoopCell : UIView
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLabel;
@end
  
@interface LoopPageView : UIView
@property (nonatomic,weak) id<LoopScroolViewDatasource> datasource;
-(instancetype)initWithFrame:(CGRect)frame imgArr:(NSArray *)imgArr preSetIndex:(NSInteger)index loopCallBack:(loopResultBlock)loopCallBack;
-(void)openAuto;
-(void)closeAuto;

@end

