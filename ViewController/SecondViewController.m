//
//  SecondViewController.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "SecondViewController.h"
#import "Cell.h"
#import "CollectionDataSource.h"
@interface SecondViewController () <UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CollectionDataSource *dataSource;
@end

@implementation SecondViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindModel];
    [self initView];
}

- (void)bindModel{
    self.dataSource = [[CollectionDataSource alloc] initWithCellIdentifier:@"Cell"];
}
- (void)initView{
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout =[[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((self.view.frame.size.width-20)*0.5, (self.view.frame.size.width-20)*0.6);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    
    self.navigationItem.title = @"选择项目";
    [self.view addSubview:self.collectionView];
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


@end
