//
//  StationDefaultValuesViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/06/23.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "StationDefaultValuesViewController.h"
#import "AppConstants.h"
#import "Utils.h"

@interface StationDefaultValuesViewController ()
@property (nonatomic, strong) UIBarButtonItemGroup* group;
@property (nonatomic) NSInteger currentSelectedElementTag;
@property (nonatomic) BOOL shouldRecalculateFields; // Used locally for tracking whether or not we've updated the distance calculations after we changed them.
@property (nonatomic, strong) NSDecimalNumberHandler *decimalRoundingBehaviour;
@end

@implementation StationDefaultValuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup field navigation.
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goToPrevious)];
    self.group = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[itemBack] representativeItem:nil];
    
    // Documentation on this: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSDecimalNumberHandler_Class/index.html
    self.decimalRoundingBehaviour = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                           scale:1
                                                                                raiseOnExactness:NO
                                                                                 raiseOnOverflow:NO
                                                                                raiseOnUnderflow:NO
                                                                             raiseOnDivideByZero:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set selectors.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // Reset the fields.
    [typeBtn setTitle:@"" forState:UIControlStateNormal];
    foreAzimuth.text = @"";
    slopeDistance.text = @"";
    slopeDistance.placeholder = @"";
    horizontalDistance.text = @"";
    horizontalDistance.placeholder = @"";
    slopePercentage.text = @"";
    [self updateFieldStates];
    [self updateRadioButtons];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
            horizontalDistance.placeholder = [roundedDecimalNumber stringValue];
            slopeDistance.placeholder = @"";
        }
        
        // If we've defined horizontal distance calculate the slope distance.
        else if (horizontalDistance.text.length  > 0 && slopePercentage.text.length > 0) {
            double conversion = HDtoSD([horizontalDistance.text doubleValue], [slopePercentage.text doubleValue]);
            // Create a NSDecimalNumber, round it, and then set the placeholder text.
            NSDecimalNumber *roundedDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:conversion] decimalValue]];
            roundedDecimalNumber = [roundedDecimalNumber decimalNumberByRoundingAccordingToBehavior:self.decimalRoundingBehaviour];
            slopeDistance.placeholder = [roundedDecimalNumber stringValue];
            horizontalDistance.placeholder = @"";
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

- (void)updateRadioButtons {
    // Update the slope field states.
    slopeDistanceBtn.selected = slopeDistance.text.length > 0;
    horizontalDistanceBtn.selected = horizontalDistance.text.length > 0;
    slopeDistance.enabled = horizontalDistance.text.length == 0;
    horizontalDistance.enabled = slopeDistance.text.length == 0;
    slopeDistanceBtn.enabled = slopeDistance.enabled;
    horizontalDistanceBtn.enabled = horizontalDistance.enabled;
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

- (void)dismissFirstResponder {
    [foreAzimuth resignFirstResponder];
    [slopeDistance resignFirstResponder];
    [horizontalDistance resignFirstResponder];
    [slopePercentage resignFirstResponder];
}

# pragma mark - Keyboard navigation.

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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
    
    // Find the next field.
    UITextField* nextField;
    for (int i = 1; i < 4; i++) {
        nextField = [textField.superview viewWithTag:textField.tag + i];
        if (nextField && nextField.enabled) {
            break;
        }
    }
    
    if (nextField) {
        // Make the next field the responder.
        self.currentSelectedElementTag = nextField.tag;
        [nextField becomeFirstResponder];
    } else {
        // Dismiss the keyboard.
        self.currentSelectedElementTag = textField.tag;
        [textField resignFirstResponder];
    }
    
    // Return no to avoid inserting linebreaks.
    return NO;
}

# pragma mark - Keyboard field entry.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limited decimal places.
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
        self.shouldRecalculateFields = YES;
    }
    
    [self updateRadioButtons];
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField {
    if (textField == horizontalDistance || textField == slopeDistance || textField == slopePercentage) {
        // Need to set it to recalculate if we get to this point as something has changed.
        self.shouldRecalculateFields = YES;
    }
    return YES;
}

# pragma mark - NavigatableButtonDelegate functions.

- (void)goToNextFrom:(NSInteger)elementTag {
    // In our case, we just go to the next cell.
}

- (void)goToPreviousFrom:(NSInteger)elementTag {
    [self updateRadioButtons];
    [self recalculateFieldData];
    
    // Find the next element.
    UIResponder* next;
    UITextField* nextField;
    long tag = elementTag;
    for (int i = 1; i < 4; i++) {
        next = [self.view viewWithTag:elementTag - i];
        // If the element is a textfield make sure its enabled.
        if ([next isKindOfClass:[UITextField class]]) {
            nextField = (UITextField*)next;
            if (nextField && nextField.enabled) {
                tag = elementTag - i;
                break;
            }
        } else {
            tag = elementTag - i;
            break;
        }
    }
    
    if (next) {
        // Make the next element the responder.
        self.currentSelectedElementTag = tag;
        [next becomeFirstResponder];
    } else {
        self.currentSelectedElementTag = elementTag;
    }
}

// Returns an empty string if there was no error. Doing it like this enforces better communication of what went wrong.
- (NSString*)checkFieldData {
    NSString *err_msg = @"";
    
    // Check shot type.
    if ([typeBtn titleForState:UIControlStateNormal].length == 0) {
        err_msg = NSLocalizedString(@"station_defaults_err_shot", nil);
    }
    // Check fore azimuth.
    else if (foreAzimuth.text.length == 0 && ![[typeBtn titleForState:UIControlStateNormal] isEqualToString:SHOT_TYPE_IFS]) {
        err_msg = NSLocalizedString(@"station_defaults_err_fore_azim", nil);
    }
    // Check slope distance and horizontal distance.
    else if (slopeDistance.text.length == 0 && horizontalDistance.text.length == 0) {
        err_msg = NSLocalizedString(@"station_defaults_err_distance", nil);
    }
    // Check slope percentage.
    else if (slopePercentage.text.length == 0) {
        err_msg = NSLocalizedString(@"station_defaults_err_slp_per", nil);
    }
    
    return err_msg;
}

# pragma mark - ShotTypeSelectionDelegate functions.

- (void)selectedType:(NSString *)type {
    [typeBtn setTitle:type forState:UIControlStateNormal];
    [self updateFieldStates];
}

# pragma mark - Segue functions.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"defaults_shot_type_selection"]) {
        [self dismissFirstResponder];
        // Set the delegate and pass in the current value.
        ((ShotTypeSelectionViewController*) segue.destinationViewController).delegate = self;
        ((ShotTypeSelectionViewController*) segue.destinationViewController).currentSelectedValue = [typeBtn titleForState:UIControlStateNormal];
    }
}

# pragma mark - Button presses.

- (IBAction)pressedCancel:(id)sender {
    [self.delegate pressedDefaultsCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressedCreate:(id)sender {
    // Check if they've filled the fields.
    NSString* fieldCheck = [self checkFieldData];
    if (fieldCheck.length == 0) {
        // Create the data and return it.
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[typeBtn titleForState:UIControlStateNormal] forKey:DEFAULTS_KEY_TYPE];
        [dict setValue:(foreAzimuth.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:foreAzimuth.text] : nil) forKey:DEFAULTS_KEY_FOREAZIM];
        [dict setValue:(slopeDistance.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:slopeDistance.text] : nil) forKey:DEFAULTS_KEY_SLOPE_DISTANCE];
        [dict setValue:(slopeDistance.placeholder.length > 0 ? [NSDecimalNumber decimalNumberWithString:slopeDistance.placeholder] : nil) forKey:KEY_CALCULATED_SLOPE_DISTANCE];
        [dict setValue:(horizontalDistance.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:horizontalDistance.text] : nil) forKey:DEFAULTS_KEY_HORIZONTAL_DISTANCE];
        [dict setValue:(horizontalDistance.placeholder.length > 0 ? [NSDecimalNumber decimalNumberWithString:horizontalDistance.placeholder] : nil) forKey:KEY_CALCULATED_HORIZONTAL_DISTANCE];
        [dict setValue:(slopePercentage.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:slopePercentage.text] : nil) forKey:DEFAULTS_KEY_SLOPE_PERCENTAGE];
        
        [self dismissViewControllerAnimated:!self.navigateAfter completion:^void(void){
            [self.delegate createTraverseWithDefaultValues:dict atIndex:self.index andDisplayNewStation:self.navigateAfter];
        }];
    } else {
        // Something went wrong, show the message.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:fieldCheck preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_ok", nil) style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                   }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:!self.navigateAfter completion:nil];
    }
}

@end
