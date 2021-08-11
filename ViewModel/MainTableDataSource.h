//
//  MainTableDataSource.h
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface MainTableDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithCellIdentifier:(NSString *)identifier configure:(void(^)(id cell,id model,NSIndexPath *indexPath))configure;
@property (nonatomic, strong) NSDictionary *dictTeams;
@end

NS_ASSUME_NONNULL_END
