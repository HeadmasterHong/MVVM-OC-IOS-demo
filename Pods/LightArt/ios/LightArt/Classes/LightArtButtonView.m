//
//  LightArtButton.m
//  LightArt
//
//  Created by 彭利章 on 2018/8/1.
//

#import "LightArtButtonView.h"

@interface LightArtButtonView ()

@property (nonatomic, strong) LightArtUIView *normalView;
@property (nonatomic, strong) LightArtUIView *selectedView;
@property (nonatomic, strong) LightArtUIView *highlightedView;

@end

@implementation LightArtButtonView

- (BOOL)setupWithModel:(LightArtButton *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    [self reloadData];
    return YES;
}

- (void)reallyReloadData {
    LightArtButton *model = (LightArtButton *)self.model;
    [self.normalView removeFromSuperview];
    self.normalView = nil;
    if (nil != model.normal) {
        self.normalView = [LightArtUIView viewWithModel:model.normal];
        self.normalView.userInteractionEnabled = NO;
        [self addSubview:self.normalView];
    }
    [self.selectedView removeFromSuperview];
    self.selectedView = nil;
    if (nil != model.selected) {
        self.selectedView = [LightArtUIView viewWithModel:model.selected];
        self.selectedView.userInteractionEnabled = NO;
        [self addSubview:self.selectedView];
    }
    [self.highlightedView removeFromSuperview];
    self.highlightedView = nil;
    if (nil != model.highlighted) {
        self.highlightedView = [LightArtUIView viewWithModel:model.highlighted];
        self.highlightedView.userInteractionEnabled = NO;
        [self addSubview:self.highlightedView];
    }
    [self refreshFrame];
    [self refreshContent];
}

- (void)reallyRefreshFrame {
    CGFloat width = 0;
    CGFloat height = 0;
    NSMutableArray *components = [NSMutableArray array];
    if (nil != self.normalView) {
        [components addObject:self.normalView];
    }
    if (nil != self.selectedView) {
        [components addObject:self.selectedView];
    }
    if (nil != self.highlightedView) {
        [components addObject:self.highlightedView];
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

- (void)refreshContent {
    LightArtButton *model = (LightArtButton *)self.model;
    if (LightArtButtonStateNormal == model.state && nil != self.normalView) {
        self.normalView.hidden = NO;
        self.selectedView.hidden = YES;
        self.highlightedView.hidden = YES;
    } else if (LightArtButtonStateSelected == model.state && nil != self.selectedView) {
        self.normalView.hidden = YES;
        self.selectedView.hidden = NO;
        self.highlightedView.hidden = YES;
    } else if (LightArtButtonStateHighlighted == model.state && nil != self.highlightedView) {
        self.normalView.hidden = YES;
        self.selectedView.hidden = YES;
        self.highlightedView.hidden = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    LightArtButton *model = (LightArtButton *)self.model;
    if (LightArtButtonStateSelected != model.state) {
        model.state = LightArtButtonStateHighlighted;
        [self refreshContent];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    LightArtButton *model = (LightArtButton *)self.model;
    if (LightArtButtonStateSelected != model.state) {
        model.state = LightArtButtonStateHighlighted;
        [self refreshContent];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    LightArtButton *model = (LightArtButton *)self.model;
    if (LightArtButtonStateSelected != model.state) {
        model.state = LightArtButtonStateNormal;
        [self refreshContent];
    }
    if ([self.delegate respondsToSelector:@selector(lightArtButtonViewDidTouchUpInside:)]) {
        [self.delegate lightArtButtonViewDidTouchUpInside:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    LightArtButton *model = (LightArtButton *)self.model;
    if (LightArtButtonStateSelected != model.state) {
        model.state = LightArtButtonStateNormal;
        [self refreshContent];
    }
}

#pragma mark - Setters

- (void)setState:(LightArtButtonState)state {
    LightArtButton *model = (LightArtButton *)self.model;
    model.state = state;
    [self refreshContent];
}

#pragma mark - Getters

- (LightArtButtonState)state {
    LightArtButton *model = (LightArtButton *)self.model;
    return model.state;
}

@end
