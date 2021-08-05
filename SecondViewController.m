//
//  SecondViewController.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "SecondViewController.h"
#import "Cell.h"

@interface SecondViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *  events;

@end

@implementation SecondViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pilstPath = [bundle pathForResource:@"events" ofType:@"plist"];
    NSArray *dict = [[NSArray alloc] initWithContentsOfFile:pilstPath];
    self.events = dict;
    
    //UI
    
    //创建flowLayout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //行与行间的距离
    flowLayout.minimumLineSpacing = 10;
    //列与列间的距离
    flowLayout.minimumInteritemSpacing = 10;
    //设置item的大小
    flowLayout.itemSize = CGSizeMake(110, 200);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    //！！！！！！！！！！！！！这个注册很重要啊！！！！！
//    [_collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];

    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + 10, self.view.frame.size.width - 20, self.view.frame.size.height - 20) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    
    self.navigationItem.title = @"选择项目";
    [self.view addSubview:self.collectionView];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.events count]/2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *event = [self.events objectAtIndex:(indexPath.section*2 + indexPath.row)];
    
    cell.textLabel.text = [event objectForKey:@"name"];
    cell.imgView.image = [UIImage imageNamed:[event objectForKey:@"image"]];
    
//    cell.imgView.image = [UIImage imageNamed:[event objectForKey:@"image"]];
//
//    cell.textLabel.text = [NSString stringWithFormat:@"Cell %ld",indexPath.item];


    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *event = [self.events objectAtIndex:(indexPath.section*2 + indexPath.row)];
    NSLog(@"select event name : %@", [event objectForKey:@"name"]);
    
    Cell *cell = (Cell *)[_collectionView cellForItemAtIndexPath:[[_collectionView indexPathsForSelectedItems] firstObject]];
    NSString *str = cell.textLabel.text;
    if ([_delegate respondsToSelector:@selector(sendValue:)]) {
        [_delegate sendValue:str];
    }
    //step1:注册将要通知
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"labelTextNotification" object:[event objectForKey:@"name"]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //类型转换问题：稍后查阅下
//    Cell *cell = (Cell *)[_collectionView cellForItemAtIndexPath:[[_collectionView indexPathsForSelectedItems] firstObject]];
//    NSString *str = cell.textLabel.text;
    //判断block
//    if (_block) {
////        NSLog(@"%@",[_collectionView cellForItemAtIndexPath:[[self.collectionView indexPathsForSelectedItems] firstObject]]);
//        _block(str);
//    }
    
}
@end
