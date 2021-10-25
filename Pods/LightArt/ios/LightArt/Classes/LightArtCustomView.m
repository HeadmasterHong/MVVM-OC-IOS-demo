//
//  LightArtCustomView.m
//  LightArt
//
//  Created by 彭利章 on 2018/5/28.
//

#import "LightArtCustomView.h"
#import "LightArtView.h"

@interface LightArtCustomView ()

@end

@implementation LightArtCustomView

- (BOOL)setupWithModel:(LightArtCustom *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    [self.contentView removeFromSuperview];
    LightArtView *lightArtView = self.model.lightArtDocument.view;
    id <LightArtServiceProtocol> lightArtService = [lightArtView lightArtService];
    UIView *reusableView = nil;
    if ([self.contentIdentifier isEqual:model.contentIdentifier]) {
        reusableView = self.contentView;
    } else {
        self.contentView = nil;
        self.contentIdentifier = model.contentIdentifier;
    }
    if ([lightArtService respondsToSelector:@selector(customViewWithType:size:indexPath:params:lightArtView:model:reusableView:)]) {
        self.contentView = [lightArtService customViewWithType:model.name size:self.la_size indexPath:[model indexPath] params:model.params lightArtView:lightArtView model:model.contentModel reusableView:reusableView];
        [self addSubview:self.contentView];
    }
    [self refreshFrame];
    return YES;
}

- (void)reallyRefreshFrame {
    if (0 == self.model.bounds.w.length) {
        self.la_width = self.contentView.la_width;
    } else {
        self.contentView.la_width = self.la_width;
    }
    if (0 == self.model.bounds.h.length) {
        self.la_height = self.contentView.la_height;
    } else {
        self.contentView.la_height = self.la_height;
    }
}

@end
