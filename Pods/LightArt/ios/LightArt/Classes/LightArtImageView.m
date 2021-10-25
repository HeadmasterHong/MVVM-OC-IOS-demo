//
//  LightArtImageView.m
//  LightArt
//
//  Created by 彭利章 on 2018/3/22.
//

#import "LightArtImageView.h"
#import "LightArtView.h"

@interface LightArtImageView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LightArtImageView

- (BOOL)setupWithModel:(LightArtImage *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    if (nil == self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.imageView];
    }
    self.imageView.image = nil;
    self.imageView.contentMode = model.default_scale_type;
    UIImage *placeholder = nil;
    id <LightArtServiceProtocol> lightArtService = [self.model.lightArtDocument.view lightArtService];
    if (0 != model.default_url.length) {
        NSURL *url = [NSURL URLWithString:model.default_url];
        placeholder = [lightArtService imageFromCacheForURL:url];
        self.imageView.image = placeholder;
        if (nil == placeholder) {
            [lightArtService loadImageWithURL:url completed:^(UIImage *image, NSURL *url) {

            }];
        }
    }
    if (0 != model.url.length) {
        [lightArtService loadImageWithURL:[NSURL URLWithString:model.url] imageView:self.imageView placeholder:placeholder completed:^(UIImage *image, NSURL *url) {
            self.imageView.contentMode = model.scale_type;
            if (!image && 0 != model.error_url.length) {
                self.imageView.contentMode = model.error_scale_type;
                [lightArtService loadImageWithURL:[NSURL URLWithString:model.error_url] imageView:self.imageView placeholder:placeholder completed:^(UIImage *image, NSURL *url) {
                    
                }];
            }
        }];
    }
    [self refreshFrame];
    return YES;
}

- (void)reallyRefreshFrame {
    self.imageView.la_size = self.la_size;
}

@end
