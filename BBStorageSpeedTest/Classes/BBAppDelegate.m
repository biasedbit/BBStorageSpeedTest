//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBAppDelegate.h"

#import "BBBenchmarkViewController.h"



#pragma mark -

@implementation BBAppDelegate


#pragma mark Property synthesizers

@synthesize window = _window;


#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    BBBenchmarkViewController* rootController = [[BBBenchmarkViewController alloc] init];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:rootController];
    _window.rootViewController = navController;

    return YES;
}

@end
