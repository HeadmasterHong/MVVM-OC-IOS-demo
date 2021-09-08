//
//  LightArtTabView.m
//  LightArt
//
//  Created by 彭利章 on 2018/8/3.
//

#import "LightArtTabView.h"
#import "LightArtSegmentView.h"
#import "LightArtView.h"

@interface LightArtTabView () <LightArtSegmentViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) LightArtSegmentView *segmentView;
@property (nonatomic, strong) UIScrollView *contentPanel;
@property (nonatomic, strong) NSMutableDictionary *contentViewDic;

@end

@implementation LightArtTabView

- (BOOL)setupWithModel:(LightArtTab *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    [self reloadData];
    return YES;
}

- (void)reallyReloadData {
    LightArtTab *model = (LightArtTab *)self.model;
    
    [self.segmentView removeFromSuperview];
    self.segmentView = (LightArtSegmentView *)[LightArtUIView viewWithModel:model.segment];
    self.segmentView.delegate = self;
    [self addSubview:self.segmentView];
    
    for (LightArtUIView *view in self.contentViewDic.allValues) {
        [view removeFromSuperview];
    }
    self.contentViewDic = [NSMutableDictionary dictionary];
    
    if (nil == self.contentPanel) {
        self.contentPanel = [[UIScrollView alloc] init];
        self.contentPanel.delegate = self;
        self.contentPanel.pagingEnabled = YES;
        self.contentPanel.scrollsToTop = NO;
        self.contentPanel.backgroundColor = [UIColor clearColor];
        self.contentPanel.showsVerticalScrollIndicator = NO;
        self.contentPanel.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.contentPanel.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.contentPanel];
    }
    
    [self refreshFrame];
    NSUInteger index = model.segment.selected_index;
    if ([self lightArtSegmentView:self.segmentView shouldSelectIndex:index]) {
        [self lightArtSegmentView:self.segmentView didSelectIndex:index];
    }
}

- (void)reallyRefreshFrame {
    [self.segmentView refreshFrameWithParentSize:self.la_size];
    LightArtTab *model = (LightArtTab *)self.model;
    if (0 == model.style.length || [@"t" isEqual:model.style]) {
        self.segmentView.la_left = (self.la_width - self.segmentView.la_width) / 2;
        self.segmentView.la_top = 0;
        self.contentPanel.frame = CGRectMake(0, self.segmentView.la_bottom, self.la_width, self.la_height - self.segmentView.la_height);
        self.contentPanel.contentSize = CGSizeMake(model.contents.count * self.contentPanel.la_width, self.contentPanel.la_height);
    } else if ([@"l" isEqual:model.style]) {
        self.segmentView.la_left = 0;
        self.segmentView.la_top = (self.la_height - self.segmentView.la_height) / 2;
        self.contentPanel.frame = CGRectMake(self.segmentView.la_right, 0, self.la_width - self.segmentView.la_width, self.la_height);
        self.contentPanel.contentSize = CGSizeMake(self.contentPanel.la_width, model.contents.count * self.contentPanel.la_height);
        self.contentPanel.scrollEnabled = NO;
    } else if ([@"r" isEqual:model.style]) {
        self.segmentView.la_right = self.la_width;
        self.segmentView.la_top = (self.la_height - self.segmentView.la_height) / 2;
        self.contentPanel.frame = CGRectMake(0, 0, self.la_width - self.segmentView.la_width, self.la_height);
        self.contentPanel.contentSize = CGSizeMake(self.contentPanel.la_width, model.contents.count * self.contentPanel.la_height);
        self.contentPanel.scrollEnabled = NO;
    } else if ([@"b" isEqual:model.style]) {
        self.segmentView.la_left = (self.la_width - self.segmentView.la_width) / 2;
        self.segmentView.la_bottom = self.la_height;
        self.contentPanel.frame = CGRectMake(0, 0, self.la_width, self.la_height - self.segmentView.la_height);
        self.contentPanel.contentSize = CGSizeMake(model.contents.count * self.contentPanel.la_width, self.contentPanel.la_height);
    }
    for (LightArtUIView *view in self.contentViewDic.allValues) {
        CGFloat left = view.la_left;
        CGFloat top = view.la_top;
        [view refreshFrameWithParentSize:self.contentPanel.la_size];
        view.la_left = left;
        view.la_top = top;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger index = 0;
    LightArtTab *model = (LightArtTab *)self.model;
    if (0 == model.style.length || [@"t" isEqual:model.style] || [@"b" isEqual:model.style]) {
        index = scrollView.contentOffset.x / scrollView.la_width + 0.5;
    } else if ([@"l" isEqual:model.style] || [@"r" isEqual:model.style]) {
        index = scrollView.contentOffset.y / scrollView.la_height + 0.5;
    }
    self.segmentView.selectedIndex = index;
}

#pragma mark - LightArtSegmentViewDelegate

- (BOOL)lightArtSegmentView:(LightArtSegmentView *)segmentView shouldSelectIndex:(NSUInteger)index {
    LightArtTab *model = (LightArtTab *)self.model;
    if (index < model.contents.count) {
        LightArtUIComponent *content = model.contents[model.segment.selected_index];
        if (nil != content.view) {
            // 可以考虑释放节约内存
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)lightArtSegmentView:(LightArtSegmentView *)segmentView didSelectIndex:(NSUInteger)index {
    LightArtTab *model = (LightArtTab *)self.model;
    
    CGPoint offset = CGPointZero;
    if (0 == model.style.length || [@"t" isEqual:model.style] || [@"b" isEqual:model.style]) {
        offset.x = model.segment.selected_index * self.contentPanel.la_width;
    } else if ([@"l" isEqual:model.style] || [@"r" isEqual:model.style]) {
        offset.y = model.segment.selected_index * self.contentPanel.la_height;
    }
    
    LightArtUIComponent *content = model.contents[model.segment.selected_index];
    NSString *key = [@(model.segment.selected_index) description];
    LightArtUIView *view = self.contentViewDic[key];
    if (nil == view) {
        view = [LightArtUIView viewWithModel:content];
        [view refreshFrameWithParentSize:self.contentPanel.la_size];
        [self.contentPanel addSubview:view];
        [self.contentViewDic setObject:view forKey:key];
    }
    if (0 == model.style.length || [@"t" isEqual:model.style] || [@"b" isEqual:model.style]) {
        view.la_left = offset.x + (self.contentPanel.la_width - view.la_width) / 2;
        view.la_top = (self.contentPanel.la_height - view.la_height) / 2;
    } else if ([@"l" isEqual:model.style] || [@"r" isEqual:model.style]) {
        view.la_left = (self.contentPanel.la_width - view.la_width) / 2;
        view.la_top = offset.y + (self.contentPanel.la_height - view.la_height) / 2;
    }
    [self.contentPanel setContentOffset:offset animated:NO];
}

@end
