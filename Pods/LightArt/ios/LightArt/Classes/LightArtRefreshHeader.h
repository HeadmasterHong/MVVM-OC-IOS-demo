//
//  LightArtRefreshHeader.h
//  LightArt
//
//  Created by 彭利章 on 2018/4/10.
//

#import <MJRefresh/MJRefresh.h>
#import "LightArtUIView.h"

@interface LightArtRefreshHeader : MJRefreshHeader

@property (nonatomic, strong) LightArtUIComponent *contentComponent;

- (instancetype)initWithLightArtUIView:(LightArtUIView *)lightArtUIView;

@end
