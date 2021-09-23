#import <UIKit/UIKit.h>

@class ZLSlider;
@class ZLSliderCell;


/**
 *  类似UITableViewDatasource
 */
@protocol ZLSliderDatasource <NSObject>
@required
- (ZLSliderCell *)zl_cellForSlider:(ZLSlider *)slider atIndex:(NSUInteger)idx;
- (NSUInteger)zl_numberOfCells;
@end

/**
 *  类似于UITableView的delegate
 */
@protocol ZLSliderDelegate <NSObject>
@optional
- (void)zl_slider:(ZLSlider *)slider didShowCellAtIndex:(NSUInteger)idx;
- (void)zl_slider:(ZLSlider *)slider didSelectCellAtIndex:(NSUInteger)idx;
@end


/**
 *  类似于UITableViewCell
 */
@interface ZLSliderCell : UIView
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UITapGestureRecognizer *tapRecognizer;

- (id)initWithSlider:(ZLSlider *)slider;

@end



/**
 *  无限轮播控件
 */
@interface ZLSlider : UIView
@property (nonatomic,weak) id<ZLSliderDatasource> datasource;
@property (nonatomic,weak) id<ZLSliderDelegate> delegate;
@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,assign) BOOL playInCircle;

- (instancetype)initWithFrame:(CGRect)frame;

- (ZLSliderCell *)dequeReuableCell;

- (void)reloadData;

@end
