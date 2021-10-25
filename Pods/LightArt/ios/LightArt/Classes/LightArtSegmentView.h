//
//  LightArtSegmentView.h
//  LightArt
//
//  Created by 彭利章 on 2018/8/1.
//

#import "LightArtUIView.h"

@class LightArtSegmentView;

@protocol LightArtSegmentViewDelegate <NSObject>

- (BOOL)lightArtSegmentView:(LightArtSegmentView *)segmentView shouldSelectIndex:(NSUInteger)index;
- (void)lightArtSegmentView:(LightArtSegmentView *)segmentView didSelectIndex:(NSUInteger)index;

@end

@interface LightArtSegmentView : LightArtUIView

@property (nonatomic, assign) id <LightArtSegmentViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end
