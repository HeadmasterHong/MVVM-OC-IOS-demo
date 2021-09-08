//
//  LightArtAsyncBoxView.m
//  LightArt
//
//  Created by 彭利章 on 2018/8/9.
//

#import "LightArtAsyncBoxView.h"
#import "LightArtView.h"

@interface LightArtAsyncBoxView ()

@property (nonatomic, strong) LightArtUIView *errorView;
@property (nonatomic, strong) LightArtUIView *loadingView;
@property (nonatomic, strong) LightArtUIView *contentView;

@end

@implementation LightArtAsyncBoxView

- (BOOL)setupWithModel:(LightArtAsyncBox *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    [self reloadData];
    return YES;
}

- (void)reallyReloadData {
    LightArtAsyncBox *model = (LightArtAsyncBox *)self.model;
    [self.errorView removeFromSuperview];
    self.errorView = (LightArtUIView *)[LightArtUIView viewWithModel:model.error];
    self.errorView.hidden = YES;
    [self addSubview:self.errorView];
    [self.loadingView removeFromSuperview];
    self.loadingView = (LightArtUIView *)[LightArtUIView viewWithModel:model.loading];
    self.loadingView.hidden = YES;
    [self addSubview:self.loadingView];
    
    if (nil != model.content) {
        self.contentView = [LightArtUIView viewWithModel:model.content];
        [self addSubview:self.contentView];
    } else if (nil != model.template && nil != model.data) {
        [self parse];
    } else {
        self.loadingView.hidden = NO;
        self.errorView.hidden = YES;
        id <LightArtServiceProtocol> lightArtService = [model.lightArtDocument.view lightArtService];
        if (lightArtService && [lightArtService respondsToSelector:@selector(loadDataWithUrl:method:params:headers:succuss:failure:)]) {
            NSString *url = nil;
            if (nil == model.template && 0 != model.template_url.length && nil != model.data) {
                url = model.template_url;
            } else if (nil == model.data && 0 != model.data_url.length && nil != model.template) {
                url = model.data_url;
            } else if (0 != model.url.length) {
                url = model.url;
            }
            [lightArtService loadDataWithUrl:url method:nil params:nil headers:nil succuss:^(NSURLSessionDataTask *task, id responseObject) {
                [self componentDidFinishLoad];
                id template = responseObject[@"template"];
                if (nil != template) {
                    model.template = template;
                }
                id data = responseObject[@"data"];
                if (nil != data) {
                    model.data = data;
                }
                if (nil == model.template || nil == model.data) {
                    [self componentDidFailLoadWithError:nil];
                    self.loadingView.hidden = YES;
                    self.errorView.hidden = NO;
                    return;
                }
                [self parse];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self componentDidFailLoadWithError:error];
                self.loadingView.hidden = YES;
                self.errorView.hidden = NO;
            }];
        }
    }
    [self refreshFrame];
}

- (void)reallyRefreshFrame {
    CGFloat width = 0;
    CGFloat height = 0;
    NSMutableArray *components = [NSMutableArray array];
    if (nil != self.errorView) {
        [components addObject:self.errorView];
    }
    if (nil != self.loadingView) {
        [components addObject:self.loadingView];
    }
    if (nil != self.contentView) {
        [components addObject:self.contentView];
    }
    for (LightArtUIView *view in components) {
        [view refreshFrameWithParentSize:self.la_size];
        if (width < view.la_right) {
            width = view.la_right;
        }
        if (height < view.la_height) {
            height = view.la_height;
        }
    }
    if (0 == self.model.bounds.w.length) {
        self.la_width = width;
    }
    if (0 == self.model.bounds.h.length) {
        self.la_height = height;
    }
    for (LightArtUIView *view in components) {
        view.la_left = (self.la_width - view.la_width) / 2;
        view.la_top = (self.la_height - view.la_height) / 2;
    }
}

- (void)parse {
    LightArtAsyncBox *model = (LightArtAsyncBox *)self.model;
    [model.lightArtDocument asynParseWithTemplate:model.template data:model.data block:^(id result) {
        self.loadingView.hidden = YES;
        self.errorView.hidden = YES;
        model.content = result;
        model.content.parent = model;
        self.contentView = [LightArtUIView viewWithModel:model.content];
        [self addSubview:self.contentView];
        [self refreshFrame];
    }];
}

- (void)componentDidFinishLoad {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtView:componentDidFinishLoad:)]) {
        NSString *componentId = self.model.component_id;
        [delegate lightArtView:lightArtView componentDidFinishLoad:componentId];
    }
}

- (void)componentDidFailLoadWithError:(NSError *)error {
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtViewDelegate> delegate = lightArtView.delegate;
    if ([delegate respondsToSelector:@selector(lightArtView:component:didFailLoadWithError:)]) {
        NSString *componentId = self.model.component_id;
        [delegate lightArtView:lightArtView component:componentId didFailLoadWithError:error];
    }
}

@end
