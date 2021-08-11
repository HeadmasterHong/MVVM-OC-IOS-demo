//
//  ViewController.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "Person.h"
#import "SelfCenterVC.h"
#import "MainTableDataSource.h"
#import "TableCell.h"
#import "TeamModel.h"
#import "WeatherViewModel.h"
//#import "UIButton+WebCache.h"
@interface ViewController () <VcBDelegate>

@property (nonatomic,strong) NSDictionary *dictTeams;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSNumber *selectRow;
@property (nonatomic, strong) MainTableDataSource *dataSource;
@property (nonatomic, strong) WeatherViewModel *weatherViewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindModel];
    [self initView];
}



-(void)bindModel{
    //设置datasource
    self.dataSource = [[MainTableDataSource alloc] initWithCellIdentifier:@"CellIdentifier" configure:^(TableCell* cell,TeamModel* model, NSIndexPath * _Nonnull indexPath) {
        
        cell.textLabel.text = model.name;
        NSString *imagePath = model.image;
        imagePath = [imagePath stringByAppendingString:@".png"];
        cell.imageView.image = [UIImage imageNamed:imagePath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }];
    self.weatherViewModel = [[WeatherViewModel alloc] initWithSucc:^(id  _Nonnull datas) {
        UIAlertController *uac = [UIAlertController alertControllerWithTitle:@"success" message:datas preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noaction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *yesaction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [uac addAction:noaction];
        [uac addAction:yesaction];
        [self presentViewController:uac animated:YES completion:nil];
    } fail:^{
        
    }];
}

- (void)initView{
    //设置tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x , self.view.frame.origin.y , self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self.dataSource;
    [self.view addSubview:self.tableView];
    
    //自定义顶部导航栏
    self.navigationItem.title = @"选择国家";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]  initWithTitle:@"查看天气" style:UIBarButtonItemStylePlain target:self action:@selector(clickButtonWeather)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithTitle:@"个人中心" style:UIBarButtonItemStylePlain target:self action:@selector(clickButtonCenter)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nvc = self.navigationController;
    SecondViewController *second = [[SecondViewController alloc] init];
    second.delegate = self;
    [nvc pushViewController:second animated:YES];
}

//实现SecondView的delegate
- (void)sendValue:(NSString *)value
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    cell.textLabel.text = [NSString stringWithFormat:@"%@+%@",cell.textLabel.text,value];
    NSLog(@"使用Delegate实现");
}

//查看天气按钮,网络请求,异步操作,使用block回调
- (void)clickButtonWeather
{
    [self.weatherViewModel getWeatherByDict:@{@"app":@"weather.today", @"weaId":@"1", @"appkey":@"60647",@"sign":@"e743d88de4bbb5438263e1a7c19a1242", @"format":@"json"}];
}

//个人中心按钮
- (void)clickButtonCenter
{
    UINavigationController *nvc = self.navigationController;
    SelfCenterVC *sc = [[SelfCenterVC alloc] init];
    sc.search_id = 358;
    [nvc pushViewController:sc animated:YES];
}
@end
