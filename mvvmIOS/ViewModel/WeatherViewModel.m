//
//  WeatherViewModel.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/11.
//

#import "WeatherViewModel.h"
#import "AFNetworking.h"
#import "YYModel.h"

@interface WeatherViewModel()
@property (nonatomic, copy) succ succ;/**<请求成功*/

@property (nonatomic, copy) fail fail;/**<请求成功*/

@end

@implementation WeatherViewModel
- (instancetype)initWithSucc:(succ)succ fail:(fail)fail{
    self = [super init];
    if (self) {
        _succ = succ;
        _fail = fail;
    }
    return self;
}
- (void)getWeatherByDict:(NSDictionary *)dict{
    AFHTTPSessionManager *Manger = [AFHTTPSessionManager manager];
    //使用字面量的方式创建参数字典
    NSString *webStr = @"https://sapi.k780.com";
    [Manger GET:webStr parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.weatherModel = [WeatherModel yy_modelWithJSON:[responseObject objectForKey:@"result"]];
        NSLog(@">>>%@",self.weatherModel.temperature_curr);
        NSLog(@">>>%@",self);
        if (self.succ) {
            self.succ(self.weatherModel.temperature_curr);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure%@",error);
        
    }];
}
- (NSString *)getTempCurr{
    return self.weatherModel.temperature_curr;
}
@end
