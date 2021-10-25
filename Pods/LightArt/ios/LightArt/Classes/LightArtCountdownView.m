//
//  LightArtCountdownView.m
//  LightArt
//
//  Created by 彭利章 on 2018/3/28.
//

#import "LightArtCountdownView.h"
#import "LightArtLabelView.h"
#import "LightArtDocument.h"
#import "LightArtView.h"

@interface LightArtCountdownView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) LightArtLabel *minLabel;
@property (nonatomic, strong) LightArtLabel *minLabel1;
@property (nonatomic, strong) LightArtLabel *minLabel0;
@property (nonatomic, strong) LightArtLabel *secondLabel;
@property (nonatomic, strong) LightArtLabel *secondLabel1;
@property (nonatomic, strong) LightArtLabel *secondLabel0;
@property (nonatomic, strong) LightArtLabel *tenthSecondLabel;
@property (nonatomic, assign) int fullHour;
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int second;
@property (nonatomic, assign) int tenthSecond;

@end

@implementation LightArtCountdownView

- (BOOL)setupWithModel:(LightArtCountdown *)model {
    [self.timer invalidate];
    LightArtCountdown *oldModel = (LightArtCountdown *)self.model;
    for (LightArtUIComponent *component in oldModel.components) {
        [component.view removeFromSuperview];
    }
    if (![super setupWithModel:model]) {
        return NO;
    }
    self.hour = -1;
    self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self refresh];
    return YES;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)refresh {
    LightArtCountdown *model = (LightArtCountdown *)self.model;
    NSTimeInterval interval = 0;
    NSDate *date = [NSDate date];
    id <LightArtServiceProtocol> lightArtService = [self.model.lightArtDocument.view lightArtService];
    if ([lightArtService respondsToSelector:@selector(serverDate)]) {
        date = [lightArtService serverDate];
    }
    if (date.timeIntervalSince1970 <= model.start_time.timeIntervalSince1970) {
        interval = model.start_time.timeIntervalSince1970 - date.timeIntervalSince1970;
    } else if (date.timeIntervalSince1970 <= model.end_time.timeIntervalSince1970) {
        interval = model.end_time.timeIntervalSince1970 - date.timeIntervalSince1970;
    }
    int daySeconds = 24 * 60 * 60;
    int hourSeconds = 60 * 60;
    int minuteSeconds = 60;
    self.fullHour = interval / hourSeconds;
    self.day = interval / daySeconds;
    interval -= self.day * daySeconds;
    int hour = interval / hourSeconds;
    BOOL shouldReloadData = hour != self.hour;
    self.hour = hour;
    interval -= self.hour * hourSeconds;
    self.minute = interval / minuteSeconds;
    interval -= self.minute * minuteSeconds;
    self.second = (int)interval;
    interval -= self.second;
    self.tenthSecond = (int)(10 * interval);
    if (shouldReloadData) {
        [self reloadData];
    } else {
        [self refreshData];
    }
}

- (void)refreshData {
    NSMutableArray *array = [NSMutableArray array];
    if (nil != self.tenthSecondLabel) {
        NSString *text = [NSString stringWithFormat:@"%i", self.tenthSecond];
        [array addObject:@[self.tenthSecondLabel, text]];
    }
    if (nil != self.secondLabel0) {
        NSString *text = [NSString stringWithFormat:@"%i", self.second % 10];
        [array addObject:@[self.secondLabel0, text]];
    }
    if (nil != self.secondLabel1) {
        NSString *text = [NSString stringWithFormat:@"%i", self.second / 10];
        [array addObject:@[self.secondLabel1, text]];
    }
    if (nil != self.secondLabel) {
        NSString *text = [NSString stringWithFormat:@"%i", self.second];
        [array addObject:@[self.secondLabel, text]];
    }
    if (nil != self.minLabel0) {
        NSString *text = [NSString stringWithFormat:@"%i", self.minute % 10];
        [array addObject:@[self.minLabel0, text]];
    }
    if (nil != self.minLabel1) {
        NSString *text = [NSString stringWithFormat:@"%i", self.minute / 10];
        [array addObject:@[self.minLabel1, text]];
    }
    if (nil != self.minLabel) {
        NSString *text = [NSString stringWithFormat:@"%i", self.minute];
        [array addObject:@[self.minLabel, text]];
    }
    for (NSArray *a in array) {
        LightArtLabel *label = a[0];
        NSString *text = a[1];
        if (![text isEqual:label.text]) {
            label.text = text;
            [label.view setupWithModel:label];
        }
    }
}

- (void)reallyReloadData {
    NSDictionary *data = @{@"$countdown": @{@"day": @(self.day), @"hour": @(self.hour), @"full_hour": @(self.fullHour)}};
    [self.model.lightArtDocument asynParseWithTemplate:self.model.originalLightArt data:data block:^(id result) {
        LightArtCountdown *model = (LightArtCountdown *)self.model;
        for (LightArtUIComponent *component in model.components) {
            [component.view removeFromSuperview];
        }
        
        LightArtCountdown *lightArtCountdown = result;
        model.components = lightArtCountdown.components;
        NSMutableArray *queue = [NSMutableArray array];
        [queue addObjectsFromArray:model.components];
        while (queue.count > 0) {
            LightArtUIComponent *l = [queue objectAtIndex:0];
            NSArray *components = nil;
            if ([l isKindOfClass:[LightArtBlock class]]) {
                components = [(LightArtBlock *)l components];
            } else if ([l isKindOfClass:[LightArtFlow class]]) {
                components = [(LightArtFlow *)l components];
            } else if ([l isKindOfClass:[LightArtCountdown class]]) {
                components = [(LightArtCountdown *)l components];
            } else if ([l isKindOfClass:[LightArtLabel class]]) {
                LightArtLabel *lightArtLabel = (LightArtLabel *)l;
                NSString *text = lightArtLabel.text;
                text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([text isEqual:@"{{$countdown.tenth_second}}"]) {
                    self.tenthSecondLabel = lightArtLabel;
                } else if ([text isEqual:@"{{$countdown.second_parts[0]}}"]) {
                    self.secondLabel0 = lightArtLabel;
                } else if ([text isEqual:@"{{$countdown.second_parts[1]}}"]) {
                    self.secondLabel1 = lightArtLabel;
                } else if ([text isEqual:@"{{$countdown.second}}"]) {
                    self.secondLabel = lightArtLabel;
                } else if ([text isEqual:@"{{$countdown.minute_parts[0]}}"]) {
                    self.minLabel0 = lightArtLabel;
                } else if ([text isEqual:@"{{$countdown.minute_parts[1]}}"]) {
                    self.minLabel1 = lightArtLabel;
                } else if ([text isEqual:@"{{$countdown.minute}}"]) {
                    self.minLabel = lightArtLabel;
                }
            }
            if (nil != components) {
                [queue addObjectsFromArray:components];
            }
            [queue removeObjectAtIndex:0];
        }
        [self refreshData];
        for (LightArtUIComponent *component in model.components) {
            LightArtUIView *view = [LightArtUIView viewWithModel:component];
            [self addSubview:view];
        }
        
        [self refreshFrame];
    }];
}

- (void)reallyRefreshFrame {
    CGFloat width = 0;
    CGFloat height = 0;
    LightArtCountdown *model = (LightArtCountdown *)self.model;
    for (LightArtUIComponent *component in model.components) {
        LightArtUIView *view = component.view;
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
    // 需要确保self.la_size先计算出来，所以放到最后
    for (LightArtUIComponent *component in model.components) {
        LightArtUIView *view = component.view;
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
