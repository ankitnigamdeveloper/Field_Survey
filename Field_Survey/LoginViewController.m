//
//  LoginViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "LoginViewController.h"
#import "AppConstants.h"
#import "Utils.h"
#import "LicenseBackgroundSyncController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "AppDelegate.h"

@interface LoginViewController ()
@property (nonatomic) NSURLSessionDataTask* task;
@property (nonatomic) WorkingViewController* workingViewController;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goToPreviousFromSelector:)];
    UIBarButtonItemGroup* group = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[itemBack] representativeItem:nil];
    
    UITextInputAssistantItem* item = [username inputAssistantItem];
    item.trailingBarButtonGroups = @[group];
    
    item = [password inputAssistantItem];
    item.trailingBarButtonGroups = @[group];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Reset the navigation flag.
    [[LicenseBackgroundSyncController sharedInstance] setShouldReturnToLogin:NO];
    /// Check if a user is already logged in.
    // If they fail here they'll need to re-enter their login information.
    if ([Utils currentSubscriptionValid]) {
        [[LicenseBackgroundSyncController sharedInstance] syncLicenseInBackgroundKickoutIfExpired:YES];
        [self navigateToTraverseListScreen];
    }
    // No subscription, don't go in.
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setSecret:UD_SECRET];
        NSString *expiryDateStr = [defaults stringForKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
        NSString *msgToDisplay = [[LicenseBackgroundSyncController sharedInstance] messageToDisplayAtLogin];
        // Show a message if applicable.
        if (expiryDateStr != nil && expiryDateStr.length > 0 && msgToDisplay != nil && msgToDisplay.length > 0) {
            [Utils displayAlertWithMessage:msgToDisplay onView:self onOk:nil];
        }
    }
}

- (void)navigateToTraverseListScreen {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.justStartedApp = NO;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *view = (UINavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"nc_login"];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard view shifting.

- (CGFloat)getFieldOffsetForKeyboard:(CGSize)keyboardSize {
    // Check if they size passed in was initialized.
    if (CGSizeEqualToSize(CGSizeZero, keyboardSize)) {
        return 0;
    }
    
    // Use the height of the current selected element to determine the offset.
    UITextField *tmp = [self.view viewWithTag:self.currentSelectedElementTag];
    // Figure out the distance of the current field's bottom to the bottom of the view.
    CGFloat distanceToBottom = self.view.frame.size.height - (tmp.frame.origin.y + tmp.frame.size.height + 10.0);
    
    // Don't shift the page up if its already in full view.
    if (distanceToBottom > keyboardSize.height) {
        return 0.0;
    } else {
        return keyboardSize.height - distanceToBottom;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = [self getFieldOffsetForKeyboard:keyboardSize] * -1;
        self.view.frame = f;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (IBAction)handleTapOffTextField {
    [self dismissFirstResponder];
}

- (void)dismissFirstResponder {
    [username resignFirstResponder];
    [password resignFirstResponder];
}

# pragma mark - keyboard navigation.

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.currentSelectedElementTag = textField.tag;
    return YES;
}

- (void)goToPreviousFromSelector:(id)responder {
    [self goToPreviousFrom:self.currentSelectedElementTag];
}

// Modified stackoverflow answer from here http://stackoverflow.com/a/1351090
// This solution relies on us propertly tagging the ui elements.
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self goToNextFrom:textField.tag];
    
    // Return no to avoid inserting linebreaks.
    return NO;
}

# pragma mark - NavigatableButtonDelegate functions.

- (void)goToNextFrom:(NSInteger)elementTag {
    // In our case, we just go to the next cell.
    // Find the next element.
    UIResponder* next = [self.view viewWithTag:elementTag + 1];
    
    if (next) {
        // Make the next element the responder.
        self.currentSelectedElementTag = elementTag + 1;
        [next becomeFirstResponder];
    } else {
        self.currentSelectedElementTag = elementTag;
        next = [self.view viewWithTag:self.currentSelectedElementTag];
        [next resignFirstResponder];
    }
}

- (void)goToPreviousFrom:(NSInteger)elementTag {
    // Find the next element.
    UIResponder* next = [self.view viewWithTag:elementTag - 1];
    
    if (next) {
        // Make the next element the responder.
        self.currentSelectedElementTag = elementTag - 1;
        [next becomeFirstResponder];
    } else {
        self.currentSelectedElementTag = elementTag;
    }
}

# pragma mark - Field validation.

// Returns an empty string if there was no error. Doing it like this forces some indication of what went wrong.
- (NSString*)checkFieldStatus {
    NSString *err_msg = @"";
    
    if (username.text.length == 0) {
        err_msg = NSLocalizedString(@"login_err_no_username", nil);
    }
    else if (password.text.length == 0) {
        err_msg = NSLocalizedString(@"login_err_no_password", nil);
    }
    
    return err_msg;
}

# pragma mark - Login attempt.

- (IBAction)pressedLogin {
    // Check for errors.
    NSString* fieldStatus = [self checkFieldStatus];
    if (fieldStatus.length == 0) {
        [self dismissFirstResponder];
        // Make the request.
        [self displayWorkingViewUseDescription:NSLocalizedString(@"working_attempting_login", nil) hideCancel:NO onCompletion:^{
            [self attemptLogin];
        }];
    }
    // Failed, display a reason.
    else {
        [Utils displayAlertWithMessage:fieldStatus onView:self onOk:nil];
    }
}

- (void)attemptLogin {
    // Create the URL.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_BASE_URL, SERVER_MOBILE_LOGIN_ENDPOINT]];
    
    // Create the request.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setValue:username.text forKey:@"username"];
    [dict setValue:password.text forKey:@"password"];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"device_id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonString length] ] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    
    // Create the data task.
    NSURLSession *session = [NSURLSession sharedSession];
    
    self.task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
        // Save what they entered here while the working view is still being displayed; eliminates the chance of them changing the value between when the working view disappears, and when the
        NSString* usernameStr = username.text;
        NSString* passwordStr = password.text;
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
                        // Save the data to NSUserDefaults.
                        // Set the secure secret for the user defaults.
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setSecret:UD_SECRET];
                        // Store their credentials.
                        [defaults setSecretObject:usernameStr forKey:UD_KEY_USERNAME];
                        [defaults setSecretObject:passwordStr forKey:UD_KEY_PASSWORD];
                        
                        if ([responseData valueForKey:@"expiry_date"] != [NSNull null]) {
                            [defaults setValue:[responseData valueForKey:@"expiry_date"] forKey:UD_KEY_SUBSCRIPTION_EXPIRY_DATE];
                        }
                        if ([responseData valueForKey:@"company"] != [NSNull null]) {
                            [defaults setValue:[responseData valueForKey:@"company"] forKey:UD_KEY_COMPANY];
                        }
                        // Update the last time it was synchronized.
                        [defaults setObject:[NSDate date] forKey:UD_KEY_LAST_TIME_SYNCED];
                        
                        [defaults synchronize];
                        
                        // Go to the traverse list.
                        [[LicenseBackgroundSyncController sharedInstance] setShouldReturnToLogin:NO];
                        [self navigateToTraverseListScreen];
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

# pragma mark - Working view display & delegate functions.

- (void)displayWorkingViewUseDescription:(NSString*)description hideCancel:(BOOL)hideCancel onCompletion:(void (^)(void))block {
    // Need to use dispatch_async as we set values on the view controller, and you can't do that on any thread other than main.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Initialize the workingViewController if it doesn't exist.
        if (self.workingViewController == nil) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            self.workingViewController = (WorkingViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_working"];
            self.workingViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.workingViewController.delegate = self;
        }
        self.workingViewController.cancelButtonIsHidden = hideCancel;
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
