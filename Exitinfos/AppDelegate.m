//
//  AppDelegate.m
//  Exitinfos
//
//  Created by LarryStanley on 12/8/1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    
    //Google analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 20;
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-46740441-1"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"Languages"], nil] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"Version2.4LaunchTimes"])
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"Version2.4LaunchTimes"];
    else
        [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"Version2.4LaunchTimes"]+1 forKey:@"Version2.4LaunchTimes"];
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
