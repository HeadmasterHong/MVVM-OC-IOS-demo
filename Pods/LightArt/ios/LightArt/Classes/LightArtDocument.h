//
//  LightArtDocument.h
//  lightart
//
//  Created by 彭利章 on 2018/3/9.
//  Copyright © 2018年 bingwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LightArtUIView;
@class LightArtView;

typedef NS_ENUM(NSUInteger, LightArtAlignment) {
    LightArtAlignmentNone,
    LightArtAlignmentStart,
    LightArtAlignmentCenter,
    LightArtAlignmentEnd
};

typedef NS_ENUM(NSUInteger, LightArtDirection) {
    LightArtDirectionVertical,
    LightArtDirectionHorizontal
};

@interface LightArtAnimationStepTranslate : NSObject

@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@end

@interface LightArtAnimationStepRotate : NSObject

@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;
@property (nonatomic, strong) NSString *z;

@end

@interface LightArtAnimationStepScale : NSObject

@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@end

@interface LightArtAnimationStep : NSObject

@property (nonatomic, strong) NSString *timing_function;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSString *alpha;
@property (nonatomic, strong) LightArtAnimationStepTranslate *translate;
@property (nonatomic, strong) LightArtAnimationStepRotate *rotate;
@property (nonatomic, strong) LightArtAnimationStepScale *scale;

- (NSValue *)transform3DValueWithScreenWidth:(CGFloat)screenWidth;

@end

@interface LightArtAnimation : NSObject

@property (nonatomic, assign) int loop;
@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) NSArray *steps;

@property (nonatomic, assign) int currentLoop;

@end

@interface Bounds : NSObject

@property (nonatomic, strong) NSString *l;
@property (nonatomic, strong) NSString *t;
@property (nonatomic, strong) NSString *w;
@property (nonatomic, strong) NSString *h;

+ (CGFloat)pixelWithString:(NSString *)str screenWidth:(CGFloat)screenWidth;
+ (CGFloat)pixelWithString:(NSString *)str parent:(CGFloat)parent screenWidth:(CGFloat)screenWidth;
+ (BOOL)isPercentValue:(NSString *)str;
- (BOOL)hasPercentValue;
- (CGRect)frameWithParentSize:(CGSize)size screenWidth:(CGFloat)screenWidth;

@end

@interface CornerRadius : NSObject

@property (nonatomic, strong) NSString *lt;
@property (nonatomic, strong) NSString *lb;
@property (nonatomic, strong) NSString *rt;
@property (nonatomic, strong) NSString *rb;

- (BOOL)isEmpty;

@end

@interface Border : NSObject

@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *color;

@end

@interface Image : NSObject

@property (nonatomic, strong) NSString *url;

@end

@interface LightArtGradient : NSObject

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSString *start_x;
@property (nonatomic, strong) NSString *start_y;
@property (nonatomic, strong) NSString *end_x;
@property (nonatomic, strong) NSString *end_y;

@end

@interface Background : NSObject

@property (nonatomic, strong) Image *image;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) LightArtGradient *gradient;

@end

@interface Align : NSObject

@property (nonatomic, assign) LightArtAlignment v;
@property (nonatomic, assign) LightArtAlignment h;

@end

@interface Action : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id params; // 可能是Dictionary，也可能是 "{{$args}}" 这样的字符串
@property (nonatomic, strong) id success; // 可能是Dictionary，也可能是Array
@property (nonatomic, strong) id fail;

- (Action *)translateWithArgs:(NSDictionary *)args;
- (Action *)successActionWithArgs:(NSDictionary *)args;
- (Action *)failActionWithArgs:(NSDictionary *)args;

@end

@class LightArtDocument;

@interface LightArtUIComponent : NSObject

@property (nonatomic, strong) NSString *dt;
@property (nonatomic, strong) Bounds *bounds;
@property (nonatomic, strong) CornerRadius *corner_radius;
@property (nonatomic, strong) Border *border;
@property (nonatomic, strong) Background *background;
@property (nonatomic, assign) NSUInteger z_index;
@property (nonatomic, strong) Align *layout_align;
@property (nonatomic, strong) NSDictionary *actions;
@property (nonatomic, strong) NSString *component_id;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, strong) NSDictionary *statistics;
@property (nonatomic, strong) NSString *index;
@property (nonatomic, strong) id business;
@property (nonatomic, strong) LightArtAnimation *animation;
@property (nonatomic, assign) CGFloat gravity;

// 非协议属性
@property (nonatomic, strong) NSString *originalLightArtId;
@property (nonatomic, strong) NSDictionary *originalLightArt;
@property (nonatomic, weak) LightArtDocument *lightArtDocument;
@property (nonatomic, weak) LightArtUIComponent *parent;
@property (nonatomic, weak) LightArtUIView *view;
@property (nonatomic, strong) NSDate *visibleDate;
@property (nonatomic, assign) BOOL lastCheckIsVisible;
@property (nonatomic, assign) BOOL exposed;
@property (nonatomic, assign) BOOL loaded;

- (NSString *)identifier;
- (NSString *)indexPath;
- (void)triggerActionWithEvent:(NSString *)event params:(id)params;
- (NSArray *)children;
- (BOOL)updateChild:(LightArtUIComponent *)component withModel:(LightArtUIComponent *)newComponent;
- (CGFloat)screenWidth;

@end

@interface LightArtFont : NSObject

@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *family;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *line_height;
@property (nonatomic, assign) BOOL bold;
@property (nonatomic, assign) BOOL italic;

- (UIFont *)fontWithScreenWidth:(CGFloat)screenWidth;

@end

@interface LightArtLabel : LightArtUIComponent

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSUInteger max_lines;
@property (nonatomic, assign) LightArtAlignment ellipsize;
@property (nonatomic, strong) LightArtFont *font;
@property (nonatomic, strong) Align *align;
@property (nonatomic, assign) BOOL strikethrough;

@end

@interface LightArtImage : LightArtUIComponent

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *default_url;
@property (nonatomic, strong) NSString *error_url;
@property (nonatomic, assign) UIViewContentMode scale_type;
@property (nonatomic, assign) UIViewContentMode default_scale_type;
@property (nonatomic, assign) UIViewContentMode error_scale_type;

@end

@interface LightArtCountdown : LightArtUIComponent

@property (nonatomic, strong) NSDate *start_time;
@property (nonatomic, strong) NSDate *end_time;
@property (nonatomic, strong) NSMutableArray *components;

@end

@interface LightArtBlock : LightArtUIComponent

@property (nonatomic, strong) NSMutableArray *components;

@end

@interface LightArtRefresh : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) LightArtUIComponent *view;

@end

@interface LightArtLoadMore : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) LightArtUIComponent *view;
@property (nonatomic, strong) NSString *preload;
@property (nonatomic, assign) BOOL hide_when_done;

@end

@interface LightArtContentInsets : NSObject

@property (nonatomic, strong) NSString *l;
@property (nonatomic, strong) NSString *t;
@property (nonatomic, strong) NSString *r;
@property (nonatomic, strong) NSString *b;

- (UIEdgeInsets)insetWithScreenWidth:(CGFloat)screenWidth;

@end

@interface LightArtFlow : LightArtUIComponent

@property (nonatomic, assign) LightArtDirection direction;
@property (nonatomic, strong) NSMutableArray *components;
@property (nonatomic, assign) NSUInteger total;
@property (nonatomic, assign) BOOL smart_overflow;
@property (nonatomic, strong) LightArtContentInsets *safe_areas;

@end

typedef NS_ENUM(NSUInteger, LightArtButtonState) {
    LightArtButtonStateNormal,
    LightArtButtonStateSelected,
    LightArtButtonStateHighlighted
};

@interface LightArtButton : LightArtUIComponent

@property (nonatomic, strong) LightArtUIComponent *selected;
@property (nonatomic, strong) LightArtUIComponent *highlighted;
@property (nonatomic, strong) LightArtUIComponent *normal;

@property (nonatomic, assign) LightArtButtonState state;

@end

@interface LightArtSegment : LightArtUIComponent

@property (nonatomic, assign) LightArtDirection direction;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, assign) NSUInteger selected_index;
@property (nonatomic, strong) Align *align;
@property (nonatomic, strong) LightArtContentInsets *safe_areas;

@end

@interface LightArtAsyncBox : LightArtUIComponent

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *data_url;
@property (nonatomic, strong) NSString *template_url;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) id template;
@property (nonatomic, strong) LightArtUIComponent *error;
@property (nonatomic, strong) LightArtUIComponent *loading;
@property (nonatomic, strong) LightArtUIComponent *content;

@end

@interface LightArtTab : LightArtUIComponent

@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) LightArtSegment *segment;
@property (nonatomic, strong) NSMutableArray *contents;

@end

@interface LightArtSection : NSObject

@property (nonatomic, assign) int column;
@property (nonatomic, strong) NSMutableArray *components;
@property (nonatomic, assign) NSUInteger total;
@property (nonatomic, strong) LightArtUIComponent *header;
@property (nonatomic, assign) BOOL sticky_header;
@property (nonatomic, strong) NSString *v_gap;
@property (nonatomic, strong) NSString *h_gap;
@property (nonatomic, strong) LightArtContentInsets *content_insets;
@property (nonatomic, strong) NSString *section_id;
@property (nonatomic, strong) NSString *load_more_url;

@end

@interface LightArtTailTab : NSObject

@property (nonatomic, strong) LightArtSegment *segment;
@property (nonatomic, strong) NSMutableArray *sections;

@end

@interface LightArtSectionList : LightArtUIComponent

@property (nonatomic, strong) LightArtRefresh *refresh;
@property (nonatomic, strong) LightArtLoadMore *load_more;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, assign) NSUInteger total;
@property (nonatomic, assign) BOOL sticky_header;
@property (nonatomic, strong) NSString *v_gap;
@property (nonatomic, strong) NSString *h_gap;
@property (nonatomic, strong) LightArtContentInsets *content_insets;
@property (nonatomic, strong) LightArtContentInsets *safe_areas;
@property (nonatomic, strong) LightArtUIComponent *scroll_button;
@property (nonatomic, strong) LightArtTailTab *tail_tab;
@property (nonatomic, strong) NSString *content_width;

@property (nonatomic, assign) NSUInteger currentPageIndex;

@end

@interface LightArtCustom : LightArtUIComponent

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) NSString *contentIdentifier;
@property (nonatomic, strong) id contentModel;

@end

@interface LightArtDocument : NSObject

@property (nonatomic, strong) NSDictionary *translatedLightArt;
@property (nonatomic, strong) LightArtUIComponent *root;
@property (nonatomic, weak) LightArtView *view;

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject;
- (NSString *)identifier;
- (void)asynParseWithTemplate:(id)template data:(NSDictionary*)data block:(void(^)(id))block;
- (id)parseWithTemplate:(id)template data:(NSDictionary *)data;
- (LightArtUIComponent *)componentWithId:(NSString *)componentId;
- (Action *)eventActionWithName:(NSString *)name;
- (Action *)actionWithName:(NSString *)name;
- (void)handleAction:(Action *)action model:(LightArtUIComponent *)model;
- (NSString *)addObserverForEvent:(NSString *)event componentId:(NSString *)componentId usingBlock:(void (^)(NSDictionary *userInfo))block;
- (void)removeObserver:(NSString *)token;
- (void)sendEvent:(NSString *)event params:(NSDictionary *)params componentId:(NSString *)componentId;

@end
