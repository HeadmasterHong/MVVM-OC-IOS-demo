//
//  ViewController.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "Person.h"
@interface ViewController () <VcBDelegate>

@property (nonatomic,strong) NSArray *listTeams;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSNumber *selectRow;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPAth = [bundle pathForResource:@"team" ofType:@"plist"];
    self.listTeams = [[NSArray alloc] initWithContentsOfFile:plistPAth];
    
    //使用comparator block进行排序
//    sel f.listTeams = [self.listTeams sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
//        NSDictionary *d1 = obj1;
//        NSDictionary *d2 = obj2;
//        return [[d1 objectForKey:@"name"] compare:[d2 objectForKey:@"name"]];
//    }];
    
    //使用descriptor来排序，descriptor本身只是一个获取keypath的工具，他能根据keypath进行排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.listTeams = [self.listTeams sortedArrayUsingDescriptors:sortDescriptors];
    
    //使用selector进行排序】
    self.listTeams = [self.listTeams sortedArrayUsingSelector:@selector(compare:)];
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + 10, self.view.frame.size.width - 20, self.view.frame.size.height - 20)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    [self.tableView setSeparatorStyle:UITableViewCellstyle];
    [self.view addSubview:self.tableView];
    

    
    
    self.navigationItem.title = @"选择国家";
    
    //notification
    //step：2 注册监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeLabelText:) name:@"labelTextNotification" object:nil];
    
    
    //FMDB
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docuPath stringByAppendingPathComponent:@"test.db"];
    NSLog(@"!!!dbPath= %@", dbPath);
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    [db open];
    if (!([db open])) {
        NSLog(@"fail DB");
        return;
    }
    NSString *sql = @"create table if not exists t_student ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,'name' TEXT NOT NULL, 'phone' TEXT NOT NULL,'score' INTEGER NOT NULL)";
    BOOL result = [db executeUpdate:sql];
    if (result) {
        NSLog(@"success");
    }
    
//    BOOL result2 = [db executeUpdate:@"insert into 't_student' (ID,name,phone,score) values (?,?,?,?)" withArgumentsInArray:@[@001, @"SuBingtian", @"13724186761", @983]];
//    if (result2) {
//        NSLog(@"insert into 't_studet' success");
//    }
//    else{
//        NSLog(@"fail");
//    }
//
    FMResultSet *result3 = [db executeQuery:@"select * from 't_student' where ID = ?" withArgumentsInArray:@[@001]];
//    NSMutableArray *arr = [NSMutableArray array];
    while ([result3 next]) {
        NSLog(@"%@n see if success",[result3 stringForColumn:@"name"]);
        UIAlertController *uac = [UIAlertController alertControllerWithTitle:@"success" message:[result3 stringForColumn:@"name"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noaction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"press cancel");
        }];
        UIAlertAction *yesaction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"press ok");
        }];
        [uac addAction:noaction];
        [uac addAction:yesaction];
        [self presentViewController:uac animated:YES completion:nil];
    }
    
    
    //AFNetworking框架
    AFHTTPSessionManager *Manger = [AFHTTPSessionManager manager];
    
    //使用字面量的方式创建字典
    NSDictionary *dict = @{@"app":@"weather.today", @"weaId":@"1", @"appkey":@"60647",@"sign":@"e743d88de4bbb5438263e1a7c19a1242", @"format":@"json"};
    NSString *webStr = @"https://sapi.k780.com";
    [Manger GET:webStr parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure");
    }];
    
    
    [db close];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%li section",section];;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(Cell == nil){
        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //确定当前cell的位置
    NSInteger row = [indexPath row]+[indexPath section]*2;
    NSDictionary *rowDict = [self.listTeams objectAtIndex:row];
    Cell.textLabel.text = [rowDict objectForKey:@"name"];
    NSString *imagePath = [rowDict objectForKey:@"image"];
    imagePath = [imagePath stringByAppendingString:@".png"];
    Cell.imageView.image = [UIImage imageNamed:imagePath];
    Cell.accessoryType = UITableViewCellAccessoryNone;
    return Cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nvc = self.navigationController;
    SecondViewController *second = [[SecondViewController alloc] init];
    
    //为VC B实现block
    second.block = ^(NSString *text) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        cell.textLabel.text = [NSString stringWithFormat:@"%@+%@",cell.textLabel.text,text];
        NSLog(@"使用Block实现");
    };
    
    second.delegate = self;
    [nvc pushViewController:second animated:YES];
    
    
    
}



- (void)changeLabelText:(NSNotification *)notification
{
    //step3:实现通知中心内部的方法
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    NSString *str = (NSString*)notification.object;
    cell.textLabel.text = [NSString stringWithFormat:@"%@+%@",cell.textLabel.text,str];
//    NSLog(@"接收到通知 %@ %li",notification.object, self.tableView.indexPathForSelectedRow);
    NSLog(@"使用Notification实现");
    
}


- (void)dealloc
{
    //strp4:消息发送完,要移除掉
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"labelTextNotification" object:nil];
}

//实现delegate方法
- (void)sendValue:(NSString *)value
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
//    NSString *str = (NSString*)notification.object;
    cell.textLabel.text = [NSString stringWithFormat:@"%@+%@",cell.textLabel.text,value];
    NSLog(@"使用Delegate实现");
}
@end

