//
//  AppDelegate.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConstants.h"
#import "Utils.h"
#import "LicenseBackgroundSyncController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.justStartedApp = YES;
    // UINavigationBar appearance.
    [[UINavigationBar appearance] setBarTintColor:[Utils darkGreen]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // UITabBar appearance.
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setItemWidth:220];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"helvetica" size:24.0f], NSFontAttributeName,
                                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                                       nil]
                                             forState:UIControlStateNormal];
    // Right, this is a bit annoying. In order to get rid of the grey tinting on unselected tabbar item icons we've set the render mode on the images manually in the Assets.xcassets. Doing it this way means if you want to change the tinting you'll need to change the image.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.justStartedApp == NO) {
        if ([Utils currentSubscriptionValid]) {
            // They've got a valid one, sync in the background if we need to.
            [[LicenseBackgroundSyncController sharedInstance] syncLicenseInBackgroundIfNeededKickoutIfExpired:YES];
        } else {
            // Invalid, need to move them to the login screen.
            [[LicenseBackgroundSyncController sharedInstance] setShouldReturnToLogin:YES];
            [[LicenseBackgroundSyncController sharedInstance] setMessageToDisplayAtLogin:NSLocalizedString(@"server_err_subscription_expired", nil)];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
