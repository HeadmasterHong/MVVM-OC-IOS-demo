//
//  AppDelegate.m
//  NoStoryBoard2
//
//  Created by 洪泽林[运营中心] on 2021/7/27.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

//@property (nonatomic, strong)

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(screenDidConnectNotification) name: UIScreenDidConnectNotification object: nil];
    
    
    NSArray<UIScreenMode *> *availableModes = [[UIScreen mainScreen] availableModes];
    NSLog(@"%lu",availableModes.count);
    NSLog(@"%@", [UIScreen screens]);
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.screen = [UIScreen mainScreen];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *vc = [[ViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    
    
    
    // Override point for customization after application launch.
    return YES;
}

- (void)screenDidConnectNotification {
    CGSize size960;
    size960.height = 0;
    size960.width  = 0;
    UIScreenMode *screenMode960 = nil;
    UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:0];
    for(int i = 0; i < [[secondScreen availableModes] count]; i++)
    {
        NSLog(@"%@",[UIScreen screens]);
       UIScreenMode *current = [[[[UIScreen screens] objectAtIndex:0] availableModes] objectAtIndex: i];
       NSLog(@"%@",current);

       if (current.size.width == 960.0 && current.size.height == 2079.0)
       {
           size960 = current.size;
           screenMode960 = current;
           break;
       }
    }
    secondScreen.currentMode = screenMode960;
}


#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
