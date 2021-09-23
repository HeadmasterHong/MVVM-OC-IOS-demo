//
//  HZLLoopScrollView.m
//  NoStoryBoard2
//
//  Created by 阿泽(洪泽林)[运营中心] on 2021/9/8.
//

#import "HZLLoopScrollView.h"
#import "CustomFlowLayout.h"
#import "Masonry.h"

@interface HZLLoopScrollViewCellModel:NSObject

@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *imgTitle;

@end

@implementation HZLLoopScrollViewCellModel



@end

@interface HZLLoopScrollViewCell:UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel     *titleLabel;
- (void)configWithCellModel:(HZLLoopScrollViewCellModel *)cellModel;

@end

@implementation HZLLoopScrollViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
    }
    return self;
}

- (void)setup{
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 100)];
    self.titleLabel.numberOfLines = 0;//表示label可以多行显示
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;//换行模式，与上面保持一致。
    self.titleLabel.layer.cornerRadius = 6;
    self.titleLabel.layer.masksToBounds = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.titleLabel.alpha = 1;
    [self addSubview:self.titleLabel];
}

- (void)configWithCellModel:(HZLLoopScrollViewCellModel *)cellModel{
    self.imageView.image = [UIImage imageNamed:cellModel.imgUrl];
    self.titleLabel.text = cellModel.imgTitle;
}

@end

@interface HZLLoopScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray<HZLLoopScrollViewCellModel *> *cellModelArray;
@property (nonatomic, strong) UIPageControl *indicator;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) HZLLoopScrollViewDidSelectItemBlock didSelectBlock;

@end

@implementation HZLLoopScrollView

+ (instancetype) loopScrollViewWithFrame:(CGRect)frame
                                 imgUrls:(NSArray *)imgUrls
                                  titles:(NSArray *)titles
                            timeInterval:(NSTimeInterval)timeInterval
                             selectIndex:(NSInteger)index
                               didSelect:(HZLLoopScrollViewDidSelectItemBlock)didSelect {
    HZLLoopScrollView *loop = [[HZLLoopScrollView alloc] initWithFrame:frame];
    loop.timeInterval = timeInterval;
    loop.imgUrls = imgUrls;
    loop.imgTitles = titles;
    loop.currentIndex = index;
    loop.didSelectBlock = didSelect;
    loop.cellModelArray = [NSMutableArray array];
    loop.timeInterval = timeInterval;
    [loop initCellModelArray];
    [loop configCollectionView];
    [loop initIndicator];
    [loop configTimer:timeInterval];

    return loop;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)configCollectionView {
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.itemSize = self.bounds.size;
    self.layout.minimumLineSpacing = 0;
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[HZLLoopScrollViewCell class]
            forCellWithReuseIdentifier:@"carouselCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
//    _collectionView.pagingEnabled = true;
    
    [self addSubview: self.collectionView];
    
}

- (void)initIndicator {
    _indicator=[[UIPageControl alloc]init];
    _indicator.numberOfPages = _imgUrls.count;
    [_indicator setCurrentPage:0];
    
    [self addSubview:_indicator];
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(10);
    }];
    

}

- (void)initCellModelArray {
    
    for (int i = 0; i < self.imgUrls.count; i++) {
        HZLLoopScrollViewCellModel *cellModel = [[HZLLoopScrollViewCellModel alloc] init];
        cellModel.imgUrl = self.imgUrls[i];
        cellModel.imgTitle = self.imgTitles[i];
        [self.cellModelArray addObject:cellModel];
    }
    
}

- (void)configTimer:(NSTimeInterval)timeInterval {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(autoscroll) userInfo:nil repeats:YES];
    
}

- (void)autoscroll {
    NSInteger curIndex = (self.collectionView.contentOffset.x + self.layout.itemSize.width * 0.5) / self.layout.itemSize.width;
    NSInteger toIndex = curIndex + 1;
    
    NSIndexPath *indexPath = nil;
    if (toIndex == self.imgUrls.count) {
      toIndex = 0;
      
      // scroll to the middle without animation, and scroll to middle with animation, so that it scrolls
      // more smoothly.
      indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
//      [self.collectionView scrollToItemAtIndexPath:indexPath
//                                  atScrollPosition:UICollectionViewScrollPositionNone
//                                          animated:NO];
    } else {
      indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
    }
    
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    
}

//-(void)openAuto{
//    
//    _isAuto=true;
//    
//    //开启自动轮播
//    __weak typeof(self) weakSelf = self;
//    _timeZ=[NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"定时切换--%lu",_tagIndex);
//        weakSelf.tagIndex++;
//        if(weakSelf.tagIndex>(weakSelf.imageArr.count-1)){
//            weakSelf.tagIndex=0;
//        }
//        
//        [_indicator setCurrentPage:weakSelf.tagIndex];
//        [weakSelf.pageCon setViewControllers:[NSArray arrayWithObject:[weakSelf pageControllerAtIndex:weakSelf.tagIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
//      
//    }];
//}
//
//-(void)closeAuto{
//    if(_timeZ){
//
//        [_timeZ invalidate];
//        _timeZ=nil;
//    }
//    
//}

- (HZLLoopScrollViewCellModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cellModelArray objectAtIndex:(indexPath.section+indexPath.row)];
}

#pragma mark collectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imgUrls.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HZLLoopScrollViewCellModel *cellModel = (HZLLoopScrollViewCellModel *)[self cellModelAtIndexPath:indexPath];
    HZLLoopScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"carouselCell" forIndexPath:indexPath];
    [cell configWithCellModel:cellModel];
    
    return cell;
}


#pragma mark collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
