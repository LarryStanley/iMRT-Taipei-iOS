//
//  AppDelegate.m
//  Exitinfos
//
//  Created by LarryStanley on 12/8/1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"Languages"]) {
        if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hant"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"Languages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hant" forKey:@"Languages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"Languages"], nil] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"Languages"], nil] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchTimes"])
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LaunchTimes"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchTimes"]+1 forKey:@"LaunchTimes"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"Languages"], nil] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}


@end
