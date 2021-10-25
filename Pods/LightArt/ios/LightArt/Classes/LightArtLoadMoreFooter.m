//
//  LightArtRefreshFooter.m
//  LightArt
//
//  Created by 彭利章 on 2018/6/5.
//

#import "LightArtLoadMoreFooter.h"

@interface LightArtLoadMoreFooter ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) LightArtUIView *lightArtUIView;

@end

@implementation LightArtLoadMoreFooter

- (instancetype)initWithLightArtUIView:(LightArtUIView *)lightArtUIView {
    self = [super init];
    if (self) {
        self.automaticallyChangeAlpha = NO;
        LightArtUIComponent *model = lightArtUIView.model;
        if ([lightArtUIView.model isKindOfClass:[LightArtSectionList class]]) {
            self.contentComponent = ((LightArtSectionList *)model).load_more.view;
            self.contentView = [LightArtUIView viewWithModel:self.contentComponent];
        }
        self.lightArtUIView = lightArtUIView;
        
        self.mj_h = self.contentView.mj_h;
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    Action *action = [[Action alloc] init];
    action.name = @"!emit";
    action.params = @{@"event": @"load_more_state_change", @"params": @{@"state": @(state)}};
    LightArtUIComponent *model = self.lightArtUIView.model;
    [model.lightArtDocument handleAction:action model:model];
}

@end
