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
        [self setup];
        
    }
    return self;
}

- (void)setup{
    self.layer.cornerRadius = 29;
    self.layer.masksToBounds = YES;
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    self.imgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.imgView];
    
}

- (void)configureByModel:(id<CellModelProtocol>)cellModel{
    self.imgView.image = [UIImage imageNamed:cellModel.imgPath];
    [self updateWithStatus:cellModel.isSelected];
}

-(void)updateWithStatus:(BOOL)isSelected{
    if (isSelected) {
        self.imgView.frame = CGRectMake(0, 0, 64, 64);
        self.layer.cornerRadius = 32;
        
    }else{
        self.imgView.frame = CGRectMake(0, 0, 58, 58);
        self.layer.cornerRadius = 29;
    }
}

+(CGSize)sizeForCell:(BOOL)isSelected{
    if (isSelected) {
        return CGSizeMake(64, 64);
    }else{
        return CGSizeMake(58, 58);
        
    }
}
@end
