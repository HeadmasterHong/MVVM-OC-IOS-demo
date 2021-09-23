//
//  LightArtParser.h
//  LightArt
//
//  Created by 彭利章 on 2018/3/19.
//

#import <Foundation/Foundation.h>

#define LIGHTART_SDK_VERSION @"1.3.0"
#define LIGHTART_VERSION @"1.3.0.4"

@interface LightArtParser : NSObject

+ (void)asyncParseWithTemplate:(id)template data:(NSDictionary *)data block:(void(^)(id))block;
+ (void)asyncParseWithTemplate:(id)template data:(NSDictionary *)data args:(id)args cache:(NSDictionary *)cache block:(void(^)(id))block;
+ (id)syncParseWithTemplate:(id)template data:(NSDictionary *)data;
+ (id)syncParseWithTemplate:(id)template data:(NSDictionary *)data args:(id)args cache:(NSDictionary *)cache;

@end
