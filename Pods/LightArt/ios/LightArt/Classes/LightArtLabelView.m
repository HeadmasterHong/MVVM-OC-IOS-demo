//
//  LightArtLabelView.m
//  LightArt
//
//  Created by 彭利章 on 2018/3/22.
//

#import "LightArtLabelView.h"

typedef enum {
    LightArtUILabelVerticalAlignmentCenter = 0,
    LightArtUILabelVerticalAlignmentTop,
    LightArtUILabelVerticalAlignmentBottom,
} LightArtUILabelVerticalAlignment;

@interface LightArtUILabel : UILabel

@property (nonatomic, assign) LightArtUILabelVerticalAlignment textVerticalAlignment;

@end

@implementation LightArtUILabel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textVerticalAlignment = LightArtUILabelVerticalAlignmentCenter;
    }
    return self;
}

- (void)setTextVerticalAlignment:(LightArtUILabelVerticalAlignment)a {
    _textVerticalAlignment = a;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.textVerticalAlignment) {
        case LightArtUILabelVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case LightArtUILabelVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case LightArtUILabelVerticalAlignmentCenter:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
    return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end

@interface LightArtLabelView ()

@property (nonatomic, strong) LightArtUILabel *label;

@end

@implementation LightArtLabelView

- (BOOL)setupWithModel:(LightArtLabel *)model {
    if (![super setupWithModel:model]) {
        return NO;
    }
    if (nil == self.label) {
        self.label = [[LightArtUILabel alloc] init];
        self.label.layer.masksToBounds = YES;
        [self addSubview:self.label];
    }
    if (nil == model.background.image.url) {
        // 防止过多的color blend
        self.label.backgroundColor = self.backgroundColor;
    } else {
        self.label.backgroundColor = [UIColor clearColor];
    }
    self.label.numberOfLines = model.max_lines;
    self.label.textVerticalAlignment = LightArtUILabelVerticalAlignmentCenter;
    if (LightArtAlignmentStart == model.align.v) {
        self.label.textVerticalAlignment = LightArtUILabelVerticalAlignmentTop;
    } else if (LightArtAlignmentCenter == model.align.v) {
        self.label.textVerticalAlignment = LightArtUILabelVerticalAlignmentCenter;
    } else if (LightArtAlignmentEnd == model.align.v) {
        self.label.textVerticalAlignment = LightArtUILabelVerticalAlignmentBottom;
    }
    self.label.attributedText = [self attributedString];
    [self refreshFrame];
    return YES;
}

- (NSMutableAttributedString *)attributedString {
    LightArtLabel *model = (LightArtLabel *)self.model;
    if (0 == model.text.length) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:model.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (LightArtAlignmentStart == model.ellipsize) {
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
    } else if (LightArtAlignmentCenter == model.ellipsize) {
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    } else if (LightArtAlignmentEnd == model.ellipsize) {
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    if (nil != model.align) {
        if (LightArtAlignmentStart == model.align.h) {
            paragraphStyle.alignment = NSTextAlignmentLeft;
        } else if (LightArtAlignmentCenter == model.align.h) {
            paragraphStyle.alignment = NSTextAlignmentCenter;
        } else if (LightArtAlignmentEnd == model.align.h) {
            paragraphStyle.alignment = NSTextAlignmentRight;
        }
    }
    UIColor *textColor = [UIColor blackColor];
    if (0 != model.font.color.length) {
        UIColor *color = [UIColor colorWithHexString:model.font.color];
        if (nil != color) {
            textColor = color;
        }
    }
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, model.text.length)];
    
    UIFont *font = [model.font fontWithScreenWidth:model.screenWidth];
    if (nil != font) {
        [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, model.text.length)];
        if (0 != model.font.line_height.length) {
            CGFloat lineSpacing = [Bounds pixelWithString:model.font.line_height screenWidth:model.screenWidth] - font.lineHeight;
            if (lineSpacing > 0) {
                paragraphStyle.lineSpacing = lineSpacing;
            }
        }
    }
    if (model.strikethrough) {
        NSRange range = NSMakeRange(0, model.text.length);
        [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
        [attributedString addAttribute:NSBaselineOffsetAttributeName value:@(0) range:range];
    }
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, model.text.length)];
    return attributedString;
}

- (void)reallyRefreshFrame {
    if (0 == self.model.bounds.w.length || 0 == self.model.bounds.h.length) {
        if (0 != self.model.bounds.w.length) {
            self.label.la_width = self.la_width;
        } else {
            self.label.la_width = CGFLOAT_MAX;
        }
        if (0 != self.model.bounds.h.length) {
            self.label.la_height = self.la_height;
        } else {
            self.label.la_height = CGFLOAT_MAX;
        }
        [self.label sizeToFit];
        if (0 == self.model.bounds.w.length) {
            self.la_width = self.label.la_width;
        } else {
            self.label.la_width = self.la_width;
        }
        if (0 == self.model.bounds.h.length) {
            self.la_height = self.label.la_height;
        } else {
            self.label.la_height = self.la_height;
        }
    }
    self.la_width = ceil(self.la_width);
    self.la_height = ceil(self.la_height);
    self.label.la_size = self.la_size;
}

@end
