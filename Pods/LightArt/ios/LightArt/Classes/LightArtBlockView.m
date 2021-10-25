//
//  LightArtBlockView.m
//  LightArt
//
//  Created by 彭利章 on 2018/3/22.
//

#import "LightArtBlockView.h"

@interface LightArtBlockView ()

@end

@implementation LightArtBlockView

- (BOOL)setupWithModel:(LightArtBlock *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    if (nil == self.components) {
        [self reloadData];
    } else {
        for (int i = 0; i < self.components.count; i++) {
            [self.components[i] setupWithModel:model.components[i]];
        }
        NSMutableArray *components = [model.components mutableCopy];
        [components sortUsingComparator:^NSComparisonResult(LightArtUIComponent *obj1, LightArtUIComponent *obj2) {
            if (obj1.z_index < obj2.z_index) {
                return NSOrderedAscending;
            } else if (obj1.z_index > obj2.z_index) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        for (LightArtUIComponent *component in components) {
            LightArtUIView *view = component.view;
            [self addSubview:view];
        }
        [self refreshFrame];
    }
    return YES;
}

- (void)reallyReloadData {
    for (LightArtUIView *view in self.components) {
        [view removeFromSuperview];
    }
    self.components = nil;
    LightArtBlock *model = (LightArtBlock *)self.model;
    NSMutableArray *components = [model.components mutableCopy];
    [components sortUsingComparator:^NSComparisonResult(LightArtUIComponent *obj1, LightArtUIComponent *obj2) {
        if (obj1.z_index < obj2.z_index) {
            return NSOrderedAscending;
        } else if (obj1.z_index > obj2.z_index) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    for (LightArtUIComponent *component in components) {
        LightArtUIView *view = [LightArtUIView viewWithModel:component];
        [self addSubview:view];
    }
    self.components = [model.components valueForKeyPath:@"view"];
    
    [self refreshFrame];
}

- (void)reallyRefreshFrame {
    CGFloat width = 0;
    CGFloat height = 0;
    for (LightArtUIView *view in self.components) {
        [view refreshFrameWithParentSize:self.la_size];
        if (width < view.la_right) {
            width = view.la_right;
        }
        if (height < view.la_bottom) {
            height = view.la_bottom;
        }
    }
    if (0 == self.model.bounds.w.length) {
        self.la_width = width;
    }
    if (0 == self.model.bounds.h.length) {
        self.la_height = height;
    }
    // 需要确保self.la_size先计算出来，所以放到最后
    for (LightArtUIView *view in self.components) {
        LightArtUIComponent *component = view.model;
        if (nil != component.layout_align) {
            if (LightArtAlignmentStart == component.layout_align.h) {
                view.la_left = 0;
            } else if (LightArtAlignmentCenter == component.layout_align.h) {
                view.la_left = (self.la_width - view.la_width) / 2;
            } else if (LightArtAlignmentEnd == component.layout_align.h) {
                view.la_right = self.la_width;
            }
            if (LightArtAlignmentStart == component.layout_align.v) {
                view.la_top = 0;
            } else if (LightArtAlignmentCenter == component.layout_align.v) {
                view.la_top = (self.la_height - view.la_height) / 2;
            } else if (LightArtAlignmentEnd == component.layout_align.v) {
                view.la_bottom = self.la_height;
            }
        }
    }
}

@end
