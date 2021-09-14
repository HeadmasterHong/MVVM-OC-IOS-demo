//
//  LoopPageView.m
//  NoStoryBoard2
//
//  Created by 阿泽(洪泽林)[运营中心] on 2021/9/10.
//

#import "LoopPageView.h"
#import "Masonry.h"

@interface LoopPageView()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (nonatomic,strong)UIPageViewController *pageCon;

//小圆点
@property (nonatomic,strong)UIPageControl *indicator;
/**
 显示的广告图
 */
@property (nonatomic,strong)NSArray *imageArr;

/**
 page
 */
@property (nonatomic,strong)NSMutableArray *controlls;
/**
 当前tag
 */
@property (nonatomic,assign)NSInteger tagIndex;
/**
 轮播定时器
 */
@property (nonatomic,strong)NSTimer *timeZ;


/**
 回调点击的图片所在的tag值
 */
@property (nonatomic,strong)loopResultBlock block;


/**
 是否在自动轮播
 */
@property (nonatomic,assign)BOOL isAuto;

@end


@implementation LoopPageView


-(instancetype)initWithFrame:(CGRect)frame imgArr:(NSArray *)imgArr preSetIndex:(NSInteger)index loopCallBack:(loopResultBlock)loopCallBack {
    self=[super initWithFrame:frame];
    if(self){
        [self initViewWithPreSetIndex:index];
        [self initData:imgArr block:loopCallBack];
    }
    return self;
    
}

-(void)initViewWithPreSetIndex:(NSInteger)index {
    _controlls=[[NSMutableArray alloc]init];
    _tagIndex=index;//默认tag==0
    _pageCon=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageCon.delegate = self;
    _pageCon.dataSource = self;
    _pageCon.view.frame=self.bounds;
    [self addSubview:_pageCon.view];
    
    _indicator=[[UIPageControl alloc]init];
    _indicator.hidesForSinglePage = YES;
    [_indicator addTarget:self action:@selector(scrollToIndex) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_indicator];

    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(10);
    }];
}



-(void)initData:(NSArray *)arr block:(loopResultBlock)block {
    _isAuto=false;
    _block=block;
    _imageArr=arr;
    _indicator.numberOfPages=_imageArr.count;

    [_imageArr enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *con=[[UIViewController alloc]init];
        con.view.frame=self.bounds;
        UIImageView *image=[[UIImageView alloc]initWithFrame:self.bounds];
        image.contentMode=UIViewContentModeScaleAspectFill;
        image.image = [UIImage imageNamed:obj];
        [con.view addSubview:image];
        [_controlls addObject:con];
        
        [self setListener:con.view index:idx];
    }];
    
     [_pageCon setViewControllers:[NSArray arrayWithObject:[self pageControllerAtIndex:_tagIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    [self openAuto];
}

- (void)scrollToIndex {
    NSInteger index = _indicator.currentPage;
    [_pageCon setViewControllers:[NSArray arrayWithObject:_controlls[index]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

-(void)openAuto {
    
    _isAuto=true;
    
    //开启自动轮播
    __weak typeof(self) weakSelf = self;
    _timeZ=[NSTimer scheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"定时切换--%lu",_tagIndex);
        weakSelf.tagIndex++;
        if(weakSelf.tagIndex>(weakSelf.imageArr.count-1)){
            weakSelf.tagIndex=0;
        }
        
        [_indicator setCurrentPage:weakSelf.tagIndex];
        [weakSelf.pageCon setViewControllers:[NSArray arrayWithObject:[weakSelf pageControllerAtIndex:weakSelf.tagIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
      
    }];
}

-(void)closeAuto {
    if(_timeZ){

        [_timeZ invalidate];
        _timeZ=nil;
    }
    
}

//返回下一个页面
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index= [_controlls indexOfObject:viewController];
    NSLog(@"viewControllerAfterViewController-->%lu",index);

    if(index==(_imageArr.count-1)){
        index=0;
    }else{
        index++;

    }
    return [self pageControllerAtIndex:index];
}

//返回前一个页面
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    //判断当前这个页面是第几个页面
    NSInteger index=[_controlls indexOfObject:viewController];
    NSLog(@"viewControllerBeforeViewController-->%lu",index);
    //如果是第一个页面
    if(index==0){
        index=_imageArr.count-1;
        
    }else{
        index--;

    }
    return [self pageControllerAtIndex:index];
    
}

//根据tag值创建内容页面
-(UIViewController*)pageControllerAtIndex:(NSInteger)index {
    if(_controlls!=nil&&_controlls.count!=0){
        UIViewController *con=_controlls[index];
        return con;
    }
    return nil;
}

//开始滑动的时候触发
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    [self closeAuto];
}

//结束滑动的时候触发
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSInteger index=[_controlls indexOfObject:pageViewController.viewControllers[0]];
     _tagIndex=index;
    [_indicator setCurrentPage:_tagIndex];
    if(_isAuto){  //判断轮播是否开启,如果已开启,重新启动定时器
        [self openAuto];

    }
}

-(void)setListener:(UIView *) arr index:(NSInteger) index {
    
    arr.tag=index;   //设置传递的参数
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuAction:)];
    //    tableViewGesture.view.tag=index;
    arr.userInteractionEnabled=YES;
    [arr addGestureRecognizer:tableViewGesture];
    
}
-(void)menuAction:(id)sender {
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    
    UIView *views = (UIView*) tap.view;
    
    NSUInteger index = views.tag;   //获取上面view设置的tag
    
    if(_block){
        _block(index);

    }
    
}


-(void)layoutSubviews {
    
    [super layoutSubviews ];
    _pageCon.view.frame=self.bounds;
    
}

@end
