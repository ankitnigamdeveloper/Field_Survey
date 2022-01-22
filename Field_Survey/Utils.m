//
//  Utils.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import "Utils.h"
#import "AppConstants.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>

@implementation Utils

+ (UIColor*)darkGreen {
    return [UIColor colorWithRed:12.0f/255.0f green:95.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
}

+ (UIColor*)lighterGreen {
    return [UIColor colorWithRed:123.0f/255.0f green:189.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
}

+ (UIColor*)lightGrey {
    return [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
}

+ (UIColor*)darkishGrey {
    return [UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1.0f];
}

+ (UIColor*)orange {
    return [UIColor colorWithRed:255.0f/255.0f green:78.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (BOOL)string:(NSString*)str passesRegex:(NSString*)regex {
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:str];
}

// We had a lot of different places when we displayed a prompt like this, made sense to consolidate the code here.
+ (void)displayAlertWithMessage:(NSString*)message onView:(UIViewController*)viewController onOk:(void (^)(void))block {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_ok", nil) style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   if (block != nil) {
                                                       block();
                                                   }
                                               }];
    
    [alert addAction:ok];
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (BOOL)currentSubscriptionValid {
    BOOL result = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecret:UD_SECRET];
    NSString *expiryDateStr = [defaults stringForKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
    
    if (expiryDateStr != nil && expiryDateStr.length > 0) {
        // Convert expiry string to a date and compare it against the current date.
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:SUBSCRIPTION_COMPARE_FORMAT];
        // Currently we're not taking into account the timezone differences.
        expiryDateStr = [expiryDateStr componentsSeparatedByString:@" "][0];
        NSDate *expiry = [formatter dateFromString:expiryDateStr];
        
        // To keep timezones out of the compare, we need to split it from the dates.
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
        
        NSDateComponents *expiryComponents = [calendar components:comps
                                                        fromDate: expiry];
        NSDateComponents *todayComponents = [calendar components:comps
                                                        fromDate: [NSDate date]];
        
        expiry = [calendar dateFromComponents:expiryComponents];
        NSDate *today = [calendar dateFromComponents:todayComponents];
        
        if (expiry != nil) {
            // https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSDate_Class/index.html#//apple_ref/occ/instm/NSDate/compare:
            // This is checking if the 2nd argument (the date time right now) is greater than the expiry date.
            result = [expiry compare:today] != NSOrderedAscending;
        }
    }
    
    return result;
}

+ (UIViewController *)vcOfClass:(Class)class existsInNavigationController:(UINavigationController*)navigationController {
    UIViewController* viewController = nil;
    // No point checking if either of these is nil.
    if (class == nil || navigationController == nil) {
        return viewController;
    }
    
    for (UIViewController *controller in navigationController.viewControllers) {
        if ([controller isKindOfClass:class]) {
            viewController = controller;
            break;
        }
    }
    return viewController;
}

@end
