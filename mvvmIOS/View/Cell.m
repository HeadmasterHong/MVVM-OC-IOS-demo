//
//  Cell.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "Cell.h"

@implementation Cell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
    }
    return self;
}

- (void)setup{
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    self.layer.cornerRadius = 6;
    self.layer.masksToBounds = YES;
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 46, 46)];
    self.imgView.layer.cornerRadius = 2;
    self.imgView.layer.masksToBounds = YES;
    [self addSubview:self.imgView];
    
    self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(58, 12, 48, 34)];
    self.textLabel.numberOfLines = 0;//表示label可以多行显示
    self.textLabel.lineBreakMode = NSLineBreakByCharWrapping;//换行模式，与上面保持一致。
    self.textLabel.layer.cornerRadius = 6;
    self.textLabel.layer.masksToBounds = YES;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.textLabel.alpha = 1;
    [self addSubview:self.textLabel];
}

- (void)configureByModel:(id<CellModelProtocol>)cellModel{
    self.imgView.image = [UIImage imageNamed:cellModel.imgPath];
    self.textLabel.text = cellModel.eventName;
    [self updateWithStatus:cellModel.isSelected];
}

-(void)updateWithStatus:(BOOL)isSelected{
    if (isSelected) {
        self.bounds = CGRectMake(-2.5, -3, self.frame.size.width, self.frame.size.height);
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        
    }else{
        self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        
    }
}

+(CGSize)sizeForCell:(BOOL)isSelected{
    if (isSelected) {
        return CGSizeMake(120, 64);
    }else{
        return CGSizeMake(115, 58);
        
    }
}
@end
