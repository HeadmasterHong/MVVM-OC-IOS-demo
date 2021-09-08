//
//  LightArtButton.h
//  LightArt
//
//  Created by 彭利章 on 2018/8/1.
//

#import "LightArtUIView.h"

@class LightArtButtonView;

@protocol LightArtButtonViewDelegate <NSObject>

- (void)lightArtButtonViewDidTouchUpInside:(LightArtButtonView *)buttonView;

@end

@interface LightArtButtonView : LightArtUIView

@property (nonatomic, weak) id <LightArtButtonViewDelegate> delegate;
@property (nonatomic, assign) LightArtButtonState state;

@end
