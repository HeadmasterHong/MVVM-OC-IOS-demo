//
//  LightArtView.h
//  lightart
//
//  Created by 彭利章 on 2018/3/9.
//  Copyright © 2018年 bingwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LightArtDocument.h"

typedef void(^LightArtServiceSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^LightArtServiceFailureBlock)(NSURLSessionDataTask *task, NSError *error);

typedef NS_ENUM(NSInteger, LightArtRefreshState) {
    /** 普通闲置状态 */
    LightArtRefreshStateIdle = 1,
    /** 松开就可以进行刷新的状态 */
    LightArtRefreshStatePulling,
    /** 正在刷新中的状态 */
    LightArtRefreshStateRefreshing,
    /** 即将刷新的状态 */
    LightArtRefreshStateWillRefresh,
    /** 所有数据加载完毕，没有更多的数据了 */
    LightArtRefreshStateNoMoreData
};

@protocol LightArtServiceProtocol <NSObject>

- (NSURLSessionDataTask *)loadDataWithUrl:(NSString *)url method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers succuss:(LightArtServiceSuccessBlock)success failure:(LightArtServiceFailureBlock)failure;

- (void)sendClickStatistics:(id)context indexPath:(NSString *)indexPath business:(id)business;
- (void)sendExposeStatistics:(id)context indexPath:(NSString *)indexPath business:(id)business;

- (BOOL)routeToUrl:(NSString *)url indexPath:(NSString *)indexPath business:(id)business;

- (BOOL)cachedImageExistsForURL:(NSURL *)url;
- (UIImage *)imageFromCacheForURL:(NSURL *)url;
- (void)loadImageWithURL:(NSURL *)url completed:(void (^)(UIImage *image, NSURL *url))completedBlock;
- (void)loadImageWithURL:(NSURL *)url imageView:(UIImageView *)imageView completed:(void (^)(UIImage *image, NSURL *url))completedBlock;
- (void)loadImageWithURL:(NSURL *)url imageView:(UIImageView *)imageView placeholder:(UIImage *)placeholder completed:(void (^)(UIImage *image, NSURL *url))completedBlock;

- (UIView *)customViewWithType:(NSString *)type size:(CGSize)size indexPath:(NSString *)indexPath params:(NSDictionary *)params lightArtView:(LightArtView *)lightArtView model:(id)model reusableView:(UIView *)reusableView;

- (NSDate *)serverDate;

@optional
- (NSString *)identifierForCustomViewType:(NSString *)type params:(NSDictionary *)params model:(id *)model;

@end

@protocol LightArtCustomContentViewDelegate <NSObject>

- (void)exposedStateDidChanged:(BOOL)exposed;

@end

@class LightArtView;

@protocol LightArtViewDelegate <NSObject>

@optional
- (void)lightArtViewDidFinishLoad:(LightArtView *)lightArtView;
- (void)lightArtView:(LightArtView *)lightArtView didFailLoadWithError:(NSError *)error;
- (void)lightArtViewDidFinishReload:(LightArtView *)lightArtView;
- (void)lightArtView:(LightArtView *)lightArtView didFailReloadWithError:(NSError *)error;
- (void)lightArtView:(LightArtView *)lightArtView component:(NSString *)componentId didFailLoadWithError:(NSError *)error;
- (void)lightArtView:(LightArtView *)lightArtView componentDidFinishLoad:(NSString *)componentId;
- (void)lightArtView:(LightArtView *)lightArtView component:(NSString *)componentId scrollViewDidScroll:(UIScrollView *)scrollView;
- (BOOL)lightArtView:(LightArtView *)lightArtView component:(NSString *)componentId gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

@end

@interface LightArtViewConfig : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) LightArtDocument *document;
@property (nonatomic, strong) id <LightArtServiceProtocol> lightArtService;
@property (nonatomic, assign) CGFloat screenWidth;

@end

@interface LightArtView : UIView

@property (nonatomic, strong) LightArtDocument *document;
@property (nonatomic, strong) id (^clickStatisticsConstructor)(id context, NSString *indexPath, id business);
@property (nonatomic, strong) id (^exposeStatisticsConstructor)(id context, NSString *indexPath, id business);
@property (nonatomic, weak) id <LightArtViewDelegate> delegate;
@property (nonatomic, assign) BOOL isCacheDocument;
@property (nonatomic, assign) CGFloat screenWidth;

+ (NSString *)lightArtSDKVersion;
+ (NSString *)lightArtVersion;

+ (void)registerLightArtService:(id <LightArtServiceProtocol>)service;
- (void)registerLightArtService:(id <LightArtServiceProtocol>)service;
- (id <LightArtServiceProtocol>)lightArtService;

- (instancetype)initWithFrame:(CGRect)frame json:(NSDictionary *)json;
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url;
- (instancetype)initWithFrame:(CGRect)frame document:(LightArtDocument *)document;
- (instancetype)initWithFrame:(CGRect)frame json:(NSDictionary *)json service:(id <LightArtServiceProtocol>)lightArtService;
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url service:(id <LightArtServiceProtocol>)lightArtService;
- (instancetype)initWithFrame:(CGRect)frame document:(LightArtDocument *)document service:(id <LightArtServiceProtocol>)lightArtService;
- (instancetype)initWithConfig:(LightArtViewConfig *)config;

- (void)refresh;

- (NSString *)addObserverForEvent:(NSString *)event componentId:(NSString *)componentId usingBlock:(void (^)(NSDictionary *userInfo))block;
- (void)removeObserver:(NSString *)token;
- (void)sendEvent:(NSString *)event params:(NSDictionary *)params componentId:(NSString *)componentId;
- (NSString *)identifier;

@end
