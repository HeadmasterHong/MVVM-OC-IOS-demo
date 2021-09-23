//
//  LightArtRefreshFooter.h
//  LightArt
//
//  Created by 彭利章 on 2018/6/5.
//

#import <MJRefresh/MJRefresh.h>
#import "LightArtUIView.h"

@interface LightArtLoadMoreFooter : MJRefreshAutoFooter

@property (nonatomic, strong) LightArtUIComponent *contentComponent;

- (instancetype)initWithLightArtUIView:(LightArtUIView *)lightArtUIView;

@end
