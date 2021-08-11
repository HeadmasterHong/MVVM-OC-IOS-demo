//
//  MainTableDataSource.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/10.
//

#import "MainTableDataSource.h"
#import "TeamModel.h"
#import "TableCell.h"
@interface MainTableDataSource ()
@property (nonatomic,copy) void (^configure) (id cell,id model, NSIndexPath *indexPath);
@property (nonatomic,copy) NSString *identifier;
@end

@implementation MainTableDataSource

- (instancetype)initWithCellIdentifier:(NSString *)identifier configure:(void (^)(id _Nonnull, id _Nonnull, NSIndexPath * _Nonnull))configure  {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _configure = configure;
    }
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPAth = [bundle pathForResource:@"team" ofType:@"plist"];
    self.dictTeams = [[NSDictionary alloc] initWithContentsOfFile:plistPAth];
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dictTeams.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dictTeams objectForKey:[[_dictTeams allKeys] objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str = [[_dictTeams allKeys] objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ section", str];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    
    if(cell == nil){
        cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.identifier];
    }
    NSInteger section = indexPath.section;
    NSArray *rowArr = [_dictTeams objectForKey:[[self.dictTeams allKeys] objectAtIndex:section]];
    NSDictionary *rowDict = [rowArr objectAtIndex:[indexPath row]];
    TeamModel *teamModel = [TeamModel new];
    teamModel.name = [rowDict objectForKey:@"name"];
    teamModel.image = [rowDict objectForKey:@"image"];
    if (self.configure) {
        self.configure(cell,teamModel,indexPath);
    }
    
    return cell;
}

@end
