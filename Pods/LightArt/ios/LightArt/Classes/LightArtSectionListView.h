//
//  LightArtSectionListView.h
//  LightArt
//
//  Created by 彭利章 on 2018/5/18.
//

#import "LightArtUIView.h"

@class LightArtCollectionView;

@protocol LightArtCollectionViewDelegate <NSObject>

- (BOOL)lightArtCollectionView:(LightArtCollectionView *)collectionView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

@end

@interface LightArtCollectionView : UICollectionView

@property (nonatomic, weak) id <LightArtCollectionViewDelegate> d;

@end

@interface LightArtSectionListView : LightArtUIView

@property (nonatomic, strong) LightArtCollectionView *collectionView;

@end
