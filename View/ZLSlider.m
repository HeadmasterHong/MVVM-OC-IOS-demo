#import "ZLSlider.h"

/**
 SliderCell的实现
 */
@implementation ZLSliderCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = NO;
        _tapRecognizer = [[UITapGestureRecognizer alloc] init];
        //等待添加手势
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _titleLabel.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addGestureRecognizer:_tapRecognizer];
        
        [self addSubview:_imageView];
        [self addSubview:_titleLabel];
    }
    
    return self;
}

- (id)initWithSlider:(ZLSlider *)slider
{
    return [self initWithFrame:slider.bounds];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

@end


/**
 Slider 实现
 */

@interface ZLSlider ()
@property (nonatomic,strong) NSMutableArray *reuableCells;
@property (nonatomic,weak) ZLSliderCell *showingCell;
@property (nonatomic,assign) CGRect showingFrame;
@property (nonatomic,assign) CGRect preFrame;
@property (nonatomic,assign) CGRect nextFrame;
@end

@implementation ZLSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _showingFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _nextFrame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
        _preFrame = CGRectMake(-frame.size.width, 0, frame.size.width, frame.size.height);
        _reuableCells = [NSMutableArray array];
    }
    
    return self;
}

- (void)reloadData
{
    [self setIndex:0];
}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
    [self p_showCellAtIndex:index];
}


- (ZLSliderCell *)dequeReuableCell
{
    if (_reuableCells.count <=0) {
        ZLSliderCell *cell = [[ZLSliderCell alloc] initWithSlider:self];
        [_reuableCells addObject:cell];
    }
    
    ZLSliderCell *cell = _reuableCells.firstObject;
    [_reuableCells removeObject:cell];
    return cell;
}

- (void)p_showCellAtIndex:(NSUInteger)idx
{
    NSAssert(_datasource, @"Must have a datasour!");
    
    NSUInteger count = [_datasource zl_numberOfCells];
    
    NSAssert(idx < count, @"index out of bounds!");
    
    [_showingCell removeFromSuperview];
    
    ZLSliderCell *showingcell = [self getCellAtIndex:idx];
    _showingCell = showingcell;
    
    [self addSubview:showingcell];
}

- (ZLSliderCell *)getCellAtIndex:(NSUInteger)idx
{
    ZLSliderCell *showingcell = [_datasource zl_cellForSlider:self atIndex:idx];
    [showingcell.tapRecognizer addTarget:self action:@selector(p_didTapCell:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slide:)];
    [showingcell addGestureRecognizer:pan];
    return showingcell;
}

- (void)p_didTapCell:(UITapGestureRecognizer *)recognizer
{
    if (_delegate && [_delegate respondsToSelector:@selector(zl_slider:didSelectCellAtIndex:)]) {
        [_delegate zl_slider:self didSelectCellAtIndex:_index];
    }
}

- (void)slide:(UIPanGestureRecognizer *)gesture {
    CGPoint translationPoint = [gesture translationInView:self];
    CGFloat centerX = translationPoint.x + gesture.view.center.x;
    gesture.view.center = CGPointMake(centerX, gesture.view.center.y);
    
    int idx = -1;
    
    if (translationPoint.x < 0 ) {
        if (_playInCircle) {
            if (_index  + 1 >= [_datasource zl_numberOfCells]) {
                idx = 0;
            }else{
                idx = (int)_index + 1;
            }
        }else{
            if (_index + 1 < [_datasource zl_numberOfCells]) {
                idx = (int)_index + 1;
            }
        }
    }else {
        if (_playInCircle) {
            if ((int)_index  - 1 < 0) {
                idx =  (int)[_datasource zl_numberOfCells] - 1;
            }else{
                idx = (int)_index - 1;
            }
        }else{
            if ((int)_index  - 1 >= 0) {
                idx = (int)_index - 1;
            }
        }
    }
    
    if (idx >= 0) {
        
        _index = idx;
        
        ZLSliderCell *nextCell = [self getCellAtIndex:_index];
        _nextFrame.origin = CGPointMake(translationPoint.x + _nextFrame.origin.x, _nextFrame.origin.y);
        nextCell.frame = _nextFrame;
        [self addSubview:nextCell];
        
    }
    
    [gesture setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)p_showNext
{
    int idx = -1;
    
    if (_playInCircle) {
        if (_index  + 1 >= [_datasource zl_numberOfCells]) {
            idx = 0;
        }else{
            idx = (int)_index + 1;
        }
    }else{
        if (_index + 1 < [_datasource zl_numberOfCells]) {
            idx = (int)_index + 1;
        }
    }
    
    if (idx >= 0) {
        
        _index = idx;
        
        ZLSliderCell *nextCell = [self getCellAtIndex:_index];
        nextCell.frame = _nextFrame;
        [self addSubview:nextCell];
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             nextCell.frame = _showingFrame;
                             _showingCell.frame = _preFrame;
                             
                         }
                         completion:^(BOOL finish){
                             
                             [_reuableCells addObject:_showingCell];
                             [_showingCell removeFromSuperview];
                             _showingCell = nextCell;
                             
                         }];
        
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(zl_slider:didShowCellAtIndex:)]) {
        [_delegate zl_slider:self didShowCellAtIndex:idx];
    }
        
    
}

- (void)p_showPre
{
    int idx = -1;
    
    if (_playInCircle) {
        if ((int)_index  - 1 < 0) {
            idx =  (int)[_datasource zl_numberOfCells] - 1;
        }else{
            idx = (int)_index - 1;
        }
    }else{
        if ((int)_index  - 1 >= 0) {
            idx = (int)_index - 1;
        }
    }
    
    if (idx >= 0) {
        
        _index = idx;
        
        ZLSliderCell *preCell = [self getCellAtIndex:_index];
        preCell.frame = _preFrame;
        [self addSubview:preCell];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             preCell.frame = _showingFrame;
                             _showingCell.frame = _nextFrame;
                             
                         }
                         completion:^(BOOL finish){
                             
                             [_reuableCells addObject:_showingCell];
                             [_showingCell removeFromSuperview];
                             _showingCell = preCell;
                             
                         }];
        
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(zl_slider:didShowCellAtIndex:)]) {
        [_delegate zl_slider:self didShowCellAtIndex:idx];
    }
}

@end
