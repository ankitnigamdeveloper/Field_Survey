//
//  SettingsViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppConstants.h"
#import "Utils.h"
#import "Traverse.h"
#import "Station.h"
#import "StationDefaults.h"
#import "SideShot.h"
#import "ActiveRecord.h"
#import "LoginViewController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "AppConstants.h"

@interface SettingsViewController ()
@property (nonatomic) NSURLSessionDataTask* task;
@property (nonatomic) WorkingViewController* workingViewController;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    appVersion.text = version;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set the user info.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecret:UD_SECRET];
    NSString *usernameStr = [defaults secretStringForKey:UD_KEY_USERNAME];
    NSString* companyStr = [defaults stringForKey:UD_KEY_COMPANY];
    NSString* expiryDateStr = [defaults stringForKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
    username.text = usernameStr != nil ? usernameStr : @"";
    company.text = companyStr != nil ? companyStr : @"";
    subscriptionDate.text = expiryDateStr != nil ? expiryDateStr : @"";
}

- (IBAction)pressedBawtreeLogo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BAWTREE_PRODUCT_URL]];
}

- (IBAction)pressedSoftreeLogo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SOFTREE_PRODUCT_URL]];
}

# pragma mark - Logout attempt.

- (IBAction)pressedLogout:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"settings_logout_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yes = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_yes", nil) style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                    // Initiate logout
                                                    [self displayWorkingViewUseDescription:NSLocalizedString(@"working_attempting_logout", nil) onCompletion:^{
                                                        [self attemptLogout];
                                                    }];
                                                }];
    UIAlertAction* no = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_no", nil) style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)attemptLogout {
    // Create the URL.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_BASE_URL, SERVER_MOBILE_LOGOUT_ENDPOINT]];
    
    // Create the request.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecret:UD_SECRET];
    NSString *usernameStr = [defaults secretStringForKey:UD_KEY_USERNAME];
    NSString *passwordStr = [defaults secretStringForKey:UD_KEY_PASSWORD];
    
    [dict setValue:usernameStr forKey:@"username"];
    [dict setValue:passwordStr forKey:@"password"];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"device_id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        [self dismissWorkingViewOnCompletion:^{
            // TODO Display error message
            return;
        }];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonString length] ] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    
    // Create the data task.
    NSURLSession *session = [NSURLSession sharedSession];
    
    self.task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
        // Dismiss the working overlay.
        [self dismissWorkingViewOnCompletion:^{            
            // Check for errors.
            if (error != nil) {
                if (error.code != NSURLErrorCancelled) {
                    [Utils displayAlertWithMessage:error.localizedDescription onView:self onOk:nil];
                }
            }
            
            // Otherwise process the response.
            else {
                NSError *conversionError;
                NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&conversionError];
                if (conversionError != nil || [responseData valueForKey:@"response_code"] == [NSNull null]) {
                    [Utils displayAlertWithMessage:NSLocalizedString(@"err_processing_data", nil) onView:self onOk:nil];
                }
                // Process the converted data.
                else {
                    NSInteger serverResponse = [[responseData valueForKey:@"response_code"] integerValue];
                    // We get back a value like "<null>" if it was null.
                    // Check if we've succeeded.
                    if (serverResponse == SUCCESSFUL_REQUEST) {
                        [self logoutSuccessful];
                    }
                    // There was an error; show the proper message.
                    else {
                        NSString* error_message = @"";
                        switch (serverResponse) {
                            case INCOMPLETE_REQUEST:
                                error_message = NSLocalizedString(@"server_err_incomplete_request", nil);
                                break;
                                
                            case USER_NOT_FULLY_SETUP:
                                error_message = NSLocalizedString(@"server_err_user_not_fully_setup", nil);
                                break;
                                
                            case INACTIVE_USER:
                                error_message = NSLocalizedString(@"server_err_user_inactive", nil);
                                break;
                                
                            case BAD_CREDENTIALS:
                                error_message = NSLocalizedString(@"server_err_bad_credentials", nil);
                                break;
                                
                            case WRONG_REQUEST_METHOD:
                                error_message = NSLocalizedString(@"server_err_wrong_request_method", nil);
                                break;
                                
                            case SUBSCRIPTION_EXPIRED:
                                error_message = NSLocalizedString(@"server_err_subscription_expired", nil);
                                break;
                                
                            case ACCOUNT_ALREADY_IN_USE:
                                error_message = NSLocalizedString(@"server_err_account_already_in_use", nil);
                                break;
                                
                            default:
                                break;
                        }
                        [Utils displayAlertWithMessage:error_message onView:self onOk:nil];
                    }
                }
            }
        }];
    }];
    
    // Start the task.
    [self.task resume];
}

- (void)logoutSuccessful {
    // Delete all the local data.
    [SideShot deleteAll];
    [SideShot commit];
    [Station deleteAll];
    [Station commit];
    [StationDefaults deleteAll];
    [StationDefaults commit];
    [Traverse deleteAll];
    [Traverse commit];
    // Clear the user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecret:UD_SECRET];
    [defaults removeObjectForKey:UD_KEY_USERNAME];
    [defaults removeObjectForKey:UD_KEY_PASSWORD];
    [defaults removeObjectForKey:UD_KEY_COMPANY];
    [defaults removeObjectForKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
    [defaults removeObjectForKey:UD_KEY_LAST_TIME_SYNCED];
    [defaults synchronize];
    // Navigate back to the login screen.
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LoginViewController *view = (LoginViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_login"];
    [self presentViewController:view animated:YES completion:nil];
}

# pragma mark - Sync license attempt.

- (IBAction)pressedSyncLicense {
    [self displayWorkingViewUseDescription:NSLocalizedString(@"working_syncing_license", nil) onCompletion:^{
        [self attemptSyncLicense];
    }];
}

- (void)attemptSyncLicense {
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
    NSURLSession *session = [NSURLSession sharedSession];
    
    self.task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
        // Dismiss the working overlay.
        [self dismissWorkingViewOnCompletion:^{
            // Check for errors.
            if (error != nil) {
                if (error.code != NSURLErrorCancelled) {
                    [Utils displayAlertWithMessage:error.localizedDescription onView:self onOk:nil];
                }
            }
            
            // Otherwise process the response.
            else {
                NSError *conversionError;
                NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&conversionError];
                if (conversionError != nil || [responseData valueForKey:@"response_code"] == [NSNull null]) {
                    NSLog(@"%@", responseData);
                    [Utils displayAlertWithMessage:NSLocalizedString(@"err_processing_data", nil) onView:self onOk:nil];
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
                        [self licenseUpdated];
                    }
                    // There was an error; show the proper message.
                    else {
                        NSString* error_message = @"";
                        // Expired subscription is a specific case.
                        if (serverResponse == SUBSCRIPTION_EXPIRED) {
                            
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setSecret:UD_SECRET];
                            // Store their credentials.
                            if ([responseData valueForKey:@"expiry_date"] != [NSNull null]) {
                                [defaults setValue:[responseData valueForKey:@"expiry_date"] forKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
                            }
                            // Update the last time it was synchronized.
                            [defaults setObject:[NSDate date] forKey:UD_KEY_LAST_TIME_SYNCED];
                            [defaults synchronize];
                            
                            error_message = NSLocalizedString(@"server_err_subscription_expired", nil);
                            // Display the message and kick out to login.
                            [Utils displayAlertWithMessage:error_message onView:self onOk:^{
                                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                LoginViewController *view = (LoginViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_login"];
                                [self presentViewController:view animated:YES completion:nil];
                            }];
                            return;
                        }
                        else {
                            switch (serverResponse) {
                                case INCOMPLETE_REQUEST:
                                    error_message = NSLocalizedString(@"server_err_incomplete_request", nil);
                                    break;
                                    
                                case USER_NOT_FULLY_SETUP:
                                    error_message = NSLocalizedString(@"server_err_user_not_fully_setup", nil);
                                    break;
                                    
                                case INACTIVE_USER:
                                    error_message = NSLocalizedString(@"server_err_user_inactive", nil);
                                    break;
                                    
                                case BAD_CREDENTIALS:
                                    error_message = NSLocalizedString(@"server_err_bad_credentials", nil);
                                    break;
                                    
                                case WRONG_REQUEST_METHOD:
                                    error_message = NSLocalizedString(@"server_err_wrong_request_method", nil);
                                    break;
                                    
                                case ACCOUNT_ALREADY_IN_USE:
                                    error_message = NSLocalizedString(@"server_err_account_already_in_use", nil);
                                    break;
                                    
                                default:
                                    break;
                            }
                            
                            [Utils displayAlertWithMessage:error_message onView:self onOk:nil];
                        }
                    }
                }
            }
        }];
    }];
    
    // Start the task.
    [self.task resume];
}

- (void)licenseUpdated {
    // Update the display data.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecret:UD_SECRET];
    NSString *usernameStr = [defaults secretStringForKey:UD_KEY_USERNAME];
    NSString* companyStr = [defaults stringForKey:UD_KEY_COMPANY];
    NSString* expiryDateStr = [defaults stringForKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
    username.text = usernameStr != nil ? usernameStr : @"";
    company.text = companyStr != nil ? companyStr : @"";
    subscriptionDate.text = expiryDateStr != nil ? expiryDateStr : @"";
    
    [Utils displayAlertWithMessage:NSLocalizedString(@"settings_license_sync_success", nil) onView:self onOk:nil];
}

# pragma mark - Working view display & delegate functions.

- (void)displayWorkingViewUseDescription:(NSString*)description onCompletion:(void (^)(void))block {
    // Need to use dispatch_async as we set values on the view controller, and you can't do that on any thread other than main.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Initialize the workingViewController if it doesn't exist.
        if (self.workingViewController == nil) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            self.workingViewController = (WorkingViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_working"];
            self.workingViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.workingViewController.delegate = self;
            self.workingViewController.cancelButtonIsHidden = NO;
        }
        self.workingViewController.taskText = description;
        [self presentViewController:self.workingViewController animated:NO completion:block];
    });
}

- (void)dismissWorkingViewOnCompletion:(void (^)(void))block {
    if (self.workingViewController != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.workingViewController dismissViewControllerAnimated:YES completion:block];
        });
    }
}

- (void)pressedCancel {
    if (self.task && self.task.state == NSURLSessionTaskStateRunning) {
        [self.task cancel];
    }
}

@end
