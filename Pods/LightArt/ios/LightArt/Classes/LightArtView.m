//
//  LightArtView.m
//  lightart
//
//  Created by 彭利章 on 2018/3/9.
//  Copyright © 2018年 bingwu. All rights reserved.
//

#import "LightArtView.h"
#import "LightArtUIView.h"
#import "LightArtSectionListView.h"
#import "LightArtParser.h"

static id <LightArtServiceProtocol> gLightArtService = nil;

@implementation LightArtViewConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectZero;
        self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    }
    return self;
}

@end

@interface LightArtView ()

@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *body;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) LightArtUIView *rootView;
@property (nonatomic, weak) id<LightArtServiceProtocol> lightArtService;
@property (nonatomic, assign) CGSize oldSize;

@end

@implementation LightArtView

+ (NSString *)lightArtSDKVersion {
    return LIGHTART_SDK_VERSION;
}

+ (NSString *)lightArtVersion {
    return LIGHTART_VERSION;
}

+ (void)registerLightArtService:(id <LightArtServiceProtocol>)service {
    gLightArtService = service;
}

- (void)registerLightArtService:(id <LightArtServiceProtocol>)service {
    self.lightArtService = service;
}

- (id <LightArtServiceProtocol>)lightArtService {
    return _lightArtService ?: gLightArtService;
}

- (instancetype)initWithFrame:(CGRect)frame json:(NSDictionary *)json {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithDocument:nil json:json url:nil service:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame json:(NSDictionary *)json service:(id <LightArtServiceProtocol>)lightArtService {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithDocument:nil json:json url:nil service:lightArtService];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithDocument:nil json:nil url:url service:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url service:(id <LightArtServiceProtocol>)lightArtService {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithDocument:nil json:nil url:url service:lightArtService];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame document:(LightArtDocument *)document {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithDocument:document json:nil url:nil service:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame document:(LightArtDocument *)document service:(id <LightArtServiceProtocol>)lightArtService {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithDocument:document json:nil url:nil service:lightArtService];
    }
    return self;
}

- (void)initWithDocument:(LightArtDocument *)document json:(NSDictionary *)json url:(NSString *)url service:(id <LightArtServiceProtocol>)lightArtService {
    self.clipsToBounds = YES;
    self.lightArtService = lightArtService;
    self.json = json;
    self.url = url;
    
    if (0 != self.json.count || 0 != self.url.length) {
        [self refresh];
    } else {
        if ([self checkDocument:document]) {
            self.document = document;
            [self didFinishLoad];
        } else {
            [self didFailLoadWithError:nil];
        }
    }
}

- (instancetype)initWithConfig:(LightArtViewConfig *)config {
    self = [super initWithFrame:config.frame];
    if (self) {
        [self initWithDocument:config.document json:config.json url:config.url service:config.lightArtService];
        self.screenWidth = config.screenWidth;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.la_size, self.oldSize)) {
        self.oldSize = self.la_size;
        [self.rootView refreshFrameWithParentSize:self.la_size];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return self.rootView.la_size;
}

- (NSString *)identifier {
    return [self.rootView identifier];
}

#pragma mark - Public

- (void)refresh {
    if (0 != self.json.count) {
        LightArtDocument *model = [[LightArtDocument alloc] initWithJSONObject:self.json];
        if ([self checkDocument:model]) {
            self.document = model;
            [self didFinishLoad];
        } else {
            [self didFailLoadWithError:nil];
        }
    } else if (0 != self.url.length) {
        [self loadData];
    }
}

#pragma mark - Private

- (void)loadData {
    id <LightArtServiceProtocol> lightArtService = [self lightArtService];
    [lightArtService loadDataWithUrl:self.url method:@"GET" params:nil headers:nil succuss:^(NSURLSessionDataTask *task, id responseObject) {
        if (nil == task && nil != self.document) {
            // 刷新时不接受缓存数据
            return;
        }
        if ([responseObject isKindOfClass:[NSDictionary class]] && nil != responseObject[@"$lightart"]) {
            LightArtDocument *model = [[LightArtDocument alloc] initWithJSONObject:responseObject];
            if ([self checkDocument:model]) {
                self.isCacheDocument = nil == task;
                self.document = model;
                [self didFinishLoad];
            } else {
                [self didFailLoadWithError:nil];
            }
        } else {
            [self didFailLoadWithError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didFailLoadWithError:error];
    }];
}

- (BOOL)checkDocument:(LightArtDocument *)document {
    return nil != document.root && nil != document.translatedLightArt;
}

- (void)didFinishLoad {
    Action *action = [_document eventActionWithName:@"!on_load"];
    if (nil != action) {
        [self.document handleAction:action model:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(lightArtViewDidFinishLoad:)]) {
            [self.delegate lightArtViewDidFinishLoad:self];
        }
    });
}

- (void)didFailLoadWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(lightArtView:didFailLoadWithError:)]) {
            [self.delegate lightArtView:self didFailLoadWithError:error];
        }
    });
}

#pragma mark - LightArtEvent

- (NSString *)addObserverForEvent:(NSString *)event componentId:(NSString *)componentId usingBlock:(void (^)(NSDictionary *userInfo))block {
    return [self.document addObserverForEvent:event componentId:componentId usingBlock:block];
}

- (void)removeObserver:(NSString *)token {
    [self.document removeObserver:token];
}

- (void)sendEvent:(NSString *)event params:(NSDictionary *)params componentId:(NSString *)componentId {
    [self.document sendEvent:event params:params componentId:componentId];
}

#pragma mark - Setters

- (void)setDocument:(LightArtDocument *)document {
    if (![self checkDocument:document]) {
        return;
    }
    _document = document;
    _document.view = self;
    if ([[self.document.root identifier] isEqual:[self.rootView identifier]]) {
        [self.rootView setupWithModel:self.document.root];
    } else {
        [self.rootView removeFromSuperview];
        self.rootView = [LightArtUIView viewWithModel:self.document.root];
    }
    [self addSubview:self.rootView];
    self.oldSize = self.la_size;
}

- (void)setScreenWidth:(CGFloat)screenWidth {
    if (screenWidth > 0 && _screenWidth != screenWidth) {
        _screenWidth = screenWidth;
        [self.rootView setupWithModel:self.document.root];
    }
}

@end
