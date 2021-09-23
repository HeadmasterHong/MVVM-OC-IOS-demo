//
//  LightArtUIView.m
//  LightArt
//
//  Created by 彭利章 on 2018/3/22.
//

#import "LightArtUIView.h"
#import "LightArtLabelView.h"
#import "LightArtImageView.h"
#import "LightArtCountdownView.h"
#import "LightArtBlockView.h"
#import "LightArtFlowView.h"
#import "LightArtView.h"
#import "LightArtParser.h"
#import <YYModel/YYModel.h>
#import "LightArtSectionListView.h"
#import "LightArtCustomView.h"
#import "LightArtButtonView.h"
#import "LightArtSegmentView.h"
#import "LightArtAsyncBoxView.h"
#import "LightArtTabView.h"
#import "LightArtAsyncBoxView.h"

@implementation UIColor (LightArt)

+ (CGFloat) colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha = 0, red = 0, blue = 0, green = 0;
    switch ([colorString length]) {
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue  = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #RRGGBBAA
            red   = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue  = [self colorComponentFrom:colorString start:4 length:2];
            alpha = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            return nil;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

@implementation UIView (LightArt)

- (CGFloat)la_left {
    return CGRectGetMinX(self.frame);
}

- (void)setLa_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)la_top {
    return CGRectGetMinY(self.frame);
}

- (void)setLa_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)la_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setLa_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)la_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setLa_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)la_width {
    return CGRectGetWidth(self.frame);
}

- (void)setLa_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)la_height {
    return CGRectGetHeight(self.frame);
}

- (void)setLa_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)la_origin {
    return self.frame.origin;
}

- (void)setLa_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)la_size {
    return self.frame.size;
}

- (void)setLa_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

@interface LightArtUIView () <CAAnimationDelegate>

@property (nonatomic, strong) LightArtUIComponent *model;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) BOOL isRefreshingFrame;
@property (nonatomic, assign) BOOL isReloadingData;

@end

@implementation LightArtUIView

+ (LightArtUIView *)viewWithModel:(LightArtUIComponent *)model {
    if ([model isKindOfClass:[LightArtLabel class]]) {
        return [[LightArtLabelView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtImage class]]) {
        return [[LightArtImageView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtCountdown class]]) {
        return [[LightArtCountdownView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtBlock class]]) {
        return [[LightArtBlockView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtFlow class]]) {
        return [[LightArtFlowView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtSectionList class]]) {
        return [[LightArtSectionListView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtCustom class]]) {
        return [[LightArtCustomView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtButton class]]) {
        return [[LightArtButtonView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtSegment class]]) {
        return [[LightArtSegmentView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtAsyncBox class]]) {
        return [[LightArtAsyncBoxView alloc] initWithModel:model];
    } else if ([model isKindOfClass:[LightArtTab class]]) {
        return [[LightArtTabView alloc] initWithModel:model];
    } else {
        return [[LightArtUIView alloc] initWithModel:model];
    }
    return nil;
}

- (instancetype)initWithModel:(LightArtUIComponent *)model {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        [self setupWithModel:model];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)setupWithModel:(LightArtUIComponent *)model {
    if (nil == model) return NO;
    if (nil != self.model && ![model isKindOfClass:[self.model class]]) return NO;
    self.model = model;
    self.model.view = self;
    CGSize parentSize = CGSizeZero;
    if (nil != model.parent) {
        parentSize = model.parent.view.la_size;
    } else {
        parentSize = model.lightArtDocument.view.la_size;
    }
    self.frame = [model.bounds frameWithParentSize:parentSize screenWidth:model.screenWidth];
    // 不能用self.oldSizeValue，会触发parent.refreshFrame
    // 一定要在此赋值，以便refreshFrame后通过比较该值是否相同，来触发parent.refreshFrame
    _oldSizeValue = [NSValue valueWithCGSize:self.la_size];;
    [self refreshCornerAndBorder];
    self.alpha = self.model.alpha;
    [self.backgroundGradientLayer removeFromSuperlayer];
    self.backgroundImageView.image = nil;
    self.backgroundColor = [UIColor clearColor];
    if (0 != self.model.background.color.length) {
        self.backgroundColor = [UIColor colorWithHexString:self.model.background.color];
    } else if (0 != self.model.background.image.url) {
        if (nil == self.backgroundImageView) {
            self.backgroundImageView = [[UIImageView alloc] init];
            self.backgroundImageView.clipsToBounds = YES;
            self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self addSubview:self.backgroundImageView];
        }
        id <LightArtServiceProtocol> lightArtService = [self.model.lightArtDocument.view lightArtService];
        if (lightArtService && [lightArtService respondsToSelector:@selector(loadImageWithURL:imageView:completed:)]) {
            [lightArtService loadImageWithURL:[NSURL URLWithString:self.model.background.image.url] imageView:self.backgroundImageView completed:^(UIImage *image, NSURL *url) {
            }];
        }
    } else if (nil != self.model.background.gradient) {
        self.backgroundGradientLayer = [CAGradientLayer layer];
        self.backgroundGradientLayer.frame = self.bounds;
        NSMutableArray *colors = [NSMutableArray array];
        for (int i = 0; i < self.model.background.gradient.colors.count; i++) {
            NSString *colorString = self.model.background.gradient.colors[i];
            UIColor *color = [UIColor colorWithHexString:colorString];
            if (nil != color) {
                [colors addObject:(__bridge id)color.CGColor];
            }
        }
        self.backgroundGradientLayer.colors = colors;
        CGPoint startPoint = CGPointMake(0, 0);
        NSString *startX = self.model.background.gradient.start_x;
        if (0 != startX.length) {
            startPoint.x = startX.floatValue;
        }
        NSString *startY = self.model.background.gradient.start_y;
        if (0 != startY.length) {
            startPoint.y = startY.floatValue;
        }
        self.backgroundGradientLayer.startPoint = startPoint;
        CGPoint endPoint = CGPointMake(1, 0);
        NSString *endX = self.model.background.gradient.end_x;
        if (0 != endX.length) {
            endPoint.x = endX.floatValue;
        }
        NSString *endY = self.model.background.gradient.end_y;
        if (0 != endY.length) {
            endPoint.y = endY.floatValue;
        }
        self.backgroundGradientLayer.endPoint = endPoint;
        NSMutableArray *locations = [NSMutableArray array];
        for (int i = 0; i < self.model.background.gradient.locations.count; i++) {
            NSString *locationString = self.model.background.gradient.locations[i];
            [locations addObject:@(locationString.floatValue)];
        }
        self.backgroundGradientLayer.locations = locations;
        [self.layer addSublayer:self.backgroundGradientLayer];
    }
    if (nil != self.model.actions) {
        Action *action = self.model.actions[@"!click"];
        if (nil == action) {
            action = self.model.actions[@"click"];
        }
        if (nil != action) {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
            [self addGestureRecognizer:tapGestureRecognizer];
            self.tapGestureRecognizer = tapGestureRecognizer;
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (0 != self.model.animation.steps.count) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    [self startAnimation];
    
    Action *action = self.model.actions[@"!on_load"];
    if (nil != action && !self.model.loaded) {
        self.model.loaded = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.model.lightArtDocument handleAction:action model:self.model];
        });
    }
    return YES;
}

- (NSString *)identifier {
    if ([self isKindOfClass:[LightArtLabelView class]]) {
        return @"1";
    } else if ([self isKindOfClass:[LightArtImageView class]]) {
        return @"2";
    } else if ([self isKindOfClass:[LightArtCountdownView class]]) {
        return @"3";
    } else if ([self isKindOfClass:[LightArtBlockView class]]) {
        NSArray *components = [(LightArtBlockView *)self components];
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < components.count; i++) {
            LightArtUIView *c = components[i];
            if (0 != i) {
                [str appendString:@"-"];
            }
            [str appendString:[c identifier]];
        }
        return [@"4" stringByAppendingFormat:@"(%@)", str];
    } else if ([self isKindOfClass:[LightArtFlowView class]]) {
        NSArray *components = [(LightArtFlowView *)self components];
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < components.count; i++) {
            LightArtUIView *c = components[i];
            if (0 != i) {
                [str appendString:@"-"];
            }
            [str appendString:[c identifier]];
        }
        return [@"5" stringByAppendingFormat:@"(%@)", str];
    } else if ([self isKindOfClass:[LightArtSectionListView class]]) {
        return @"6";
    } else if ([self isKindOfClass:[LightArtCustomView class]]) {
        NSString *contentIdentifer = [(LightArtCustomView *)self contentIdentifier];
        if (nil != contentIdentifer) {
            return [@"7" stringByAppendingFormat:@"(%@)", contentIdentifer];
        } else {
            return @"7";
        }
    } else if ([self isKindOfClass:[LightArtButtonView class]]) {
        return @"8";
    } else if ([self isKindOfClass:[LightArtSegmentView class]]) {
        return @"9";
    } else if ([self isKindOfClass:[LightArtAsyncBoxView class]]) {
        return @"A";
    } else if ([self isKindOfClass:[LightArtTabView class]]) {
        return @"B";
    } else {
        return @"0";
    }
}

- (void)didMoveToWindow {
    if (nil != self.window) {
        [self startAnimation];
    } else {
        [self stopAnimation];
    }
    BOOL needDetectExpose = NO;
    if ([self isKindOfClass:[LightArtCustomView class]] && [[(LightArtCustomView *)self contentView] respondsToSelector:@selector(exposedStateDidChanged:)]) {
        needDetectExpose = YES;
    } else if (nil != self.model.statistics[@"expose"]) {
        needDetectExpose = YES;
    }
    if (!needDetectExpose) return;
    
    if (nil != self.window) {
        NSNumber *hash = @(self.hash);
        [LightArtUIView viewMap][hash] = self;
        [self maybeExpose];
    } else {
        NSNumber *hash = @(self.hash);
        [[LightArtUIView viewMap] removeObjectForKey:hash];
        [self unexpose];
    }
}

- (void)maybeExpose {
    // 如果从其他页面返回，虽然didMoveToWindow检测到已经添加到window上了，但此时checkVisible仍然为NO，所以需要延迟0.5秒检测
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakSelf checkVisible]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf checkVisible];
            });
        }
    });
}

- (void)expose {
    if (self.model.exposed) return;
    self.model.exposed = YES;
    id <LightArtCustomContentViewDelegate> contentView = nil;
    if ([self isKindOfClass:[LightArtCustomView class]]) {
        contentView = (id <LightArtCustomContentViewDelegate>)[(LightArtCustomView *)self contentView];
        if ([contentView respondsToSelector:@selector(exposedStateDidChanged:)]) {
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            formatter.dateFormat = @"HH:mm:ss.SSS";
//            [LightArtUIView log:[NSString stringWithFormat:@"%@ exposed Y %@ %@", [formatter stringFromDate:[NSDate date]], self.model, [contentView class]]];
            [contentView exposedStateDidChanged:self.model.exposed];
        }
    }
    [self sendExposeStatistics];
}

- (void)unexpose {
    self.model.visibleDate = nil;
    self.model.lastCheckIsVisible = NO;
    if (!self.model.exposed) return;
    self.model.exposed = NO;
    id <LightArtCustomContentViewDelegate> contentView = nil;
    if ([self isKindOfClass:[LightArtCustomView class]]) {
        contentView = (id <LightArtCustomContentViewDelegate>)[(LightArtCustomView *)self contentView];
        if ([contentView respondsToSelector:@selector(exposedStateDidChanged:)]) {
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            formatter.dateFormat = @"HH:mm:ss.SSS";
//            [LightArtUIView log:[NSString stringWithFormat:@"%@ exposed N %@ %@", [formatter stringFromDate:[NSDate date]], self.model, [contentView class]]];
            [contentView exposedStateDidChanged:self.model.exposed];
        }
    }
}

static NSMutableString *logString = nil;

+ (void)log:(NSString *)message {
//    if (nil == logString) {
//        logString = [NSMutableString string];
//    }
//    [logString appendString:message];
//    [logString appendString:@"\n"];
}

- (BOOL)checkVisible {
    BOOL isVisible = [self isVisible];
    if (self.model.lastCheckIsVisible && isVisible) {
        if (!self.model.exposed && nil != self.model.visibleDate) {
            NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self.model.visibleDate];
            if (delta > 0.5) {
                [self expose];
            }
        }
    } else if (isVisible) {
        self.model.visibleDate = [NSDate date];
        self.model.lastCheckIsVisible = YES;
    } else {
        [self unexpose];
    }
    return isVisible;
}

- (BOOL)isVisible {
    if (nil == self.window || nil == self.superview) {
        return NO;
    }
    
    if (self.hidden) {
        return NO;
    }
    
    if (CGRectIsEmpty(self.frame)) {
        return NO;
    }
    
    CGRect referRect = [UIScreen mainScreen].bounds;
    
    CGRect rect = [self convertRect:self.bounds toView:nil];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return NO;
    }
    
    CGRect intersectionRect = CGRectIntersection(rect, referRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return NO;
    }
    
    // 循环向上判断各级视图是否可视
    UIView *currentView = self;
    while (nil != currentView) {
        if (currentView.hidden || 0 == currentView.alpha || CGRectIsEmpty(currentView.frame)) {
            // 自身不可见
            return NO;
        }
        if (nil == currentView.superview) break;
        NSArray *array = currentView.superview.subviews;
        NSUInteger index = [array indexOfObject:currentView];
        if (NSNotFound != index) {
            for (NSUInteger i = index + 1; i < array.count; i++) {
                UIView *v = array[i];
                if (!v.hidden && 0 != v.alpha && CGRectContainsRect(v.frame, currentView.frame)) {
                    // 已被兄弟遮盖
                    return NO;
                }
            }
        }
        // 继续判断父视图
        currentView = currentView.superview;
    }
    
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (nil != self.backgroundImageView) {
        self.backgroundImageView.la_width = self.la_width;
        self.backgroundImageView.la_height = self.la_height;
    }
    
    if (nil != self.borderLayer) {
        [self.layer addSublayer:self.borderLayer];
    }
    
    if (nil != self.backgroundGradientLayer) {
        self.backgroundGradientLayer.frame = self.frame;
        [self.layer insertSublayer:self.backgroundGradientLayer atIndex:0];
    }
}

- (void)refreshCornerAndBorder {
    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = nil;
    self.layer.mask = nil;
    
    if ((nil != self.model.corner_radius && ![self.model.corner_radius isEmpty]) || nil != self.model.border) {
        NSString *rt = self.model.corner_radius.rt;
        CGFloat rtRadius = 0;
        if (0 != rt.length) {
            rtRadius = [Bounds pixelWithString:rt screenWidth:self.model.screenWidth];
            if (rtRadius < 0) {
                rtRadius = 0;
            }
        }
        NSString *rb = self.model.corner_radius.rb;
        CGFloat rbRadius = 0;
        if (0 != rb.length) {
            rbRadius = [Bounds pixelWithString:rb screenWidth:self.model.screenWidth];
            if (rbRadius < 0) {
                rbRadius = 0;
            }
        }
        NSString *lb = self.model.corner_radius.lb;
        CGFloat lbRadius = 0;
        if (0 != lb.length) {
            lbRadius = [Bounds pixelWithString:lb screenWidth:self.model.screenWidth];
            if (lbRadius < 0) {
                lbRadius = 0;
            }
        }
        NSString *lt = self.model.corner_radius.lt;
        CGFloat ltRadius = 0;
        if (0 != lt.length) {
            ltRadius = [Bounds pixelWithString:lt screenWidth:self.model.screenWidth];
            if (ltRadius < 0) {
                ltRadius = 0;
            }
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGFloat width = self.la_width;
        CGFloat height = self.la_height;
        
        {
            // 绘制第1条线和第1个1/4圆弧，右上圆弧
            CGFloat radius = rtRadius;
            CGPathMoveToPoint(path, NULL, radius, 0);
            CGPathAddLineToPoint(path, NULL, width - radius, 0);
            CGPathAddArc(path, NULL, width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
        }
        
        {
            // 绘制第2条线和第2个1/4圆弧，右下圆弧
            CGFloat radius = rbRadius;
            CGPathAddLineToPoint(path, NULL, width, height - radius);
            CGPathAddArc(path, NULL, width - radius, height - radius, radius, 0.0, 0.5 * M_PI, 0);
        }
        
        {
            // 绘制第3条线和第3个1/4圆弧，左下圆弧
            CGFloat radius = lbRadius;
            CGPathAddLineToPoint(path, NULL, radius, height);
            CGPathAddArc(path, NULL, radius, height - radius, radius, 0.5 * M_PI, M_PI, 0);
        }
        
        {
            // 绘制第4条线和第4个1/4圆弧，左上圆弧
            CGFloat radius = ltRadius;
            CGPathAddLineToPoint(path, NULL, 0, radius);
            CGPathAddArc(path, NULL, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
            CGPathCloseSubpath(path);
        }
        
        if (nil != self.model.border) {
            CAShapeLayer *borderLayer = [CAShapeLayer layer];
            borderLayer.frame = CGRectMake(0, 0, width, height);
            borderLayer.lineWidth = 2 * [Bounds pixelWithString:self.model.border.width screenWidth:self.model.screenWidth]; // 因为宽度一半在外侧，一半在内测
            borderLayer.strokeColor = [UIColor colorWithHexString:self.model.border.color].CGColor;
            borderLayer.fillColor = [UIColor clearColor].CGColor;
            borderLayer.path = path;
            [self.layer addSublayer:borderLayer];
            self.borderLayer = borderLayer;
        }
        
        if (0 != rtRadius || 0 != rbRadius || 0 != lbRadius || 0 != ltRadius) {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = path;
            self.layer.mask = shapeLayer;
        }
        
        CFRelease(path);
    }
}

- (void)onClick {
    id ctx = self.model.statistics[@"click"];
    if (nil != ctx) {
        id (^constructor)(id context, NSString *indexPath, id business) = self.model.lightArtDocument.view.clickStatisticsConstructor;
        if (nil != constructor) {
            ctx = constructor(ctx, [self.model indexPath], self.model.business);
        }
        if (nil != ctx) {
            id <LightArtServiceProtocol> lightArtService = [self.model.lightArtDocument.view lightArtService];
            if (lightArtService && [lightArtService respondsToSelector:@selector(sendClickStatistics:indexPath:business:)]) {
                [lightArtService sendClickStatistics:ctx indexPath:[self.model indexPath] business:self.model.business];
            }
        }
    }
    Action *action = self.model.actions[@"!click"];
    if (nil == action) {
        action = self.model.actions[@"click"];
    }
    [self.model.lightArtDocument handleAction:action model:self.model];
}

- (void)sendExposeStatistics {
    id ctx = self.model.statistics[@"expose"];
    if (nil != ctx) {
        id (^constructor)(id context, NSString *indexPath, id business) = self.model.lightArtDocument.view.exposeStatisticsConstructor;
        if (nil != constructor) {
            ctx = constructor(ctx, [self.model indexPath], self.model.business);
        }
        if (nil == ctx) {
            return;
        }
        id <LightArtServiceProtocol> lightArtService = [self.model.lightArtDocument.view lightArtService];
        if (lightArtService && [lightArtService respondsToSelector:@selector(sendExposeStatistics:indexPath:business:)]) {
            [lightArtService sendExposeStatistics:ctx indexPath:[self.model indexPath] business:self.model.business];
        }
    }
}

- (void)refreshFrameWithParentSize:(CGSize)parentSize {
    CGRect frame = self.frame;
    BOOL lp = [Bounds isPercentValue:self.model.bounds.l];
    BOOL tp = [Bounds isPercentValue:self.model.bounds.t];
    BOOL wp = [Bounds isPercentValue:self.model.bounds.w];
    BOOL hp = [Bounds isPercentValue:self.model.bounds.h];
    if (lp || tp || wp || hp) {
        if (lp) {
            frame.origin.x = [Bounds pixelWithString:self.model.bounds.l parent:parentSize.width screenWidth:self.model.screenWidth];
        }
        if (tp) {
            frame.origin.y = [Bounds pixelWithString:self.model.bounds.t parent:parentSize.height screenWidth:self.model.screenWidth];
        }
        if (wp) {
            frame.size.width = [Bounds pixelWithString:self.model.bounds.w parent:parentSize.width screenWidth:self.model.screenWidth];
        }
        if (hp) {
            frame.size.height = [Bounds pixelWithString:self.model.bounds.h parent:parentSize.height screenWidth:self.model.screenWidth];
        }
        if (!CGRectEqualToRect(frame, self.frame)) {
            self.frame = frame;
            [self refreshCornerAndBorder];
            [self refreshFrame];
        }
    }
}

- (void)reloadData {
    if (self.isReloadingData) return;
    self.isReloadingData = YES;
    [self reallyReloadData];
    self.isReloadingData = NO;
}

- (void)reallyReloadData {
    
}

- (void)refreshFrame {
    if (self.isRefreshingFrame) return;
    self.isRefreshingFrame = YES;
    [self reallyRefreshFrame];
    self.oldSizeValue = [NSValue valueWithCGSize:self.la_size];
    self.isRefreshingFrame = NO;
}

- (void)reallyRefreshFrame {
    
}

- (void)scrollTo:(NSDictionary *)params {
    
}

+ (NSMutableDictionary *)viewMap {
    static NSMutableDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [NSMutableDictionary dictionary];
    });
    return map;
}

+ (void)checkVisibleForAllViews {
    for (LightArtUIView *view in self.viewMap.allValues) {
        [view checkVisible];
    }
}

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

+ (void)applicationWillEnterForeground {
    for (LightArtUIView *view in self.viewMap.allValues) {
        if (nil != view.window) {
            [view maybeExpose];
        }
    }
}

+ (void)applicationDidEnterBackground {
    for (LightArtUIView *view in self.viewMap.allValues) {
        if (view.model.exposed) {
            [view unexpose];
        }
    }
}

#pragma mark - Setters

- (void)setOldSizeValue:(NSValue *)oldSizeValue {
    if (nil != _oldSizeValue && ![_oldSizeValue isEqual:oldSizeValue]) {
        [self refreshCornerAndBorder];
        LightArtUIComponent *parentComponent = self.model.parent;
        if (nil != parentComponent) {
            // 父节点reloadData引起的子节点size变化，不应再传导给父节点
            if (!parentComponent.view.isReloadingData) {
                [parentComponent.view refreshFrame];
            }
        } else {
            if (![self.model.bounds hasPercentValue]) {
//                [self.model.lightArtDocument.view refreshFrame];
            }
        }
    }
    _oldSizeValue = oldSizeValue;
}

#pragma mark - Animation

- (void)startAnimation {
    [self stopAnimation];
    if (nil == self.window) return;
    if (0 == self.model.animation.steps.count) return;
    int loop = self.model.animation.loop;
    if (loop >= 0 && self.model.animation.currentLoop >= loop) {
        return;
    }
    self.model.animation.currentLoop++;
    [self startAnimationWithIndex:0];
}

- (void)startAnimationWithIndex:(NSUInteger)index {
    if (index >= self.model.animation.steps.count) {
        [self startAnimation];
        return;
    }
    LightArtAnimationStep *step = self.model.animation.steps[index];
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.beginTime = CACurrentMediaTime() + step.delay;
    group.duration = step.duration;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    group.delegate = self;
    
    CATransform3D lastTransform = CATransform3DIdentity;
    CGFloat lastAlpha = self.model.alpha;
    if (index > 0) {
        LightArtAnimationStep *step = self.model.animation.steps[index - 1];
        NSValue *transform3DValue = [step transform3DValueWithScreenWidth:self.model.screenWidth];
        if (nil != transform3DValue) {
            lastTransform = transform3DValue.CATransform3DValue;
        }
        if (nil != step.alpha) {
            lastAlpha = step.alpha.floatValue;
        }
    }
    
    NSMutableArray *animations = [NSMutableArray array];
    NSValue *transform3DValue = [step transform3DValueWithScreenWidth:self.model.screenWidth];
    CABasicAnimation *transformAnimation = [CABasicAnimation animation];
    transformAnimation.keyPath = @"transform";
    if ([@"step_start" isEqual:step.timing_function] && nil != transform3DValue) {
        transformAnimation.fromValue = transform3DValue;
    } else {
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:lastTransform];
    }
    if (nil != transform3DValue) {
        transformAnimation.toValue = transform3DValue;
    } else {
        transformAnimation.toValue = [NSValue valueWithCATransform3D:lastTransform];
    }
    [animations addObject:transformAnimation];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animation];
    opacityAnimation.keyPath = @"opacity";
    if ([@"step_start" isEqual:step.timing_function] && nil != step.alpha) {
        opacityAnimation.fromValue = @(step.alpha.floatValue);
    } else {
        opacityAnimation.fromValue = @(lastAlpha);
    }
    if (nil != step.alpha) {
        opacityAnimation.toValue = @(step.alpha.floatValue);
    } else {
        opacityAnimation.toValue = @(lastAlpha);
    }
    [animations addObject:opacityAnimation];
    
    group.animations = animations;
    [group setValue:@(index) forKey:@"index"];
    
    [self.layer addAnimation:group forKey:[NSString stringWithFormat:@"LightArtAnimation_%lu", (unsigned long)index]];
}

- (void)stopAnimation {
    [self.layer removeAllAnimations];
    self.userInteractionEnabled = YES;
}

- (void)animationDidStart:(CAAnimation *)anim {
    self.userInteractionEnabled = YES;
    NSUInteger index = [[anim valueForKey:@"index"] unsignedIntegerValue];
    LightArtAnimationStep *step = self.model.animation.steps[index];
    if (nil != step.scale) {
        if (0 != step.scale.x.length && 0 == step.scale.x.floatValue) {
            self.userInteractionEnabled = NO;
        } else if (0 != step.scale.y.length && 0 == step.scale.y.floatValue) {
            self.userInteractionEnabled = NO;
        }
    }
    if (nil != step.alpha && 0 == step.alpha.floatValue) {
        self.userInteractionEnabled = NO;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSUInteger index = [[anim valueForKey:@"index"] unsignedIntegerValue];
    if (flag) {
        [self startAnimationWithIndex:index + 1];
    }
}

@end

@interface LAScrollEventEmitter : NSObject {
    NSTimeInterval _emitInterval;
    NSTimer *_scheduledTimer;
    BOOL _shouldEmit;
}

@end

@implementation LAScrollEventEmitter

+ (instancetype)sharedInstance {
    static LAScrollEventEmitter *emitter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emitter = [LAScrollEventEmitter new];
        [emitter startWithInterval:0];
    });
    return emitter;
}

- (void)startWithInterval:(NSTimeInterval)interval {
    [self stop];
    _emitInterval = interval > 0 ? interval : 0.5;
    _shouldEmit = YES;
}

- (void)stop {
    _shouldEmit = NO;
}

- (instancetype)initWithInterval:(NSTimeInterval)interval  {
    self = [super init];
    if (self) {
        _emitInterval = interval;
    }
    return self;
}

- (void)emitEvent {
    if (UIApplicationStateBackground == [UIApplication sharedApplication].applicationState) {
        return;
    }
    if (!_shouldEmit) {
        [_scheduledTimer invalidate];
    } else if (!_scheduledTimer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:_emitInterval target:self selector:@selector(checkVisibleForAllViews) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _scheduledTimer = timer;
    }
}

- (void)checkVisibleForAllViews {
    [LightArtUIView checkVisibleForAllViews];
    [_scheduledTimer invalidate];
    _scheduledTimer = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"] && [object isKindOfClass:[UIScrollView class]]) {
        NSValue *offsetNewValue = change[NSKeyValueChangeNewKey];
        NSValue *offsetOldValue = change[NSKeyValueChangeOldKey];
        if (nil != offsetNewValue && nil != offsetOldValue && !CGPointEqualToPoint(offsetNewValue.CGPointValue, offsetOldValue.CGPointValue)) {
            UIScrollView *scrollView = (UIScrollView *)object;
            if (scrollView.window) {
                [self emitEvent];
            }
        }
    }
}

@end

@interface UIScrollView (LightArt)

@end

@implementation UIScrollView (LightArt)

+ (void)load {
    if ([self class] == [UIScrollView class]) {
        [self la_swizzleInstanceMethodWithOriginSel:@selector(initWithFrame:) swizzledSel:@selector(la_initWithFrame:)];
        [self la_swizzleInstanceMethodWithOriginSel:@selector(initWithCoder:) swizzledSel:@selector(la_initWithCoder:)];
        [self la_swizzleInstanceMethodWithOriginSel:NSSelectorFromString(@"dealloc") swizzledSel:@selector(la_dealloc)];
    }
}

+ (void)la_swizzleInstanceMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Method oriSelMethod = class_getInstanceMethod(self, oriSel);
    Method swiSelMethod = class_getInstanceMethod(self, swiSel);
    [self la_swizzleMethodWithOriginSel:oriSel oriMethod:oriSelMethod swizzledSel:swiSel swizzledMethod:swiSelMethod class:self];
}

+ (void)la_swizzleMethodWithOriginSel:(SEL)oriSel
                              oriMethod:(Method)oriMethod
                            swizzledSel:(SEL)swizzledSel
                         swizzledMethod:(Method)swizzledMethod
                                  class:(Class)cls {
    BOOL didAddMethod = class_addMethod(cls, oriSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swizzledMethod);
    }
}

- (instancetype)la_initWithFrame:(CGRect)frame {
    return [[self la_initWithFrame:frame] la_setup];
}

- (instancetype)la_initWithCoder:(NSCoder *)coder {
    return [[self la_initWithCoder:coder] la_setup];
}

- (void)la_dealloc {
    [self removeObserver:[LAScrollEventEmitter sharedInstance] forKeyPath:@"contentOffset"];
    [self la_dealloc];
}

- (id)la_setup {
    [self addObserver:[LAScrollEventEmitter sharedInstance] forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    return self;
}

@end
