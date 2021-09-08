//
//  LightArtModel.m
//  lightart
//
//  Created by 彭利章 on 2018/3/9.
//  Copyright © 2018年 bingwu. All rights reserved.
//

#import "LightArtDocument.h"
#import "LightArtParser.h"
#import <YYModel/YYModel.h>
#import "LightArtView.h"
#import "LightArtUIView.h"

@interface ModelProxy : NSObject

@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) NSString *fromComponentId;
@property (nonatomic, weak) LightArtUIComponent *model;
@property (nonatomic, copy) void (^block)(NSDictionary *params);

@end

@implementation ModelProxy

@end

@interface LightArtDocument ()

@property (nonatomic, strong) NSMutableDictionary *originalLightArtDic;
@property (nonatomic, strong) NSMutableDictionary *componentDic;
@property (nonatomic, strong) NSMutableDictionary *eventDic;
@property (nonatomic, strong) NSMutableDictionary *actionDic;
@property (nonatomic, strong) NSMutableDictionary *eventTokenArrayDic;
@property (nonatomic, strong) NSMutableDictionary *tokenDic;

@end

@implementation LightArtDocument

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    self = [super init];
    if (self) {
        self.originalLightArtDic = [NSMutableDictionary dictionary];
        self.componentDic = [NSMutableDictionary dictionary];
        NSDictionary *lightArt = jsonObject[@"$lightart"];
        NSDictionary *head = lightArt[@"head"];
        if (nil != head[@"events"]) {
            NSDictionary *events = head[@"events"];
            NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
            for (NSString *name in events) {
                Action *action = [Action yy_modelWithJSON:events[name]];
                if (nil != action) {
                    eventDic[name] = action;
                }
            }
            self.eventDic = eventDic;
        }
        if (nil != head[@"actions"]) {
            NSDictionary *actions = head[@"actions"];
            NSMutableDictionary *actionDic = [NSMutableDictionary dictionary];
            for (NSString *name in actions) {
                Action *action = [Action yy_modelWithJSON:actions[name]];
                if (nil != action) {
                    actionDic[name] = action;
                }
            }
            self.actionDic = actionDic;
        }
        self.eventTokenArrayDic = [NSMutableDictionary dictionary];
        self.tokenDic = [NSMutableDictionary dictionary];
        id body = lightArt[@"body"];
        NSDictionary *data = nil;
        if (nil == body) {
            body = head[@"templates"][@"body"];
            data = head[@"datas"][@"body"];
        }
        if ([body isKindOfClass:[NSDictionary class]] && 0 != [body count]) {
            body = [body mutableCopy];
            if (nil != data) {
                [self extractOriginalLightArt:body];
                id lightArt = [LightArtParser syncParseWithTemplate:body data:data];
                self.translatedLightArt = lightArt;
                self.root = [self modelWithJSON:lightArt];
            } else {
                [self extractOriginalLightArt:body];
                self.translatedLightArt = body;
                self.root = [self modelWithJSON:body];
            }
        }
    }
    return self;
}

- (NSString *)identifier {
    return [self.root identifier];
}

- (void)asynParseWithTemplate:(id)template data:(NSDictionary*)data block:(void(^)(id))block {
    template = [template mutableCopy];
    [self extractOriginalLightArt:template];
    [LightArtParser asyncParseWithTemplate:template data:data block:^(id lightArt) {
        id result = [self modelWithJSON:lightArt];
        if (block) {
            block(result);
        }
    }];
}

- (id)parseWithTemplate:(id)template data:(NSDictionary *)data {
    template = [template mutableCopy];
    [self extractOriginalLightArt:template];
    id lightArt = [LightArtParser syncParseWithTemplate:template data:data];
    return [self modelWithJSON:lightArt];
}

- (id)modelWithJSON:(id)json {
    id model = nil;
    NSMutableArray *queue = [NSMutableArray array];
    if ([json isKindOfClass:[NSArray class]]) {
        NSMutableArray *components = [NSMutableArray array];
        for (NSDictionary *dic in json) {
            LightArtUIComponent *component = [LightArtUIComponent yy_modelWithJSON:dic];
            [components addObject:component];
        }
        model = components;
        [queue addObjectsFromArray:components];
    } else if ([json isKindOfClass:[NSDictionary class]]) {
        LightArtUIComponent *component = [LightArtUIComponent yy_modelWithJSON:json];
        model = component;
        [queue addObject:component];
    }
    while (queue.count > 0) {
        LightArtUIComponent *l = [queue objectAtIndex:0];
        l.lightArtDocument = self;
        if (nil != l.component_id && nil == self.componentDic[l.component_id]) {
            self.componentDic[l.component_id] = l;
        }
        for (NSString *event in l.actions) {
            ModelProxy *modelProxy = [[ModelProxy alloc] init];
            modelProxy.model = l;
            modelProxy.event = event;
            [self addObserverForEvent:modelProxy.event modelProxy:modelProxy];
        }
        NSArray *components = [l children];
        for (LightArtUIComponent *c in components) {
            c.parent = l;
        }
        [queue addObjectsFromArray:components];
        [queue removeObjectAtIndex:0];
    }
    return model;
}

- (void)extractOriginalLightArt:(NSMutableDictionary *)json {
    if (![json isKindOfClass:[NSMutableDictionary class]]) {
        return;
    }
    NSMutableArray *queue = [NSMutableArray array];
    [queue addObject:json];
    while (queue.count > 0) {
        NSObject *object = queue[0];
        [queue removeObjectAtIndex:0];
        if ([object isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *dic = (NSMutableDictionary *)object;
            NSArray *allKeys = dic.allKeys;
            for (NSString *key in allKeys) {
                NSObject *value = dic[key];
                if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                    value = [value mutableCopy];
                    dic[key] = value;
                    [queue addObject:value];
                }
            }
            if (nil != dic[@"dt"] && nil == dic[@"originalLightArtId"]) {
                NSString *lightArtId = [[NSUUID UUID] UUIDString];
                dic[@"originalLightArtId"] = lightArtId;
                self.originalLightArtDic[lightArtId] = dic;
            }
        } else if ([object isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *mutableArray = (NSMutableArray *)object;
            for (int i = 0; i < mutableArray.count; i++) {
                NSObject *value = mutableArray[i];
                if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                    value = [value mutableCopy];
                    [mutableArray replaceObjectAtIndex:i withObject:value];
                    [queue addObject:value];
                }
            }
        }
    }
}

- (LightArtUIComponent *)componentWithId:(NSString *)componentId {
    if (nil == componentId) {
        return nil;
    }
    return self.componentDic[componentId];
}

- (Action *)eventActionWithName:(NSString *)name {
    return self.eventDic[name];
}

- (Action *)actionWithName:(NSString *)name {
    return self.actionDic[name];
}

- (void)handleAction:(Action *)action model:(LightArtUIComponent *)model {
    if (nil == action) return;
    if ([@"!href" isEqual:action.name]) {
        BOOL success =NO;
        NSString *url = action.params[@"url"];
        if (0 != url.length) {
            id <LightArtServiceProtocol> lightArtService = [self.view lightArtService];
            if (lightArtService && [lightArtService respondsToSelector:@selector(routeToUrl:indexPath:business:)]){
                if ([lightArtService routeToUrl:url indexPath:[model indexPath] business:model.business]) {
                    success = YES;
                }
            }
        }
        if (success) {
            Action *successAction = [action successActionWithArgs:nil];
            [self handleAction:successAction model:model];
        } else {
            Action *failAction = [action failActionWithArgs:nil];
            [self handleAction:failAction model:model];
        }
    } else if ([@"!request" isEqual:action.name]) {
        NSDictionary *params = action.params;
        NSString *url = params[@"url"];
        NSDictionary *parameters = params[@"parameters"];
        NSString *method = params[@"method"];
        NSDictionary *headers = params[@"headers"];
        id <LightArtServiceProtocol> lightArtService = [self.view lightArtService];
        if (lightArtService && [lightArtService respondsToSelector:@selector(loadDataWithUrl:method:params:headers:succuss:failure:)]) {
            [lightArtService loadDataWithUrl:url method:method params:parameters headers:headers succuss:^(NSURLSessionDataTask *task, id responseObject) {
                if (nil != responseObject) {
                    Action *successAction = [action successActionWithArgs:responseObject];
                    [self handleAction:successAction model:model];
                } else {
                    Action *failAction = [action failActionWithArgs:nil];
                    [self handleAction:failAction model:model];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                Action *failAction = [action failActionWithArgs:nil];
                [self handleAction:failAction model:model];
            }];
        }
    } else if ([@"!update" isEqual:action.name]) {
        BOOL success = NO;
        NSDictionary *params = action.params;
        NSString *componentId = params[@"component_id"];
        NSDictionary *template = params[@"template"];
        LightArtUIComponent *component = [self componentWithId:componentId];
        if (nil != component) {
            if (nil == template) {
                template = component.originalLightArt;
            }
            LightArtDocument *document = component.lightArtDocument;
            LightArtUIComponent *newComponent = [document parseWithTemplate:template data:params[@"data"]];
            if (nil != newComponent) {
                LightArtUIComponent *parentComponent = component.parent;
                if (nil == parentComponent) {
                    // 根节点
                    document.root = newComponent;
                    document.view.document = document;
                } else {
                    success = [parentComponent updateChild:component withModel:newComponent];
                }
            }
        }
        if (success) {
            Action *successAction = [action successActionWithArgs:nil];
            [self handleAction:successAction model:model];
        } else {
            Action *failAction = [action failActionWithArgs:nil];
            [self handleAction:failAction model:model];
        }
    } else if ([@"!list_scroll_to" isEqual:action.name]) {
        NSString *componentId = action.params[@"component_id"];
        if (0 == componentId.length) {
            [model.view scrollTo:action.params];
        } else {
            LightArtUIComponent *component = [self componentWithId:componentId];
            [component.view scrollTo:action.params];
        }
        
        Action *successAction = [action successActionWithArgs:nil];
        [self handleAction:successAction model:model];
    } else if ([@"!emit" isEqual:action.name]) {
        NSString *event = action.params[@"event"];
        if (nil == event) {
            return;
        }
        NSString *componentId = action.params[@"component_id"];
        NSDictionary *params = action.params[@"params"];
        [self sendEvent:event params:params toComponentId:componentId fromComponentId:model.component_id];
        
        Action *successAction = [action successActionWithArgs:nil];
        [self handleAction:successAction model:model];
    } else {
        // 引用document里面的action
        Action *realAction = [self actionWithName:action.name];
        realAction = [realAction translateWithArgs:action.params];
        [self handleAction:realAction model:model];
    }
}

- (NSString *)addObserverForEvent:(NSString *)event componentId:(NSString *)componentId usingBlock:(void (^)(NSDictionary *userInfo))block {
    if (0 == event.length) return nil;
    ModelProxy *modelProxy = [[ModelProxy alloc] init];
    modelProxy.event = event;
    modelProxy.fromComponentId = componentId;
    modelProxy.block = block;
    return [self addObserverForEvent:event modelProxy:modelProxy];
}

- (NSString *)addObserverForEvent:(NSString *)event modelProxy:(ModelProxy *)modelProxy {
    NSString *token = [NSUUID UUID].UUIDString;
    self.tokenDic[token] = modelProxy;
    NSMutableArray *array = self.eventTokenArrayDic[event];
    if (nil == array) {
        array = [NSMutableArray array];
        self.eventTokenArrayDic[event] = array;
    }
    [array addObject:token];
    return token;
}

- (void)removeObserver:(NSString *)token {
    if (nil == token) {
        return;
    }
    ModelProxy *modelProxy = self.tokenDic[token];
    [self.tokenDic removeObjectForKey:token];
    NSMutableArray *array = self.eventTokenArrayDic[modelProxy.event];
    [array removeObject:token];
}

- (void)sendEvent:(NSString *)event params:(NSDictionary *)params componentId:(NSString *)componentId {
    if (0 == event.length) return;
    [self sendEvent:event params:params toComponentId:componentId fromComponentId:nil];
}

- (void)sendEvent:(NSString *)event params:(NSDictionary *)params toComponentId:(NSString *)toComponentId fromComponentId:(NSString *)fromComponentId {
    if (0 == event.length) return;
    NSMutableArray *array = self.eventTokenArrayDic[event];
    for (NSString *token in array) {
        ModelProxy *modelProxy = self.tokenDic[token];
        if (nil != modelProxy.model && (0 == toComponentId.length || [modelProxy.model.component_id isEqual:toComponentId])) {
            // 如果componentId不为空，则事件只发给这个组件
            [modelProxy.model triggerActionWithEvent:event params:params];
        }
        if (nil != modelProxy.block && (0 == modelProxy.fromComponentId.length || [modelProxy.fromComponentId isEqual:fromComponentId])) {
            // 如果modelProxy.fromComponentId不为空，则只接收来自这个组件的事件
            modelProxy.block(params);
        }
    }
}

@end

@implementation LightArtAnimationStepTranslate

@end

@implementation LightArtAnimationStepRotate

@end

@implementation LightArtAnimationStepScale

@end

@implementation LightArtAnimationStep

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    for (NSString *key in @[@"delay", @"duration"]) {
        mutableDic[key] = @([dic[key] doubleValue] / 1000.0);
    }
    return mutableDic;
}

- (NSValue *)transform3DValueWithScreenWidth:(CGFloat)screenWidth {
    if (nil != self.translate || nil != self.rotate || nil != self.scale) {
        CATransform3D t = CATransform3DIdentity;
        if (nil != self.translate) {
            t = CATransform3DTranslate(t, [Bounds pixelWithString:self.translate.x screenWidth:screenWidth], [Bounds pixelWithString:self.translate.y screenWidth:screenWidth], 0);
        }
        if (nil != self.rotate) {
            if (0 != self.rotate.x.length) {
                t = CATransform3DRotate(t, self.rotate.x.floatValue / 180 * M_PI, 1, 0, 0);
            }
            if (0 != self.rotate.y.length) {
                t = CATransform3DRotate(t, self.rotate.y.floatValue / 180 * M_PI, 0, 1, 0);
            }
            if (0 != self.rotate.z.length) {
                t = CATransform3DRotate(t, self.rotate.z.floatValue / 180 * M_PI, 0, 0, 1);
            }
        }
        if (nil != self.scale) {
            if (0 != self.scale.x.length) {
                t = CATransform3DScale(t, self.scale.x.floatValue, 1, 1);
            }
            if (0 != self.scale.y.length) {
                t = CATransform3DScale(t, 1, self.scale.y.floatValue, 1);
            }
            
        }
        return [NSValue valueWithCATransform3D:t];
    } else {
        return nil;
    }
}

@end

@implementation LightArtAnimation

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    if (nil == mutableDic[@"loop"]) {
        mutableDic[@"loop"] = @"-1";
    }
    return mutableDic;
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"steps": [LightArtAnimationStep class]};
}

@end

@implementation Bounds

+ (CGFloat)pixelWithString:(NSString *)str screenWidth:(CGFloat)screenWidth {
    return [self pixelWithString:str parent:0 screenWidth:screenWidth];
}

+ (CGFloat)pixelWithString:(NSString *)str parent:(CGFloat)parent screenWidth:(CGFloat)screenWidth  {
    CGFloat f = 0;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([str hasSuffix:@"px"]) {
        str = [str substringToIndex:str.length - 2];
        f = str.floatValue / 2; 
    } else if ([str hasSuffix:@"%"]) {
        str = [str substringToIndex:str.length - 1];
        f = str.floatValue / 100 * parent;
    } else {
        if ([str hasSuffix:@"dip"]) {
            str = [str substringToIndex:str.length - 3];
        }
        f = (str.floatValue / 375 * screenWidth) / 2;
    }
    return round(f * 2) / 2;
}

+ (BOOL)isPercentValue:(NSString *)str {
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [str hasSuffix:@"%"];
}

- (BOOL)hasPercentValue {
    if ([Bounds isPercentValue:self.l]) {
        return YES;
    }
    if ([Bounds isPercentValue:self.t]) {
        return YES;
    }
    if ([Bounds isPercentValue:self.w]) {
        return YES;
    }
    if ([Bounds isPercentValue:self.h]) {
        return YES;
    }
    return NO;
}

- (CGRect)frameWithParentSize:(CGSize)size screenWidth:(CGFloat)screenWidth {
    CGRect rect = CGRectMake([Bounds pixelWithString:self.l parent:size.width screenWidth:screenWidth],
                             [Bounds pixelWithString:self.t parent:size.height screenWidth:screenWidth],
                             [Bounds pixelWithString:self.w parent:size.width screenWidth:screenWidth],
                             [Bounds pixelWithString:self.h parent:size.height screenWidth:screenWidth]);
    return rect;
}

@end

@implementation CornerRadius

- (BOOL)isEmpty {
    return 0 == self.lt.length && 0 == self.lb.length && 0 == self.rt.length && 0 == self.rb.length;
}

@end

@implementation Border

@end

@implementation Image

@end

@implementation LightArtGradient

@end

@implementation Background

@end

@implementation LightArtFont

- (UIFont *)fontWithScreenWidth:(CGFloat)screenWidth {
    if (0 == self.size.length) return nil;
    CGFloat fontSize = [Bounds pixelWithString:self.size screenWidth:screenWidth];
    if (self.bold) {
        return [UIFont boldSystemFontOfSize:fontSize];
    } else if (self.italic) {
        return [UIFont italicSystemFontOfSize:fontSize];
    } else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

@end

@implementation Align

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    for (NSString *key in @[@"v", @"h"]) {
        NSString *str = dic[key];
        LightArtAlignment alignType = LightArtAlignmentNone;
        if ([@"start" isEqual:str]) {
            alignType = LightArtAlignmentStart;
        } else if ([@"center" isEqual:str]) {
            alignType = LightArtAlignmentCenter;
        } else if ([@"end" isEqual:str]) {
            alignType = LightArtAlignmentEnd;
        }
        mutableDic[key] = @(alignType);
    }
    return mutableDic;
}

@end

@interface Action () <NSCopying>

@end

@implementation Action

- (id)copyWithZone:(NSZone *)zone {
    Action *action = [Action new];
    action.name = [self.name copy];
    action.params = [self.params copy];
    action.success = [self.success copy];
    action.fail = [self.fail copy];
    return action;
}

- (Action *)translateWithArgs:(NSDictionary *)args {
    Action *action = [self copy];
    if (nil == args) {
        return action;
    }
    NSMutableDictionary *template = [NSMutableDictionary dictionary];
    if (nil != self.params) {
        template[@"params"] = action.params;
    }
    if (0 != template.count) {
        NSDictionary *dic = [LightArtParser syncParseWithTemplate:template data:@{@"$args": args}];
        action.params = dic[@"params"];
    }
    return action;
}

- (Action *)successActionWithArgs:(NSDictionary *)args {
    if (nil == self.success) {
        return nil;
    }
    NSMutableDictionary *template = [NSMutableDictionary dictionary];
    template[@"success"] = self.success;
    if (nil != args) {
        NSDictionary *dic = [LightArtParser syncParseWithTemplate:template data:@{@"$args": args}];
        Action *action = [Action yy_modelWithJSON:dic[@"success"]];
        return action;
    } else {
        Action *action = [Action yy_modelWithJSON:self.success];
        return action;
    }
}

- (Action *)failActionWithArgs:(NSDictionary *)args {
    if (nil == self.fail) {
        return nil;
    }
    NSMutableDictionary *template = [NSMutableDictionary dictionary];
    template[@"fail"] = self.fail;
    if (nil != args) {
        NSDictionary *dic = [LightArtParser syncParseWithTemplate:template data:@{@"$args": args}];
        Action *action = [Action yy_modelWithJSON:dic[@"fail"]];
        return action;
    } else {
        Action *action = [Action yy_modelWithJSON:self.fail];
        return action;
    }
}

@end

@interface LightArtUIComponent ()

@end

@implementation LightArtUIComponent

+ (Class)modelCustomClassForDictionary:(NSDictionary *)dictionary {
    NSString *dt = dictionary[@"dt"];
    if ([@"label" isEqual:dt]) {
        return [LightArtLabel class];
    } else if ([@"image" isEqual:dt]) {
        return [LightArtImage class];
    } else if ([@"countdown" isEqual:dt]) {
        return [LightArtCountdown class];
    } else if ([@"block" isEqual:dt]) {
        return [LightArtBlock class];
    } else if ([@"flow" isEqual:dt]) {
        return [LightArtFlow class];
    } else if ([@"section_list" isEqual:dt]) {
        return [LightArtSectionList class];
    } else if ([@"native" isEqual:dt]) {
        return [LightArtCustom class];
    } else if ([@"button" isEqual:dt]) {
        return [LightArtButton class];
    } else if ([@"segment" isEqual:dt]) {
        return [LightArtSegment class];
    } else if ([@"async_box" isEqual:dt]) {
        return [LightArtAsyncBox class];
    } else if ([@"tab" isEqual:dt]) {
        return [LightArtTab class];
    } else {
        return [LightArtUIComponent class];
    }
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    if (nil == mutableDic[@"alpha"]) {
        mutableDic[@"alpha"] = @"1";
    }
    return mutableDic;
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"actions": [Action class]};
}

- (NSDictionary *)originalLightArt {
    if (nil != _originalLightArt) {
        return _originalLightArt;
    }
    if (nil == self.originalLightArtId) {
        return nil;
    }
    return self.lightArtDocument.originalLightArtDic[self.originalLightArtId];
}

- (BOOL)isEqual:(id)object {
    if ([self isKindOfClass:[object class]]) {
        LightArtUIComponent *component = (LightArtUIComponent *)object;
        if ([self.component_id isEqual:component.component_id]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)identifier {
    if ([self isKindOfClass:[LightArtLabel class]]) {
        return @"1";
    } else if ([self isKindOfClass:[LightArtImage class]]) {
        return @"2";
    } else if ([self isKindOfClass:[LightArtCountdown class]]) {
        return @"3";
    } else if ([self isKindOfClass:[LightArtBlock class]]) {
        NSArray *components = [(LightArtBlock *)self components];
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < components.count; i++) {
            LightArtUIComponent *c = components[i];
            if (0 != i) {
                [str appendString:@"-"];
            }
            [str appendString:[c identifier]];
        }
        return [@"4" stringByAppendingFormat:@"(%@)", str];
    } else if ([self isKindOfClass:[LightArtFlow class]]) {
        NSArray *components = [(LightArtFlow *)self components];
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < components.count; i++) {
            LightArtUIComponent *c = components[i];
            if (0 != i) {
                [str appendString:@"-"];
            }
            [str appendString:[c identifier]];
        }
        return [@"5" stringByAppendingFormat:@"(%@)", str];
    } else if ([self isKindOfClass:[LightArtSectionList class]]) {
        return @"6";
    } else if ([self isKindOfClass:[LightArtCustom class]]) {
        NSString *contentIdentifer = [(LightArtCustom *)self contentIdentifier];
        if (nil != contentIdentifer) {
            return [@"7" stringByAppendingFormat:@"(%@)", contentIdentifer];
        } else {
            return @"7";
        }
    } else if ([self isKindOfClass:[LightArtButton class]]) {
        return @"8";
    } else if ([self isKindOfClass:[LightArtSegment class]]) {
        return @"9";
    } else if ([self isKindOfClass:[LightArtAsyncBox class]]) {
        return @"A";
    } else if ([self isKindOfClass:[LightArtTab class]]) {
        return @"B";
    } else {
        return @"0";
    }
}

- (NSString *)indexPath {
    if (nil == self.index) return nil;
    NSMutableString *str = [NSMutableString string];
    [str insertString:self.index atIndex:0];
    LightArtUIComponent *parent = self.parent;
    while (nil != parent) {
        if (nil != parent.index) {
            [str insertString:@":" atIndex:0];
            [str insertString:parent.index atIndex:0];
        }
        parent = parent.parent;
    }
    return str;
}

- (void)triggerActionWithEvent:(NSString *)event params:(id)params {
    if (nil == event) return;
    Action *action = self.actions[event];
    if (nil != action) {
        action = [action translateWithArgs:params];
        [self.lightArtDocument handleAction:action model:self];
    }
    if ([event isEqual:self.animation.event]) {
        [self.view startAnimation];
    }
}

- (NSArray *)children {
    return nil;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    return NO;
}

- (CGFloat)screenWidth {
    CGFloat width = self.lightArtDocument.view.screenWidth;
    if (width <= 0) {
        width = [UIScreen mainScreen].bounds.size.width;
    }
    return width;
}

@end

@implementation LightArtLabel

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    dic = [super modelCustomWillTransformFromDictionary:dic];
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    for (NSString *key in @[@"ellipsize"]) {
        NSString *str = dic[key];
        LightArtAlignment alignType = LightArtAlignmentEnd;
        if ([@"start" isEqual:str]) {
            alignType = LightArtAlignmentStart;
        } else if ([@"center" isEqual:str]) {
            alignType = LightArtAlignmentCenter;
        } else if ([@"end" isEqual:str]) {
            alignType = LightArtAlignmentEnd;
        }
        mutableDic[key] = @(alignType);
    }
    return mutableDic;
}

@end

@implementation LightArtImage

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    dic = [super modelCustomWillTransformFromDictionary:dic];
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    for (NSString *key in @[@"scale_type", @"default_scale_type", @"error_scale_type"]) {
        NSString *str = dic[key];
        UIViewContentMode mode = UIViewContentModeScaleAspectFit;
        if ([@"center" isEqual:str]) {
            mode = UIViewContentModeScaleAspectFit;
        } else if ([@"fill" isEqual:str]) {
            mode = UIViewContentModeScaleAspectFill;
        }
        mutableDic[key] = @(mode);
    }
    return mutableDic;
}
        
@end

@implementation LightArtCountdown

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary *originalLightArt = dic;
    dic = [super modelCustomWillTransformFromDictionary:dic];
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    for (NSString *key in @[@"start_time", @"end_time"]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([dic[key] doubleValue] / 1000.0)];
        mutableDic[key] = date;
    }
    mutableDic[@"originalLightArt"] = originalLightArt;
    return mutableDic;
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super modelContainerPropertyGenericClass]];
    [dic addEntriesFromDictionary:@{@"components": [LightArtUIComponent class]}];
    return dic;
}

- (NSArray *)children {
    return self.components;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    NSUInteger index = [self.components indexOfObject:component];
    if (NSNotFound != index) {
        [component.view removeFromSuperview];
        [self.components replaceObjectAtIndex:index withObject:newComponent];
        [self.view reloadData];
        return YES;
    }
    return NO;
}

@end

@implementation LightArtBlock

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super modelContainerPropertyGenericClass]];
    [dic addEntriesFromDictionary:@{@"components": [LightArtUIComponent class]}];
    return dic;
}

- (NSArray *)children {
    return self.components;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    NSUInteger index = [self.components indexOfObject:component];
    if (NSNotFound != index) {
        [component.view removeFromSuperview];
        [self.components replaceObjectAtIndex:index withObject:newComponent];
        [self.view reloadData];
        return YES;
    }
    return NO;
}

@end

@implementation LightArtRefresh

- (NSString *)method {
    if (0 != _method.length) {
        return [_method uppercaseString];
    }
    return @"GET";
}

@end

@implementation LightArtLoadMore

- (NSString *)method {
    if (0 != _method.length) {
        return [_method uppercaseString];
    }
    return @"GET";
}

@end

@implementation LightArtFlow

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    dic = [super modelCustomWillTransformFromDictionary:dic];
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    for (NSString *key in @[@"direction"]) {
        NSString *str = dic[key];
        LightArtDirection direction = LightArtDirectionVertical;
        if ([@"vertical" isEqual:str]) {
            direction = LightArtDirectionVertical;
        } else if ([@"horizontal" isEqual:str]) {
            direction = LightArtDirectionHorizontal;
        }
        mutableDic[key] = @(direction);
    }
    return mutableDic;
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super modelContainerPropertyGenericClass]];
    [dic addEntriesFromDictionary:@{@"components": [LightArtUIComponent class]}];
    return dic;
}

- (NSArray *)children {
    return self.components;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    NSUInteger index = [self.components indexOfObject:component];
    if (NSNotFound != index) {
        [component.view removeFromSuperview];
        [self.components replaceObjectAtIndex:index withObject:newComponent];
        [self.view reloadData];
        return YES;
    }
    return NO;
}

@end

@implementation LightArtContentInsets

- (UIEdgeInsets)insetWithScreenWidth:(CGFloat)screenWidth {
    UIEdgeInsets inset = UIEdgeInsetsMake([Bounds pixelWithString:self.t screenWidth:screenWidth],
                                          [Bounds pixelWithString:self.l screenWidth:screenWidth],
                                          [Bounds pixelWithString:self.b screenWidth:screenWidth],
                                          [Bounds pixelWithString:self.r screenWidth:screenWidth]);
    return inset;
}

@end

@implementation LightArtButton

- (NSArray *)children {
    NSMutableArray *array = [NSMutableArray array];
    if (nil != self.selected) {
        [array addObject:self.selected];
    }
    if (nil != self.highlighted) {
        [array addObject:self.highlighted];
    }
    if (nil != self.normal) {
        [array addObject:self.normal];
    }
    return array;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    if (component == self.selected) {
        self.selected = newComponent;
        [self.view reloadData];
        return YES;
    }
    if (component == self.highlighted) {
        self.highlighted = newComponent;
        [self.view reloadData];
        return YES;
    }
    if (component == self.normal) {
        self.normal = newComponent;
        [self.view reloadData];
        return YES;
    }
    return YES;
}

@end

@implementation LightArtSegment

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    dic = [super modelCustomWillTransformFromDictionary:dic];
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    for (NSString *key in @[@"direction"]) {
        NSString *str = dic[key];
        LightArtDirection direction = LightArtDirectionHorizontal;
        if ([@"vertical" isEqual:str]) {
            direction = LightArtDirectionVertical;
        } else if ([@"horizontal" isEqual:str]) {
            direction = LightArtDirectionHorizontal;
        }
        mutableDic[key] = @(direction);
    }
    return mutableDic;
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super modelContainerPropertyGenericClass]];
    [dic addEntriesFromDictionary:@{@"buttons": [LightArtButton class]}];
    return dic;
}

- (NSArray *)children {
    return self.buttons;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    NSUInteger index = [self.buttons indexOfObject:component];
    if (NSNotFound != index) {
        [component.view removeFromSuperview];
        [self.buttons replaceObjectAtIndex:index withObject:newComponent];
        [self.view reloadData];
        return YES;
    }
    return NO;
}

@end

@implementation LightArtAsyncBox

- (NSArray *)children {
    NSMutableArray *array = [NSMutableArray array];
    if (nil != self.loading) {
        [array addObject:self.loading];
    }
    if (nil != self.error) {
        [array addObject:self.error];
    }
    if (nil != self.content) {
        [array addObject:self.content];
    }
    return array;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    if (component == self.error) {
        self.error = newComponent;
        [self.view reloadData];
        return YES;
    }
    if (component == self.loading) {
        self.loading = newComponent;
        [self.view reloadData];
        return YES;
    }
    if (component == self.content) {
        self.content = newComponent;
        [self.view reloadData];
        return YES;
    }
    return YES;
}

@end

@implementation LightArtTab

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setDictionary:@{@"contents": [LightArtUIComponent class]}];
    return dic;
}

- (NSArray *)children {
    NSMutableArray *array = [NSMutableArray array];
    if (nil != self.segment) {
        [array addObject:self.segment];
    }
    [array addObjectsFromArray:self.contents];
    return array;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    NSUInteger index = [self.contents indexOfObject:component];
    if (NSNotFound != index) {
        [component.view removeFromSuperview];
        [self.contents replaceObjectAtIndex:index withObject:newComponent];
        [self.view reloadData];
        return YES;
    }
    if (component == self.segment && [newComponent isKindOfClass:[LightArtSegment class]]) {
        self.segment = (LightArtSegment *)newComponent;
        [self.view reloadData];
        return YES;
    }
    return NO;
}

@end

@implementation LightArtSection

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"components" : [LightArtUIComponent class]};
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[LightArtSection class]]) {
        LightArtSection *section = (LightArtSection *)object;
        if ([self.section_id isEqual:section.section_id]) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation LightArtTailTab

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:@{@"sections": [LightArtSection class]}];
    return dic;
}

@end

@implementation LightArtSectionList

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    dic = [super modelCustomWillTransformFromDictionary:dic];
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    NSString *stickHeader = mutableDic[@"sticky_header"];
    if (nil == stickHeader || ![stickHeader isKindOfClass:[NSString class]] || 0 == stickHeader.length) {
        mutableDic[@"sticky_header"] = @"true";
    }
    return mutableDic;
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super modelContainerPropertyGenericClass]];
    [dic addEntriesFromDictionary:@{@"sections": [LightArtSection class]}];
    return dic;
}

- (NSArray *)children {
    NSMutableArray *array = [NSMutableArray array];
    for (LightArtSection *section in self.sections) {
        if (nil != section.header) {
            [array addObject:section.header];
        }
        [array addObjectsFromArray:section.components];
    }
    if (nil != self.refresh.view) {
        [array addObject:self.refresh.view];
    }
    if (nil != self.load_more.view) {
        [array addObject:self.load_more.view];
    }
    if (nil != self.scroll_button) {
        [array addObject:self.scroll_button];
    }
    if (nil != self.tail_tab.segment) {
        [array addObject:self.tail_tab.segment];
    }
    for (LightArtSection *section in self.tail_tab.sections) {
        [array addObjectsFromArray:section.components];
    }
    return array;
}

- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent {
    newComponent.parent = self;
    for (LightArtSection *section in self.sections) {
        if (component == section.header) {
            section.header = newComponent;
            [self.view reloadData];
            return YES;
        }
        NSUInteger index = [section.components indexOfObject:component];
        if (NSNotFound != index) {
            [component.view removeFromSuperview];
            [section.components replaceObjectAtIndex:index withObject:newComponent];
            [self.view reloadData];
            return YES;
        }
    }
    if (component == self.refresh.view) {
        self.refresh.view = newComponent;
        [self.view reloadData];
        return YES;
    }
    if (component == self.load_more.view) {
        self.load_more.view = newComponent;
        [self.view reloadData];
        return YES;
    }
    if (component == self.scroll_button) {
        self.scroll_button = newComponent;
        [self.view reloadData];
        return YES;
    }
    if (component == self.tail_tab.segment) {
        [self.view reloadData];
        return YES;
    }
    for (LightArtSection *section in self.tail_tab.sections) {
        NSUInteger index = [section.components indexOfObject:component];
        if (NSNotFound != index) {
            [component.view removeFromSuperview];
            [section.components replaceObjectAtIndex:index withObject:newComponent];
            [self.view reloadData];
            return YES;
        }
    }
    return NO;
}

@end

@interface LightArtCustom ()

@property (nonatomic, assign) BOOL translated;

@end

@implementation LightArtCustom

- (NSString *)contentIdentifier {
    if (nil == _contentIdentifier && !self.translated) {
        LightArtView *lightArtView = self.lightArtDocument.view;
        id <LightArtServiceProtocol> lightArtService = [lightArtView lightArtService];
        if (lightArtService) {
            self.translated = YES;
            if ([lightArtService respondsToSelector:@selector(identifierForCustomViewType:params:model:)]) {
                id contentModel = nil;
                NSString *identifier = [lightArtService identifierForCustomViewType:self.name params:self.params model:&contentModel];
                self.contentIdentifier = identifier;
                self.contentModel = contentModel;
            }
        }
    }
    return _contentIdentifier;
}

@end
