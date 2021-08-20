//
//  SecondViewController.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "SecondViewController.h"
#import "SecondViewModel.h"
#import "Cell.h"

@interface SecondViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SecondViewModel *viewModel;
@property (nonatomic, assign) NSInteger layoutFlag;
@end


@implementation SecondViewController
- (void)viewDidLoad {
    [super viewDidLoad];
//    dispatch_group_t group = dispatch_group_create();
//
//    dispatch_group_enter(group);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self bindModel];
//        dispatch_group_leave(group);
//    });
    
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self initView];
//    });
}

- (void)bindModel{
    self.viewModel = [[SecondViewModel alloc] initSelf];
    self.layoutFlag = 0;//初始布局
}
- (void)initView{
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout =[[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((self.view.frame.size.width-20)*0.5, (self.view.frame.size.width-20)*0.6);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    [self registerCell];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    
    self.navigationItem.title = @"选择项目";
    [self.view addSubview:self.collectionView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]  initWithTitle:@"切换布局" style:UIBarButtonItemStylePlain target:self action:@selector(clickButtonLayout)];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = (Cell *)[_collectionView cellForItemAtIndexPath:[[_collectionView indexPathsForSelectedItems] firstObject]];
    NSString *str = cell.textLabel.text;
    if ([_delegate respondsToSelector:@selector(sendValue:)]) {
        [_delegate sendValue:str];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)registerCell
{
    [SecondViewModel enumerateCellClassNamesUsingBlock:^(NSString * _Nonnull cellClassName) {
        if(cellClassName) {
            [self.collectionView registerClass:NSClassFromString(cellClassName) forCellWithReuseIdentifier:cellClassName];
        }
    }];
}

- (void)clickButtonLayout{
    self.layoutFlag = [self.viewModel changeLayout:self.layoutFlag];
    [self.collectionView reloadData];
}

#pragma dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.viewModel numberOfSections:self.layoutFlag];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowsInSection:section:self.layoutFlag];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    id<CellModelProtocol> cellModel = (id<CellModelProtocol>)[self.viewModel cellModelAtIndexPath:indexPath];
    UICollectionViewCell<CellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellModel.cellIdentifier forIndexPath:indexPath];
    
    
    [cell configureByModel:cellModel];

    return cell;
}

@end
