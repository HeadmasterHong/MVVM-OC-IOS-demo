//
//  LightArtSectionListLayout.h
//  lightart
//
//  Created by 彭利章 on 2018/5/14.
//  Copyright © 2018年 bingwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LightArtDocument.h"

@interface LightArtSectionListLayout : UICollectionViewLayout

@property (nonatomic, strong) LightArtSectionList *sectionList;

- (void)caculateLayout;

@end
