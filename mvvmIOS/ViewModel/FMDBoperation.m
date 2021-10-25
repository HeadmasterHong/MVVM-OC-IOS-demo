//
//  FMDBoperation.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/8/4.
//

#import "FMDBoperation.h"
#import "FMDatabase.h"

@interface FMDBoperation ()

@property (nonatomic,strong)FMDatabase *db;
@end

@implementation FMDBoperation

-(void)openDatabase
{
    //FMDB
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docuPath stringByAppendingPathComponent:@"test.db"];
    NSLog(@">>> sql lite address %@",dbPath);
    self.db = [FMDatabase databaseWithPath:dbPath];
    [self.db open];
}
-(Person *)findPersonByID:(NSInteger)sear_id{
    [self openDatabase];
    Person *res = [[Person alloc] init];
    if (!([_db open])) {
        NSLog(@"fail DB");
        return nil;
    }
    FMResultSet *result = [_db executeQuery:@"SELECT * FROM t_student WHERE ID = ?" withArgumentsInArray:@[[NSNumber numberWithInteger:sear_id]]];
    while ([result next]) {
        res.ID = (int)sear_id;
        res.name = [result stringForColumn:@"name"];
        res.phone = [result stringForColumn:@"phone"];
        res.score = [result intForColumn:@"score"];
    }
    [_db close];
    
    return res;
}

@end
