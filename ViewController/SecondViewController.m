//
//  SecondViewController.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "SecondViewController.h"
#import "Cell.h"
#import "RowCell.h"
#import "CustomFlowLayout.h"
#import "ReactiveObjC.h"

@interface SecondViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) id<CellModelProtocol> selectedModel;
@property (nonatomic, assign) NSInteger layoutFlag;
@property (nonatomic, assign) NSInteger headerStickyWidth;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, assign) BOOL floatFlag;
@property (nonatomic, assign) BOOL canParentViewScroll;
@property (nonatomic, assign) BOOL canChildViewScroll;


@end


@implementation SecondViewController
- (void)viewDidLoad {
    [super viewDidLoad];
        [self bindModel];
        [self initView];
//    [self observeContentOffset];
}

//- (void)observeContentOffset
//{
//    @weakify(self)
//    [[RACObserve(self.collectionView,contentOffset) deliverOnMainThread] subscribeNext:^(NSValue *value) {
//        @strongify(self)
//        if (self.collectionView.contentOffset.x >= 120) {
////            self.collectionView.scrollEnabled = NO;
//            self.floatFlag = YES;
//        }
//    }];
//}

- (void)bindModel{
    self.viewModel = [[SecondViewModel alloc] initSelf];
    self.layoutFlag = 0;//初始布局
}

- (void)initView{
    //底图
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgSPEC.jpeg"]];
    bgImage.frame = CGRectMake(0,0, self.view.frame.size.width, 150);
    [self.view addSubview:bgImage];
    
    //页面属性
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.headerStickyWidth = 64;
    self.maxLength = 648;
    
    self.canParentViewScroll = YES;
    self.canChildViewScroll = NO;
    
    //创建layout布局类
    CustomFlowLayout *layout = [[CustomFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    //右侧容器
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(128, 0, self.view.frame.size.width-64, 100) collectionViewLayout:layout];
    [self registerCell:self.collectionView];
    self.collectionView.alwaysBounceHorizontal =YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    
    //外层容器
    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.containerView.contentSize = CGSizeMake(1000, 100);
    self.containerView.delegate = self;
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
    label1.textColor = [UIColor redColor];
    label1.text = @"图标";
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(64, 0, 64, 64)];
    label2.textColor = [UIColor redColor];
    label2.text = @"分隔";
    
    //添加部件
    [self.containerView addSubview:self.collectionView];
    [self.containerView addSubview:label1];
    [self.containerView addSubview:label2];
    [self.view addSubview:self.containerView];
    
    
    self.navigationItem.title = @"选择项目";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]  initWithTitle:@"切换布局" style:UIBarButtonItemStylePlain target:self action:@selector(clickButtonLayout)];
}

- (void)registerCell:(UICollectionView *)collectionView
{
    [SecondViewModel enumerateCellClassNamesUsingBlock:^(NSString * _Nonnull cellClassName) {
        if(cellClassName) {
            [collectionView registerClass:NSClassFromString(cellClassName) forCellWithReuseIdentifier:cellClassName];
        }
    }];
}

- (void)clickButtonLayout{
    self.layoutFlag = [self.viewModel changeLayout:self.layoutFlag];
    [self.collectionView reloadData];
}

#pragma mark collectionview delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.viewModel.cellModelArry.count) {
        return NO;
    }
    id<CellModelProtocol> cellModel = _viewModel.cellModelArry[indexPath.item];
    if (!cellModel.isSelected) {
        self.selectedModel.isSelected = NO;
        cellModel.isSelected = YES;
        self.selectedModel = cellModel;
        
        [collectionView reloadData];
        
//        [collectionView scrollToItemAtIndexPath:indexPath  atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        NSInteger totalDistance = 5;
        for (int i=0; i<indexPath.row; i++) {
            UICollectionViewLayoutAttributes *attrs = [collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            totalDistance += attrs.size.width+10;
        }
        //解决由于滑动改变位置造成定位不准的问题:需多滑动前一段view距离锚点的距离
        [collectionView setContentOffset:CGPointMake(totalDistance+(_headerStickyWidth-self.containerView.contentOffset.x), 0) animated:YES];

        
        //回传首页
//        NSString *str = cellModel.eventName;
//        if ([_delegate respondsToSelector:@selector(receiveValue:)]) {
//            [_delegate receiveValue:str];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
        return YES;
    }
    return NO;
    
    
}
// 返回YES表示可以继续传递触摸事件，这样两个嵌套的scrollView才能同时滚动
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat mainContentOffsetX = _containerView.contentOffset.x;
    CGFloat childContenOffSetX = _collectionView.contentOffset.x;
    
    if (scrollView == self.containerView) {
        NSLog(@"parentScrolling");
        //悬停也能滑动 让用户感知到一体的滑动导航
        if(mainContentOffsetX > _headerStickyWidth){
            [_containerView setContentOffset:CGPointMake(_headerStickyWidth, 0)];
            [_collectionView setContentOffset:CGPointMake(childContenOffSetX+mainContentOffsetX-_headerStickyWidth, 0)];
        }else if (mainContentOffsetX < _headerStickyWidth){
            if (childContenOffSetX != 0 ) {
                [_containerView setContentOffset:CGPointMake(_headerStickyWidth, 0)];
                [_collectionView setContentOffset:CGPointMake(childContenOffSetX+mainContentOffsetX-_headerStickyWidth, 0)];
            }
        }
            
        
    }else{
        NSLog(@"childScrolling");
        if (mainContentOffsetX < _headerStickyWidth) {
            //没吸顶前子View先不动 让父view代替动
            [_collectionView setContentOffset:CGPointMake(0, 0)];
            [_containerView setContentOffset:CGPointMake(mainContentOffsetX+childContenOffSetX, 0)];
        }else if (mainContentOffsetX == _headerStickyWidth){
            if (childContenOffSetX < 0) {
                [_collectionView setContentOffset:CGPointMake(0, 0)];
                [_containerView setContentOffset:CGPointMake(mainContentOffsetX+childContenOffSetX, 0)];
            }
        }
        //限制可滑动的最大距离
        if (childContenOffSetX > _maxLength){
            [_collectionView setContentOffset:CGPointMake(_maxLength, 0)];
        }
    }
}



#pragma mark - collectionview dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{

return UIEdgeInsetsMake(0, 5, 0, 5);//分别为上、左、下、右

}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowsInSection:section];
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    id<CellModelProtocol> cellModel = (id<CellModelProtocol>)[self.viewModel cellModelAtIndexPath:indexPath];
    UICollectionViewCell<CellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellModel.cellIdentifier forIndexPath:indexPath];
    //进来默认选中第一个
    if (_selectedModel == nil && indexPath.item == 0) {
        cellModel.isSelected = YES;
        _selectedModel = cellModel;
    }
    [cell configureByModel:cellModel];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id<CellModelProtocol> cellModel = (id<CellModelProtocol>)[self.viewModel cellModelAtIndexPath:indexPath];
    return [NSClassFromString(cellModel.cellIdentifier) sizeForCell:cellModel.isSelected];


}
@end
