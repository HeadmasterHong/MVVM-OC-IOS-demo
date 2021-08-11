//
//  WeatherModel.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface WeatherModel : NSObject
@property (nonatomic,copy) NSString *citynm;//城市名称
@property (nonatomic,copy) NSString *teaperature;//温度区间
@property (nonatomic,copy) NSString *aqi;//pm2.5
@property (nonatomic,copy) NSString *weather;//天气概括
@property (nonatomic,copy) NSString *wind;//风力
@property (nonatomic,copy) NSString *temperature_curr;//实时温度

@end

NS_ASSUME_NONNULL_END
