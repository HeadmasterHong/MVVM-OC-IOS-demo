//
//  SelfCenterVC.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/4.
//

#import "SelfCenterVC.h"
#import "Masonry.h"
#import "UILabel+LabelExtension.h"
#import "FMDBoperation.h"
@interface SelfCenterVC ()
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UILabel *IDView;
@property (nonatomic,strong) UILabel *nameView;
@property (nonatomic,strong) UILabel *phoneView;
@property (nonatomic,strong) UILabel *scoreView;
@property (nonatomic,strong) Person *selfPerson;
@end

@implementation SelfCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bindPerson:self.search_id];
    [self addView];
    [self makeConstraints];
    
}
-(void)addView{
    [self.view addSubview:self.contentView];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self.contentView addSubview:self.IDView];
    [self.contentView addSubview:self.nameView];
    [self.contentView addSubview:self.phoneView];
    [self.contentView addSubview:self.scoreView];
}
-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = [UIColor systemBackgroundColor];
        
    }
    return  _contentView;
}
-(UILabel *)IDView
{
    if (!_IDView) {
        NSString *str = [NSString stringWithFormat:@"ID:%i",self.selfPerson.ID];
        _IDView = [UILabel LabelWithText:str bgColor:[UIColor systemBackgroundColor] textColor:[UIColor labelColor] fontSize:15 numberOfLine:0];
        
    }
    return _IDView;
}
-(UILabel *)nameView
{
    if (!_nameView) {
        NSString *str = [NSString stringWithFormat:@"name:%@",self.selfPerson.name];
        _nameView = [UILabel LabelWithText:str bgColor:[UIColor systemBackgroundColor] textColor:[UIColor labelColor] fontSize:15 numberOfLine:0];
    }
    return _nameView;
}
-(UILabel *)scoreView
{
    if (!_scoreView) {
        NSString *str = [NSString stringWithFormat:@"name:%@",self.selfPerson.phone];

        _scoreView = [UILabel LabelWithText:str bgColor:[UIColor systemBackgroundColor] textColor:[UIColor labelColor] fontSize:15 numberOfLine:0];
        
    }
    return _scoreView;
}
-(UILabel *)phoneView
{
    if (!_phoneView) {
        NSString *str = [NSString stringWithFormat:@"name:%i",self.selfPerson.score];

        _phoneView = [UILabel LabelWithText:str bgColor:[UIColor systemBackgroundColor] textColor:[UIColor labelColor] fontSize:15 numberOfLine:0];
        
    }
    return _phoneView;
}
-(void)makeConstraints
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(100);
    }];
    
    [self.IDView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(20);
    }];
    
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.IDView);
        make.top.mas_equalTo(self.IDView.mas_bottom).offset(40);
    }];
    
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.IDView);
        make.top.mas_equalTo(self.nameView.mas_bottom).offset(40);
    }];
    
    [self.scoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.IDView);
        make.top.mas_equalTo(self.phoneView.mas_bottom).offset(40);
        make.bottom.mas_equalTo(-20);
    }];
}

-(void)bindPerson:(NSInteger)search_id
{
    FMDBoperation *fmdb = [[FMDBoperation alloc] init];
    self.selfPerson = [fmdb findPersonByID:search_id];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // trait发生了改变

    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
    // 执行操作
        NSLog(@"系统模式切换了");
    }

    }
@end
