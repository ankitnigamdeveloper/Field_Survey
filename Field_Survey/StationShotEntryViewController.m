//
//  StationShotEntryViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "StationShotEntryViewController.h"
#import "Utils.h"
#import "AppConstants.h"
#import "Station.h"
#import "StationDefaults.h"
#import "ActiveRecord.h"
#import "LicenseBackgroundSyncController.h"
#import "DataController.h"


@interface StationShotEntryViewController ()
@property (nonatomic, strong) UIBarButtonItemGroup* group;
@property (nonatomic) StationDefaultValuesViewController* stationDefaultsViewController;
@property (nonatomic) BOOL shouldRecalculateFields; // Used locally for tracking whether or not we've updated the distance calculations after we changed them.
@property (nonatomic, strong) NSDecimalNumberHandler *decimalRoundingBehaviour;
@end

@implementation StationShotEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup field navigation.
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goToPrevious)];
    self.group = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[itemBack] representativeItem:nil];
    
    self.decimalRoundingBehaviour = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                              scale:1
                                                                                   raiseOnExactness:NO
                                                                                    raiseOnOverflow:NO
                                                                                   raiseOnUnderflow:NO
                                                                                raiseOnDivideByZero:NO];
    
    slopeDistanceBtn.delegate = self;
    horizontalDistance.delegate = self;
    pipeBtn.delegate = self;
    boxBtn.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set selectors.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    // Need to set this every time the view appears so the next station button targets the current viewcontroller.
    UIBarButtonItem* rightNextBarButton = [self.parentViewController.navigationItem rightBarButtonItem];
    [rightNextBarButton setTarget:self];
    
    // Set navigation title. Regrettably needs to be set every time it will show.
    [self.parentViewController.navigationItem setTitle:@"C/L Station & Shot"];
    // Load data, update button states, update strings.
    [self loadData];
    [self updateTabStates];
    [self updatePreviousNextButtons];
    [self updateRadioButtons];
    [self updateFieldStates];
    currentStationInfo.text = [NSString stringWithFormat:NSLocalizedString(@"general_station_info_heading", nil), [[DataController sharedInstance] currentStation].calcStation];
    
    if ([[LicenseBackgroundSyncController sharedInstance] shouldReturnToLogin] == YES) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *view = (UIViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_login"];
        [self presentViewController:view animated:YES completion:nil];
    }
    [super updateInsertText];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    // Save the changes to the station entry.
    [self saveData];
    
    NSInteger currentStationIndex = [[[DataController sharedInstance] currentTraverse].relStation indexOfObject:[[DataController sharedInstance] currentStation]];
    // Check if we're at the invalid index.
    if (currentStationIndex == [[DataController sharedInstance] invalidStationIndex]) {
        [[DataController sharedInstance] recheckValidityOfCurrentInvalidStation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goToNextStation {
    // Run updates.
    [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:[[DataController sharedInstance] currentStation]];
    // Go to the next one.
    [[DataController sharedInstance] nextStation];
    // Reload the screens data.
    [self loadData];
    [self updateTabStates];
    [self updatePreviousNextButtons];
    [self updateFieldStates];
    [self updateRadioButtons];
    currentStationInfo.text = [NSString stringWithFormat:NSLocalizedString(@"general_station_info_heading", nil), [[DataController sharedInstance] currentStation].calcStation];
    [super updateInsertText];
}

- (void)goToPreviousStation {
    // Run updates.
    [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:[[DataController sharedInstance] currentStation]];
    // Go to the previous station.
    [[DataController sharedInstance] previousStation];
    // Reload the screens data.
    [self loadData];
    [self updateTabStates];
    [self updatePreviousNextButtons];
    [self updateFieldStates];
    [self updateRadioButtons];
    currentStationInfo.text = [NSString stringWithFormat:NSLocalizedString(@"general_station_info_heading", nil), [[DataController sharedInstance] currentStation].calcStation];
    [super updateInsertText];
}

# pragma mark - Button functions.

- (IBAction)pressedInsert:(id)sender {
    // Save the values.
    [self saveData];
    
    // Check if we can go to the next station.
    NSString *fieldCheck = [[DataController sharedInstance] stationValuesValid:[[DataController sharedInstance] currentStation]];
    // If we didn't find an error and we have an invalid station then set the value.
    NSInteger currentStationIndex = 0;
    if (fieldCheck.length == 0) {
        currentStationIndex = [[[DataController sharedInstance] currentTraverse].relStation indexOfObject:[[DataController sharedInstance] currentStation]];
        // If we made it here then check if there is an invalid station.
        if ([[DataController sharedInstance] allStationsValid] == NO) {
            [[DataController sharedInstance] recheckValidityOfCurrentInvalidStation];
            // Check if there is still a problem.
            if ([[DataController sharedInstance] allStationsValid] == NO) {
                fieldCheck = [NSString stringWithFormat:NSLocalizedString(@"data_controller_err_cant_make_invalid_station_exists", nil), [[DataController sharedInstance] currentInvalidStation].calcStationIndex];
            }
        }
    }
    
    if (fieldCheck.length == 0) {
        // At this point create a new station and go to it.
        [[DataController sharedInstance] insertNewStationAtIndex:currentStationIndex];
        [self goToNextStation];
    } else {
        // Something went wrong, show the message.
        [Utils displayAlertWithMessage:fieldCheck onView:self onOk:nil];
    }
}


- (IBAction)pressedNext:(id)sender {
    // Save the values.
    [self saveData];
    // Go to the next one.
    [self goToNextStation];
}

- (IBAction)pressedPrevious:(id)sender {
    // Save the values.
    [self saveData];
    // Go to the previous one.
    [self goToPreviousStation];
}

# pragma mark - Save / Load data functions.

- (void)loadData {
    Station *station = [[DataController sharedInstance] currentStation];
    if (station) {
        [typeBtn setTitle:station.stType forState:UIControlStateNormal];
        foreAzimuth.text = station.stForeAzimuth != nil ? [station.stForeAzimuth stringValue] : @"";
        
        slopeDistance.text = station.stSlopeDistance != nil ? [station.stSlopeDistance stringValue] : @"";
        NSAttributedString* slpDistancePlaceholder = [[NSAttributedString alloc] initWithString:(station.calcSlopeDistance != nil ? [station.calcSlopeDistance stringValue] : @"") attributes:@{NSForegroundColorAttributeName: [Utils darkishGrey]}];
        slopeDistance.attributedPlaceholder = slpDistancePlaceholder;
        
        horizontalDistance.text = station.stHorizontalDistance != nil ? [station.stHorizontalDistance stringValue] : @"";
        NSAttributedString* horizontalPlaceholder = [[NSAttributedString alloc] initWithString:(station.calcHorizontalDistance != nil ? [station.calcHorizontalDistance stringValue] : @"") attributes:@{NSForegroundColorAttributeName: [Utils darkishGrey]}];
        horizontalDistance.attributedPlaceholder = horizontalPlaceholder;
        
        slopePercentage.text = station.stSlopePercentage != nil ? [station.stSlopePercentage stringValue] : @"";
        groundLayer1.text = station.stGround1;
        groundLayer2.text = station.stGround2;
        groundLayer3.text = station.stGround3;
        groundLayer1depth.text = station.stDepth1 != nil ? [station.stDepth1 stringValue] : @"";
        groundLayer2depth.text = station.stDepth2 != nil ? [station.stDepth2 stringValue] : @"";
        groundLayer3depth.text = station.stDepth3 != nil ? [station.stDepth3 stringValue] : @"";
        diameter.text = station.stPipeDiameter != nil ? [station.stPipeDiameter stringValue] : @"";
        width.text = station.stBoxWidth != nil ? [station.stBoxWidth stringValue] : @"";
        height.text = station.stBoxHeight != nil ? [station.stBoxHeight stringValue] : @"";
        label.text = station.stLabel;
        
        // If both distance placeholder values are empty then recalculate just to be safe.
        self.shouldRecalculateFields = slopeDistance.placeholder.length == 0 && horizontalDistance.placeholder.length == 0;
        [self recalculateFieldData];
    } else {
        NSLog(@"StationShotEntryViewController: Failed to load station data.");
    }
}

- (void)saveData {
    // Enforce the default values.
    [self enforceDefaultValues];
    // Save the data.
    Station *station = [[DataController sharedInstance] currentStation];
    if (station) {
        station.stType = [typeBtn titleForState:UIControlStateNormal];
        station.stForeAzimuth = foreAzimuth.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:foreAzimuth.text] : nil;
        station.stSlopePercentage = slopePercentage.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:slopePercentage.text] : nil;
        station.stGround1 = groundLayer1.text;
        station.stGround2 = groundLayer2.text;
        station.stGround3 = groundLayer3.text;
        station.stDepth1 = groundLayer1depth.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:groundLayer1depth.text] : nil;
        station.stDepth2 = groundLayer2depth.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:groundLayer2depth.text] : nil;
        station.stDepth3 = groundLayer3depth.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:groundLayer3depth.text] : nil;
        station.stPipeDiameter = diameter.text.length > 0 ? [NSNumber numberWithInteger:[diameter.text integerValue]] : nil;
        station.stBoxHeight = height.text.length > 0 ? [NSNumber numberWithInteger:[height.text integerValue]] : nil;
        station.stBoxWidth = width.text.length > 0 ? [NSNumber numberWithInteger:[width.text integerValue]] : nil;
        station.stLabel = label.text;
        
        // Recalculate at this point just to be safe.
        [self recalculateFieldData];
        station.stSlopeDistance = slopeDistance.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:slopeDistance.text] : nil;
        station.calcSlopeDistance = slopeDistance.placeholder.length > 0 ? [NSDecimalNumber decimalNumberWithString:slopeDistance.placeholder] : nil;
        station.stHorizontalDistance = horizontalDistance.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:horizontalDistance.text] : nil;
        station.calcHorizontalDistance = horizontalDistance.placeholder.length > 0 ? [NSDecimalNumber decimalNumberWithString:horizontalDistance.placeholder] : nil;
        
        [station commit];
        
        // Update station defaults. Have them store the last valid entries.
        StationDefaults *defaults = station.relDefaults;
        defaults.stSlopeDistance = station.stSlopeDistance;
        defaults.stHorizontalDistance = station.stHorizontalDistance;
        defaults.stSlopePercentage = station.stSlopePercentage;
        defaults.stType = station.stType;
        defaults.stForeAzimuth = station.stForeAzimuth;
        
        [defaults commit];
    } else {
        NSLog(@"StationShotEntryViewController: Failed to save station data.");
    }
}

- (void)recalculateFieldData {
    // Only recalculate it if needed.
    if (self.shouldRecalculateFields == YES) {
        self.shouldRecalculateFields = NO;
        // Clear both fields of placeholder values if they contain no data.
        if ((slopeDistance.text.length == 0 && horizontalDistance.text.length == 0) || slopePercentage.text.length == 0) {
            slopeDistance.placeholder = @"";
            horizontalDistance.placeholder = @"";
        }
        
        // If we've defined slope distance calculate the horizontal distance.
        else if (slopeDistance.text.length  > 0 && slopePercentage.text.length > 0) {
            double conversion = SDtoHD([slopeDistance.text doubleValue], [slopePercentage.text doubleValue]);
            // Create a NSDecimalNumber, round it, and then set the placeholder text.
            NSDecimalNumber *roundedDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:conversion] decimalValue]];
            roundedDecimalNumber = [roundedDecimalNumber decimalNumberByRoundingAccordingToBehavior:self.decimalRoundingBehaviour];
            // They want specific colours on the placeholder.
            NSAttributedString* placeholder = [[NSAttributedString alloc] initWithString:[roundedDecimalNumber stringValue] attributes:@{NSForegroundColorAttributeName: [Utils darkishGrey]}];
            horizontalDistance.attributedPlaceholder = placeholder;
            slopeDistance.placeholder = @"";
        }
        
        // If we've defined horizontal distance calculate the slope distance.
        else if (horizontalDistance.text.length  > 0 && slopePercentage.text.length > 0) {
            double conversion = HDtoSD([horizontalDistance.text doubleValue], [slopePercentage.text doubleValue]);
            // Create a NSDecimalNumber, round it, and then set the placeholder text.
            NSDecimalNumber *roundedDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:conversion] decimalValue]];
            roundedDecimalNumber = [roundedDecimalNumber decimalNumberByRoundingAccordingToBehavior:self.decimalRoundingBehaviour];
            // They want specific colours on the placeholder.
            NSAttributedString* placeholder = [[NSAttributedString alloc] initWithString:[roundedDecimalNumber stringValue] attributes:@{NSForegroundColorAttributeName: [Utils darkishGrey]}];
            slopeDistance.attributedPlaceholder = placeholder;
            horizontalDistance.placeholder = @"";
        }
    }
}

- (void)enforceDefaultValues {
    StationDefaults *defaults = [[DataController sharedInstance] currentStation].relDefaults;
    if (defaults != nil) {
        if ([typeBtn titleForState:UIControlStateNormal].length == 0) {
            [typeBtn setTitle:defaults.stType forState:UIControlStateNormal];
        }
        if (foreAzimuth.text.length == 0 && ![[typeBtn titleForState:UIControlStateNormal] isEqualToString:SHOT_TYPE_IFS]) {
            
            if (defaults.stForeAzimuth != nil) {
                foreAzimuth.text = [defaults.stForeAzimuth stringValue];
            } else {
                if ([defaults.stType isEqualToString:SHOT_TYPE_IFS]) {
                    // Note: If they make a new station with an initial shot type of IFS, and then change it to one of the other types then the default will not work as expected. This is why we have 0 where it would otherwise be an empty string.
                    foreAzimuth.text = @"0";
                    [[DataController sharedInstance] setDataErrorMessage:NSLocalizedString(@"data_controller_err_no_fore_azimuth_on_non_ifs", nil)];
                } else {
                    foreAzimuth.text = @"";
                }
            }
        }
        if (slopeDistance.text.length == 0 && horizontalDistance.text.length == 0) {
            // Only one of these can be selected, so we only do something if both of them are empty.
            slopeDistance.text = defaults.stSlopeDistance != nil ? [defaults.stSlopeDistance stringValue] : @"";
            horizontalDistance.text = defaults.stHorizontalDistance != nil ? [defaults.stHorizontalDistance stringValue] : @"";
            self.shouldRecalculateFields = YES;
        }
        if (slopePercentage.text.length == 0) {
            slopePercentage.text = defaults.stSlopePercentage != nil ? [defaults.stSlopePercentage stringValue] : @"";
            self.shouldRecalculateFields = YES;
        }
    }
}

# pragma mark - Button state management functions.

- (IBAction)pressedRadioButton:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    // Since they're radio buttons make it so only one is selected at time.
    if (sender == slopeDistanceBtn) {
        horizontalDistanceBtn.selected = NO;
    } else if (sender == horizontalDistanceBtn) {
        slopeDistanceBtn.selected = NO;
    }
    
    else if (sender == pipeBtn) {
        boxBtn.selected = NO;
    } else if (sender == boxBtn) {
        pipeBtn.selected = NO;
    }
}

- (void)updateRadioButtons {
    // Update the slope field states.
    slopeDistanceBtn.selected = slopeDistance.text.length > 0;
    horizontalDistanceBtn.selected = horizontalDistance.text.length > 0;
    slopeDistance.enabled = horizontalDistance.text.length == 0;
    horizontalDistance.enabled = slopeDistance.text.length == 0;
    slopeDistanceBtn.enabled = slopeDistance.enabled;
    horizontalDistanceBtn.enabled = horizontalDistance.enabled;
    
    // Update the culvert field states.
    pipeBtn.selected = diameter.text.length > 0;
    boxBtn.selected = width.text.length > 0 || height.text.length > 0;
    
    diameter.enabled = width.text.length == 0 && height.text.length == 0;
    width.enabled = diameter.text.length == 0;
    height.enabled = width.enabled;
    pipeBtn.enabled = diameter.enabled;
    boxBtn.enabled = height.enabled;
}

- (void)updateFieldStates {
    // If they selected ifs then disable the fore azimuth value.
    if ([[typeBtn titleForState:UIControlStateNormal] isEqualToString:SHOT_TYPE_IFS]) {
        foreAzimuth.text = @"";
        foreAzimuth.enabled = NO;
    } else {
        foreAzimuth.enabled = YES;
    }
}

- (void)updateTabStates {
    Station *station = [[DataController sharedInstance] currentStation];
    if ([[DataController sharedInstance] allowAccessToCoordinatesAndSideShotsForStation:station]) {
        [super enableTab:TI_COORDINATES];
        [super enableTab:TI_SIDE_SHOTS];
        // For this one we need to disable some things on the page.
        groundLayer1.enabled = YES;
        groundLayer2.enabled = YES;
        groundLayer3.enabled = YES;
        groundLayer1depth.enabled = YES;
        groundLayer2depth.enabled = YES;
        groundLayer1.textColor = [Utils darkGreen];
        groundLayer2.textColor = [Utils darkGreen];
        groundLayer3.textColor = [Utils darkGreen];
        groundLayer1depth.textColor = [Utils darkGreen];
        groundLayer2depth.textColor = [Utils darkGreen];
    } else {
        [super disableTab:TI_COORDINATES];
        [super disableTab:TI_SIDE_SHOTS];
        groundLayer1.enabled = NO;
        groundLayer2.enabled = NO;
        groundLayer3.enabled = NO;
        groundLayer1depth.enabled = NO;
        groundLayer2depth.enabled = NO;
        groundLayer1.textColor = [UIColor clearColor];
        groundLayer2.textColor = [UIColor clearColor];
        groundLayer3.textColor = [UIColor clearColor];
        groundLayer1depth.textColor = [UIColor clearColor];
        groundLayer2depth.textColor = [UIColor clearColor];
    }
}

- (void)updatePreviousNextButtons {
    if ([[DataController sharedInstance] currentTraverse].relStation.count <= 1) {
        nextBtn.hidden = YES;
        previousBtn.hidden = YES;
    } else {
        nextBtn.hidden = [[DataController sharedInstance] isLastStation];
        previousBtn.hidden = [[DataController sharedInstance] isFirstStation];
    }
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
    [self updateRadioButtons];
    [self recalculateFieldData];
    
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
    [slopeDistanceBtn resignFirstResponder];
    [horizontalDistanceBtn resignFirstResponder];
    [pipeBtn resignFirstResponder];
    [boxBtn resignFirstResponder];
    [foreAzimuth resignFirstResponder];
    [slopeDistance resignFirstResponder];
    [horizontalDistance resignFirstResponder];
    [slopePercentage resignFirstResponder];
    [groundLayer1 resignFirstResponder];
    [groundLayer2 resignFirstResponder];
    [groundLayer3 resignFirstResponder];
    [groundLayer1depth resignFirstResponder];
    [groundLayer2depth resignFirstResponder];
    [groundLayer3depth resignFirstResponder];
    [diameter resignFirstResponder];
    [width resignFirstResponder];
    [height resignFirstResponder];
    [label resignFirstResponder];
}

# pragma mark - App state change logic.

- (void)appWillResignActive:(NSNotification *)notification {
    [self saveData];
}

- (void)appWillTerminate:(NSNotification *)notification {
    // Save data.
    [self saveData];
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

# pragma mark - Keyboard navigation.

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ((textField == slopeDistance && horizontalDistance.text.length > 0) ||
        (textField == horizontalDistance && slopeDistance.text.length > 0) ||
        (textField == diameter && (width.text.length > 0 || height.text.length > 0)) ||
        ((textField == width || textField == height) && diameter.text.length > 0)
        ) {
        return NO;
    }
    
    // Check if we need to shift the keyboard up.
    UITextInputAssistantItem* item = [textField inputAssistantItem];
    item.trailingBarButtonGroups = @[self.group];
    self.currentSelectedElementTag = textField.tag;
    [self updateRadioButtons];
    return YES;
}

- (void)goToPrevious {
    [self goToPreviousFrom:self.currentSelectedElementTag];
}

// Modified stackoverflow answer from here http://stackoverflow.com/a/1351090
// This solution relies on us propertly tagging the ui elements.
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self updateRadioButtons];
    [self recalculateFieldData];
    [self goToNextFrom:self.currentSelectedElementTag];
    
    // Return no to avoid inserting linebreaks.
    return NO;
}

# pragma mark - Keyboard field entry.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limited decimal places.
    if (textField == groundLayer1depth || textField == groundLayer2depth || textField == groundLayer3depth ||
        textField == foreAzimuth || textField == horizontalDistance || textField == slopeDistance || textField == slopePercentage) {
        
        NSArray  *strings = [textField.text componentsSeparatedByString:@"."];
        // Check if they're trying to more than one period.
        if (strings.count > 1 && [string isEqualToString:@"."]) {
            return NO;
        }
        // Check if they're adding a - to anywhere except the start, and if they've already added a - sign.
        else if ([string isEqualToString:@"-"] && (range.location != 0 || [textField.text containsString:@"-"])) {
            return NO;
        }
        else if (![string isEqualToString:@""]) {
            if (![Utils string:string passesRegex:REGEX_INPUT_NUMBERS_AND_DECIMAL] || // Check the character we're adding
                (strings.count == 2 && [strings[1] length] > 0)) {               // Check the length of the decimal component.
                return NO;
            }
        }
        
        if (textField == horizontalDistance || textField == slopeDistance || textField == slopePercentage) {
            // Need to set it to recalculate if we get to this point as something has changed.
            self.shouldRecalculateFields = YES;
            [[DataController sharedInstance] setShouldRecalculateStationValues:YES];
        } else if (textField == foreAzimuth) {
            [[DataController sharedInstance] setShouldRecalculateForeAzimuthValues:YES];
        }
    }
    
    // No decimal places.
    else if (textField == width || textField == height || textField == diameter) {
        // Check that we're only adding decimals.
        if (![string isEqualToString:@""] && ![Utils string:string passesRegex:REGEX_INPUT_ONLY_NUMBERS]) {
            return NO;
        }
    }
    
    // Only alphabetic characters.
    else if (textField == groundLayer1 || textField == groundLayer2 || textField == groundLayer3) {
        // Check that we're only adding alphabetic characters and if we're below 2 characters.
        if (![string isEqualToString:@""] && (textField.text.length > 1 || ![Utils string:string passesRegex:REGEX_INPUT_ONLY_ALPHABETIC_CHARACTERS])) {
            return NO;
        }
    }
    
    [self updateRadioButtons];
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField {
    if (textField == horizontalDistance || textField == slopeDistance || textField == slopePercentage) {
        // Need to set it to recalculate if we get to this point as something has changed.
        self.shouldRecalculateFields = YES;
        [[DataController sharedInstance] setShouldRecalculateStationValues:YES];
    } else if (textField == foreAzimuth) {
        [[DataController sharedInstance] setShouldRecalculateForeAzimuthValues:YES];
    }
    return YES;
}

# pragma mark - NavigatableButtonDelegate functions.

- (void)goToNextFrom:(NSInteger)elementTag {
    // Find the next element.
    UIResponder* next;
    UITextField* nextField;
    long tag = elementTag;
    for (int i = 1; i < 12; i++) {
        next = [self.view viewWithTag:elementTag + i];
        // If the element is a textfield make sure its enabled.
        if ([next isKindOfClass:[UITextField class]]) {
            nextField = (UITextField*)next;
            if (nextField && nextField.enabled) {
                tag = elementTag + i;
                break;
            } else {
                nextField = nil;
            }
        }
    }
    
    if (nextField) {
        // Make the next element the responder.
        self.currentSelectedElementTag = tag;
        [nextField becomeFirstResponder];
    } else {
        UITextField* currentField = (UITextField*)[self.view viewWithTag:self.currentSelectedElementTag];
        [currentField resignFirstResponder];
    }
}

- (void)goToPreviousFrom:(NSInteger)elementTag {
    [self updateRadioButtons];
    [self recalculateFieldData];
    
    // Find the next element.
    UIResponder* next;
    UITextField* nextField;
    long tag = elementTag;
    for (int i = 1; i < 12; i++) {
        next = [self.view viewWithTag:elementTag - i];
        // If the element is a textfield make sure its enabled.
        if ([next isKindOfClass:[UITextField class]]) {
            nextField = (UITextField*)next;
            if (nextField && nextField.enabled) {
                tag = elementTag - i;
                break;
            } else {
                nextField = nil;
            }
        }
    }
    
    if (nextField) {
        // Make the next element the responder.
        self.currentSelectedElementTag = tag;
        [nextField becomeFirstResponder];
    } else {
        self.currentSelectedElementTag = elementTag;
    }
}

# pragma mark - ShotTypeSelectionDelegate functions.

- (void)selectedType:(NSString *)type {
    [typeBtn setTitle:type forState:UIControlStateNormal];
    [self updateFieldStates];
    // Set the index flag to recalculate them.
    [[DataController sharedInstance] setShouldRecalculateIndexValues:YES];
    [[DataController sharedInstance] setShouldRecalculateStationValues:YES];
    [[DataController sharedInstance] setShouldRecalculateForeAzimuthValues:YES];
}

# pragma mark - Segue functions.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shot_type_selection"]) {
        [self dismissFirstResponder];
        // Set the delegate and pass in the current value.
        ((ShotTypeSelectionViewController*) segue.destinationViewController).delegate = self;
        ((ShotTypeSelectionViewController*) segue.destinationViewController).currentSelectedValue = [typeBtn titleForState:UIControlStateNormal];
    }
}

@end
