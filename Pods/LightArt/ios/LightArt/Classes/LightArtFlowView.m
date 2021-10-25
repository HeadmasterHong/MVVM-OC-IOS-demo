//
//  LightArtFlowView.m
//  LightArt
//
//  Created by 彭利章 on 2018/3/22.
//

#import "LightArtFlowView.h"
#import "LightArtView.h"
#import <MJRefresh/MJRefresh.h>
#import "LightArtRefreshHeader.h"
#import "LightArtLoadMoreFooter.h"

@interface LightArtFlowView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation LightArtFlowView

- (BOOL)setupWithModel:(LightArtFlow *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    if (nil == self.components) {
        [self reloadData];
    } else {
        for (int i = 0; i < self.components.count; i++) {
            [self.components[i] setupWithModel:model.components[i]];
        }
        self.scrollView.contentOffset = CGPointMake(0, 0);
        [self refreshFrame];
    }
    return YES;
}

- (void)reallyReloadData {
    self.scrollView.contentOffset = CGPointMake(0, 0);
    if (nil == self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.scrollsToTop = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.scrollView];
    }
    LightArtFlow *model = (LightArtFlow *)self.model;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (nil != model.safe_areas) {
        inset = [model.safe_areas insetWithScreenWidth:model.screenWidth];
    }
    self.scrollView.contentInset = inset;
    self.scrollView.scrollIndicatorInsets = inset;
    for (LightArtUIView *view in self.components) {
        [view removeFromSuperview];
    }
    self.components = nil;
    for (LightArtUIComponent *component in model.components) {
        LightArtUIView *view = [LightArtUIView viewWithModel:component];
        [self.scrollView addSubview:view];
    }
    self.components = [model.components valueForKeyPath:@"view"];
    [self refreshFrame];
}

- (void)reallyRefreshFrame {
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat totalGravity = 0;
    LightArtUIView *lastView = nil;
    LightArtFlow *model = (LightArtFlow *)self.model;
    for (LightArtUIView *view in self.components) {
        [view refreshFrameWithParentSize:self.la_size];
        view.hidden = NO;
        if (LightArtDirectionVertical == model.direction) {
            view.la_left = 0;
            view.la_top = height;
            if (width < view.la_width) {
                width = view.la_width;
            }
            height = view.la_bottom;
        } else {
            view.la_left = width;
            view.la_top = 0;
            width = view.la_right;
            if (height < view.la_height) {
                height = view.la_height;
            }
        }
        lastView = view;
        totalGravity += view.model.gravity;
    }
    if (totalGravity > 0 && LightArtDirectionVertical == model.direction && self.la_height > height) {
        CGFloat t = self.la_height - height;
        CGFloat top = 0;
        for (LightArtUIView *view in self.components) {
            if (view.model.gravity > 0) {
                view.la_height += ceil(view.model.gravity / totalGravity * t);
                [view refreshFrame];
            }
            view.la_top = top;
            top = view.la_bottom;
        }
    } else if (totalGravity > 0 && LightArtDirectionHorizontal == model.direction && self.la_width > width) {
        CGFloat t = self.la_width - width;
        CGFloat left = 0;
        for (LightArtUIView *view in self.components) {
            if (view.model.gravity > 0) {
                view.la_width += ceil(view.model.gravity / totalGravity * t);
                [view refreshFrame];
            }
            view.la_left = left;
            left = view.la_right;
        }
    }
    if (0 == self.model.bounds.w.length) {
        // 宽度自适应
        self.la_width = width;
    }
    if (0 == self.model.bounds.h.length) {
        // 高度自适应
        self.la_height = height;
    }
    if (model.smart_overflow) {
        // 超出部分隐藏
        if (LightArtDirectionVertical == model.direction && height > self.la_height) {
            height = 0;
            for (LightArtUIView *view in self.components) {
                if (view.la_bottom > self.la_height) {
                    view.hidden = YES;
                } else {
                    height += view.la_height;
                }
            }
        } else if (LightArtDirectionHorizontal == model.direction && width > self.la_width) {
            width = 0;
            for (LightArtUIView *view in self.components) {
                if (view.la_right > self.la_width) {
                    view.hidden = YES;
                } else {
                    width += view.la_width;
                }
            }
        }
    }
    self.scrollView.la_size = self.la_size;
    self.scrollView.contentSize = CGSizeMake(width, height);
    if (LightArtDirectionVertical == model.direction) {
        self.scrollView.scrollEnabled = height > self.la_height;
    } else {
        self.scrollView.scrollEnabled = width > self.la_width;
    }
}

@end
