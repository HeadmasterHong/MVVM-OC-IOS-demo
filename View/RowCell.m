//
//  RowCell.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/18.
//

#import "RowCell.h"

@implementation RowCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 200, 200)];
        [self addSubview:self.imgView];
        
        self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.imgView.frame), CGRectGetHeight(self.frame)*0.5, 200, 20)];

        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
    }
    return self;
}
- (void)configureByModel:(id<CellModelProtocol>)cellModel{
    self.imgView.image = [UIImage imageNamed:cellModel.imgPath];
    self.textLabel.text = cellModel.eventName;
}
@end
