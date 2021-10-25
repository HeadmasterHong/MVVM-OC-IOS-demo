//
//  SecondViewModel.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/19.
//

#import "SecondViewModel.h"
#import "CellModel.h"

static NSArray *collectionViewCellArrayName() {
    return @[@"Cell",
             @"RowCell"
    ];
}

@implementation SecondViewModel
- (NSUInteger)numberOfSections{
    return 1;
}

- (NSUInteger)numberOfRowsInSection:(NSInteger)section{
    return [self.cellModelArry count];
}

- (id<CellModelProtocol>)cellModelAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cellModelArry objectAtIndex:(indexPath.section+indexPath.row)];
}



+ (void)enumerateCellClassNamesUsingBlock:(void (^)(NSString *cellClassName))block{
    if (!block) {
        return;
    }
    for (NSString *className in collectionViewCellArrayName()) {
        if (block) {
            block(className);
        }
    }
}

- (instancetype)initSelf{
    self = [super init];
    if (self) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *pilstPath = [bundle pathForResource:@"eventss" ofType:@"plist"];
        NSArray *arr = [[NSArray alloc] initWithContentsOfFile:pilstPath];
        self.cellModelArry = [[NSMutableArray alloc] init];
        
        for (id dict in arr) {
            CellModel *cellModel = [[CellModel alloc] init];
            cellModel.eventName = [dict objectForKey:@"name"];
            cellModel.imgPath = [dict objectForKey:@"image"];
            cellModel.cellIdentifier = [dict objectForKey:@"cellIdentifier"];
            [self.cellModelArry addObject:cellModel];
        }
        
    }
    
    return self;
}

-(NSInteger)changeLayout:(NSInteger)flag{
    NSString *newLayout = flag>1?@"Cell":@"RowCell";
    for (id<CellModelProtocol> obj in self.cellModelArry) {
        obj.cellIdentifier = newLayout;
    }
    return flag>1?:2;
}
@end
