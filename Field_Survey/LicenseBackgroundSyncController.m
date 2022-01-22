//
//  LicenseBackgroundSyncController.m
//  Field_Survey
//
//  Created by Martin on 2016/07/22.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import "LicenseBackgroundSyncController.h"
#import "AppConstants.h"
#import "Utils.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>

@interface LicenseBackgroundSyncController ()
@property (nonatomic, retain) NSMutableData* receivedData;
@property (nonatomic) BOOL kickoutOnBadSubscription;
@end

@implementation LicenseBackgroundSyncController

@synthesize shouldReturnToLogin;
@synthesize messageToDisplayAtLogin;

+ (id)sharedInstance {
    static LicenseBackgroundSyncController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.receivedData = nil;
        self.kickoutOnBadSubscription = NO;
    }
    return self;
}

- (void)syncLicenseInBackgroundIfNeededKickoutIfExpired:(BOOL)kickout {
    // Checks if we need to sync the license.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecret:UD_SECRET];
    NSDate *lastTimeSynced = [defaults objectForKey:UD_KEY_LAST_TIME_SYNCED];
    
    if (lastTimeSynced != nil) {
        // We only care if the day value is different.
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
        
        NSDateComponents *lastTimeSyncedComponents = [calendar components:comps
                                                         fromDate:lastTimeSynced];
        NSDateComponents *todayComponents = [calendar components:comps
                                                        fromDate:[NSDate date]];
        
        // If the day values are different then we should do a sync.
        if (lastTimeSyncedComponents.day != todayComponents.day) {
            [self syncLicenseInBackgroundKickoutIfExpired:kickout];
        }
    } else {
        // I don't think we can get to this state if they've logged in, but this should handle those situations.
        [self syncLicenseInBackgroundKickoutIfExpired:kickout];
    }
}

- (void)syncLicenseInBackgroundKickoutIfExpired:(BOOL)kickout {
    // If its not nil then we're already doing something.
    if (self.receivedData != nil) {
        return;
    }
    
    self.kickoutOnBadSubscription = kickout;
    self.receivedData = [[NSMutableData alloc] init];
    
    // Launch session on a background thread.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecret:UD_SECRET];
    NSString *usernameStr = [defaults secretStringForKey:UD_KEY_USERNAME];
    NSString *passwordStr = [defaults secretStringForKey:UD_KEY_PASSWORD];
    
    // Create the URL.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@username=%@&password=%@", SERVER_BASE_URL, SERVER_MOBILE_SYNC_LICENSE_ENDPOINT, usernameStr, passwordStr]];
    
    // Create the request.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Create the data task.
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"licenseSync"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    
    // Start the task.
    [task resume];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data {
    if (data) {
        [self.receivedData appendData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSString* message = nil;
    // Check for errors.
    if (error != nil) {
        message = error.localizedDescription;
    }
    
    // Otherwise process the response.
    else {
        NSError *conversionError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&conversionError];
        if (conversionError != nil || [responseData valueForKey:@"response_code"] == [NSNull null]) {
            message = NSLocalizedString(@"err_processing_data", nil);
        }
        // Process the converted data.
        else {
            NSInteger serverResponse = [[responseData valueForKey:@"response_code"] integerValue];
            // We get back a value like "<null>" if it was null.
            // Check if we've succeeded.
            if (serverResponse == SUCCESSFUL_REQUEST) {
                // Save the data to NSUserDefaults.
                // Set the secure secret for the user defaults.
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setSecret:UD_SECRET];
                // Store their credentials.
                if ([responseData valueForKey:@"expiry_date"] != [NSNull null]) {
                    [defaults setValue:[responseData valueForKey:@"expiry_date"] forKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
                }
                if ([responseData valueForKey:@"company"] != [NSNull null]) {
                    [defaults setValue:[responseData valueForKey:@"company"] forKey:UD_KEY_COMPANY];
                }
                // Update the last time it was synchronized.
                [defaults setObject:[NSDate date] forKey:UD_KEY_LAST_TIME_SYNCED];
                
                [defaults synchronize];
            }
            // There was an error.
            else {
                if (SUBSCRIPTION_EXPIRED == serverResponse) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setSecret:UD_SECRET];
                    // Store their credentials.
                    if ([responseData valueForKey:@"expiry_date"] != [NSNull null]) {
                        [defaults setValue:[responseData valueForKey:@"expiry_date"] forKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
                    }
                    if ([responseData valueForKey:@"company"] != [NSNull null]) {
                        [defaults setValue:[responseData valueForKey:@"company"] forKey:UD_KEY_COMPANY];
                    }
                    // Update the last time it was synchronized.
                    [defaults setObject:[NSDate date] forKey:UD_KEY_LAST_TIME_SYNCED];
                    [defaults synchronize];
                    
                    if (self.kickoutOnBadSubscription) {
                        // Need to kick them out to the login screen.
                        self.messageToDisplayAtLogin = NSLocalizedString(@"server_err_subscription_expired", nil);
                        self.shouldReturnToLogin = YES;
                    }
                } else {
                    switch (serverResponse) {
                        case INCOMPLETE_REQUEST:
                            message = NSLocalizedString(@"server_err_incomplete_request", nil);
                            break;
                            
                        case USER_NOT_FULLY_SETUP:
                            message = NSLocalizedString(@"server_err_user_not_fully_setup", nil);
                            break;
                            
                        case INACTIVE_USER:
                            message = NSLocalizedString(@"server_err_user_inactive", nil);
                            break;
                            
                        case BAD_CREDENTIALS:
                            message = NSLocalizedString(@"server_err_bad_credentials", nil);
                            break;
                            
                        case WRONG_REQUEST_METHOD:
                            message = NSLocalizedString(@"server_err_wrong_request_method", nil);
                            break;
                            
                        case ACCOUNT_ALREADY_IN_USE:
                            message = NSLocalizedString(@"server_err_account_already_in_use", nil);
                            break;
                            
                        default:
                            break;
                    }
                }
            }
        }
    }
    [session finishTasksAndInvalidate];
    self.receivedData = nil;
}


- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    // Session failed, reset the received data.
    self.receivedData = nil;
}
@end
