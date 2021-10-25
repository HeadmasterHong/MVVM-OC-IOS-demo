//
//  WeatherViewModel.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/11.
//

#import <Foundation/Foundation.h>
#import "WeatherModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^succ)(id datas);
typedef void(^fail)(void);

@interface WeatherViewModel : NSObject
- (NSString *)getTempCurr;
- (instancetype)initWithSucc:(succ)succ fail:(fail)fail;
- (void)getWeatherByDict:(NSDictionary *)dict;
@property (atomic, strong)WeatherModel *weatherModel;
@end

NS_ASSUME_NONNULL_END
