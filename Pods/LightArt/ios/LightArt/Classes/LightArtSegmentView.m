//
//  LightArtSegmentView.m
//  LightArt
//
//  Created by 彭利章 on 2018/8/1.
//

#import "LightArtSegmentView.h"
#import "LightArtButtonView.h"

@interface LightArtSegmentView () <LightArtButtonViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *components;

@end

@implementation LightArtSegmentView

- (BOOL)setupWithModel:(LightArtSegment *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    [self reloadData];
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
    LightArtSegment *model = (LightArtSegment *)self.model;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (nil != model.safe_areas) {
        inset = [model.safe_areas insetWithScreenWidth:model.screenWidth];
    }
    self.scrollView.contentInset = inset;
    self.scrollView.scrollIndicatorInsets = inset;
    for (LightArtUIView *view in self.components) {
        [view removeFromSuperview];
    }
    self.components = [NSMutableArray array];
    for (LightArtUIComponent *component in model.buttons) {
        LightArtUIView *view = [LightArtUIView viewWithModel:component];
        if ([view isKindOfClass:[LightArtButtonView class]]) {
            [(LightArtButtonView *)view setDelegate:self];
        }
        [self.scrollView addSubview:view];
        [self.components addObject:view];
    }
    [self refreshFrame];
    [self refreshButtonViewWithIndex:model.selected_index state:LightArtButtonStateSelected];
}

- (void)reallyRefreshFrame {
    CGFloat width = 0;
    CGFloat height = 0;
    LightArtUIView *lastView = nil;
    LightArtSegment *model = (LightArtSegment *)self.model;
    for (LightArtUIView *view in self.components) {
        [view refreshFrameWithParentSize:self.la_size];
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
    }
    if (0 == self.model.bounds.w.length) {
        self.la_width = width;
    } else if (LightArtDirectionHorizontal == model.direction) {
        if (self.la_width > width) {
            CGFloat left = (self.la_width - width) / 2;
            if (LightArtAlignmentStart == model.align.h) {
                left = 0;
            } else if (LightArtAlignmentEnd == model.align.h) {
                left = self.la_width - width;
            }
            for (LightArtUIView *view in self.components) {
                view.la_left += left;
                view.la_top = (self.la_height - view.la_height) / 2;
            }
        }
    }
    if (0 == self.model.bounds.h.length) {
        self.la_height = height;
    } else if (LightArtDirectionVertical == model.direction) {
        if (self.la_height > height) {
            CGFloat top = (self.la_height - height) / 2;
            if (LightArtAlignmentStart == model.align.v) {
                top = 0;
            } else if (LightArtAlignmentEnd == model.align.v) {
                top = self.la_height - height;
            }
            for (LightArtUIView *view in self.components) {
                view.la_top += top;
                view.la_left = (self.la_width - view.la_width) / 2;
            }
        }
    }
    self.scrollView.la_size = self.la_size;
    self.scrollView.contentSize = CGSizeMake(width, height);
    self.scrollView.scrollEnabled = YES;
}

- (void)scrollButtonToCenter:(LightArtButtonView *)buttonView {
    LightArtSegment *model = (LightArtSegment *)self.model;
    CGSize contentSize = self.scrollView.contentSize;
    if (LightArtDirectionVertical == model.direction) {
        if (contentSize.height > self.scrollView.la_height) {
            CGFloat offsetY = 0;
            if (buttonView.la_height < self.scrollView.la_height) {
                offsetY = buttonView.center.y - self.scrollView.la_height / 2;
                if (offsetY < 0) {
                    offsetY = 0;
                } else if ((offsetY + self.scrollView.la_height) > contentSize.height) {
                    offsetY = contentSize.height - self.scrollView.la_height;
                }
            } else {
                offsetY = buttonView.la_top;
            }
            [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        }
    } else {
        if (contentSize.width > self.scrollView.la_width) {
            CGFloat offsetX = 0;
            if (buttonView.la_width < self.scrollView.la_width) {
                offsetX = buttonView.center.x - self.scrollView.la_width / 2;
                if (offsetX < 0) {
                    offsetX = 0;
                } else if ((offsetX + self.scrollView.la_width) > contentSize.width) {
                    offsetX = contentSize.width - self.scrollView.la_width;
                }
            } else {
                offsetX = buttonView.la_left;
            }
            [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        }
    }
}

- (void)refreshButtonViewWithIndex:(NSUInteger)index state:(LightArtButtonState)state {
    if (index < self.components.count) {
        LightArtButtonView *buttonView = self.components[index];
        buttonView.state = state;
        if (LightArtButtonStateSelected == state) {
             [self scrollButtonToCenter:buttonView];
        }
    }
}

#pragma mark - LightArtButtonViewDelegate

- (void)lightArtButtonViewDidTouchUpInside:(LightArtButtonView *)buttonView {
    NSUInteger index = [self.components indexOfObject:buttonView];
    self.selectedIndex = index;
}

#pragma mark - Setters

- (void)setSelectedIndex:(NSUInteger)index {
    if (NSNotFound != index) {
        if ([self.delegate lightArtSegmentView:self shouldSelectIndex:index]) {
            LightArtSegment *model = (LightArtSegment *)self.model;
            [self refreshButtonViewWithIndex:model.selected_index state:LightArtButtonStateNormal];
            model.selected_index = index;
            [self refreshButtonViewWithIndex:model.selected_index state:LightArtButtonStateSelected];
            [self.delegate lightArtSegmentView:self didSelectIndex:index];
        }
    }
}

#pragma mark - Getters

- (NSUInteger)selectedIndex {
    LightArtSegment *model = (LightArtSegment *)self.model;
    return model.selected_index;
}

@end
