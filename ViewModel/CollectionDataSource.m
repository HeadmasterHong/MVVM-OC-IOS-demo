//
//  CollectionDataSource.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/11.
//

#import "CollectionDataSource.h"

@interface CollectionDataSource()

@property (nonatomic,strong) NSArray *events;
@property (nonatomic,copy) NSString *identifier;

@end

@implementation CollectionDataSource


- (instancetype)initWithCellIdentifier:(NSString *)identifier{
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pilstPath = [bundle pathForResource:@"events" ofType:@"plist"];
    NSArray *dict = [[NSArray alloc] initWithContentsOfFile:pilstPath];
    self.events = dict;
    return self;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.events count]/2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    NSDictionary *event = [self.events objectAtIndex:(indexPath.section*2 + indexPath.row)];
    
    cell.textLabel.text = [event objectForKey:@"name"];
    cell.imgView.image = [UIImage imageNamed:[event objectForKey:@"image"]];

    return cell;
}

@end
