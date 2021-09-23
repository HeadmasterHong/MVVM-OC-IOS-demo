//
//  LightArtRefreshHeader.m
//  LightArt
//
//  Created by 彭利章 on 2018/4/10.
//

#import "LightArtRefreshHeader.h"

@interface LightArtRefreshHeader ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) LightArtUIView *lightArtUIView;

@end

@implementation LightArtRefreshHeader

- (instancetype)initWithLightArtUIView:(LightArtUIView *)lightArtUIView {
    self = [super init];
    if (self) {
        self.automaticallyChangeAlpha = NO;
        LightArtUIComponent *model = lightArtUIView.model;
        if ([lightArtUIView.model isKindOfClass:[LightArtSectionList class]]) {
            self.contentComponent = ((LightArtSectionList *)model).refresh.view;
            self.contentView = [LightArtUIView viewWithModel:self.contentComponent];
        }
        self.lightArtUIView = lightArtUIView;
    }
    return self;
}

- (void)prepare {
    [super prepare];
}

- (void)placeSubviews {
    [super placeSubviews];
    if (nil == self.contentView.superview) {
        self.mj_h = self.contentView.mj_h;
        self.mj_y = - self.mj_h - self.ignoredScrollViewContentInsetTop;
        
        self.contentView.la_top = self.contentView.mj_h;
        [self addSubview:self.contentView];
        
        // 固定不动的下拉刷新，需要遮盖，否则可能会透出来
        UIView *maskView = [[UIView alloc] initWithFrame:self.contentView.frame];
        // 背景色应该与scollView的父容器背景色一致
        maskView.backgroundColor = self.scrollView.superview.backgroundColor;
        [self addSubview:maskView];
    }
    [self.superview insertSubview:self atIndex:0];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.scrollView.contentOffset.y < 0) {
        self.contentView.la_top = self.contentView.mj_h + self.scrollView.contentOffset.y;
    } else {
        self.contentView.la_top = self.contentView.mj_h;
    }
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    Action *action = [[Action alloc] init];
    action.name = @"!emit";
    action.params = @{@"event": @"refresh_state_change", @"params": @{@"state": @(state)}};
    LightArtUIComponent *model = self.lightArtUIView.model;
    [model.lightArtDocument handleAction:action model:model];
//    Action *action = self.slv.model.actions[@"state_change"];
//    if (nil != action) {
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//        params[@"state"] = @(state);
//        action = [action translateWithArgs:params];
//        [self.lightArtUIView handleAction:action];
//    }
}

@end
