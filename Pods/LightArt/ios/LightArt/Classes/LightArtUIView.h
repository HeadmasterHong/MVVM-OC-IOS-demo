//
//  LightArtUIView.h
//  LightArt
//
//  Created by 彭利章 on 2018/3/22.
//

#import <UIKit/UIKit.h>
#import "LightArtDocument.h"

@interface UIColor (LightArt)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

@interface UIView (LightArt)

@property (nonatomic) CGFloat la_left;
@property (nonatomic) CGFloat la_top;
@property (nonatomic) CGFloat la_right;
@property (nonatomic) CGFloat la_bottom;
@property (nonatomic) CGFloat la_width;
@property (nonatomic) CGFloat la_height;
@property (nonatomic) CGPoint la_origin;
@property (nonatomic) CGSize la_size;

@end

@interface LightArtUIView : UIView

@property (nonatomic, strong) NSValue *oldSizeValue;

+ (LightArtUIView *)viewWithModel:(LightArtUIComponent *)model;
- (void)setModel:(LightArtUIComponent *)model;
- (LightArtUIComponent *)model;
- (void)refreshFrameWithParentSize:(CGSize)parentSize;

/**
 * 如果是容器，则实现此方法，当子组件被更新时调用
 */
- (void)reloadData;
- (void)reallyReloadData;
- (void)refreshFrame;
- (void)reallyRefreshFrame;
- (void)scrollTo:(NSDictionary *)params;
- (BOOL)setupWithModel:(LightArtUIComponent *)model;
- (NSString *)identifier;
- (void)startAnimation;

@end
