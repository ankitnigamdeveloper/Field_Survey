//
//  CoordinateEntryViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "CoordinateEntryViewController.h"
#import "Station.h"
#import "ActiveRecord.h"
#import "DataController.h"
#import "AppConstants.h"
#import "Utils.h"

@interface CoordinateEntryViewController ()
@property (nonatomic, strong) UIBarButtonItemGroup* group;
@property (nonatomic) StationDefaultValuesViewController* stationDefaultsViewController;
@end

@implementation CoordinateEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup field navigation.
    xyAbsBtn.delegate = self;
    zAbsBtn.delegate = self;
    
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goToPrevious)];
    self.group = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[itemBack] representativeItem:nil];
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
    
    // Load data, update strings.
    [self.parentViewController.navigationItem setTitle:@"C/L Coordinates"];
    [self loadData];
    [self updateCheckboxes];
    currentStationInfo.text = [NSString stringWithFormat:NSLocalizedString(@"general_station_info_heading", nil), [[DataController sharedInstance] currentStation].calcStation];
    [self updateTabStates];
    [self updatePreviousNextButtons];
    [super updateInsertText];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
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

- (void)updateCheckboxes {
    xyAbsBtn.selected = (![northing.text isEqualToString:@""] || ![easting.text isEqualToString:@""]);
    zAbsBtn.selected = ![elevation.text isEqualToString:@""];
}

- (void)goToNextStation {
    // Run updates.
    [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:[[DataController sharedInstance] currentStation]];
    // Go to the next one.
    [[DataController sharedInstance] nextStation];
//    // Reload the screens data.
//    [self loadData];
//    [self updateCheckboxes];
//    currentStationInfo.text = [NSString stringWithFormat:NSLocalizedString(@"general_station_info_heading", nil), [[DataController sharedInstance] currentTraverse].trName, [[DataController sharedInstance] currentStation].calcStationIndex, [[DataController sharedInstance] currentStation].calcStation];
//    [self updateTabStates];
//    [self updatePreviousNextButtons];
    // Now switch to the station & shot tab.
    [self.tabBarController setSelectedIndex:TI_STATION_SHOT];
}

- (void)goToPreviousStation {
    // Run updates.
    [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:[[DataController sharedInstance] currentStation]];
    // Go to the previous station.
    [[DataController sharedInstance] previousStation];
//    // Reload the screens data.
//    [self loadData];
//    [self updateCheckboxes];
//    currentStationInfo.text = [NSString stringWithFormat:NSLocalizedString(@"general_station_info_heading", nil), [[DataController sharedInstance] currentTraverse].trName, [[DataController sharedInstance] currentStation].calcStationIndex, [[DataController sharedInstance] currentStation].calcStation];
//    [self updateTabStates];
//    [self updatePreviousNextButtons];
    // Now switch to the station & shot tab.
    [self.tabBarController setSelectedIndex:TI_STATION_SHOT];
}

# pragma mark - Button functions.

- (IBAction)pressedButton:(UIButton*)sender {
    sender.selected = !sender.selected;
}

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
        easting.text = station.coEasting != nil ? [station.coEasting stringValue] : @"";
        northing.text = station.coNorthing != nil ? [station.coNorthing stringValue] : @"";
        elevation.text = station.coElevation != nil ? [station.coElevation stringValue] : @"";
    } else {
        NSLog(@"CoordinateEntryViewController: Failed to load station data.");
    }
}

- (void)saveData {
    // Enforce the default values.
    [self enforceDefaultValues];
    // Save the data.
    Station *station = [[DataController sharedInstance] currentStation];
    if (station) {
        station.coEasting = easting.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:easting.text] : nil;
        station.coNorthing = northing.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:northing.text] : nil;
        station.coElevation = elevation.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:elevation.text] : nil;
        
        [station commit];
    } else {
        NSLog(@"CoordinateEntryViewController: Failed to save station data.");
    }
}

// If the coordinate fields are empty and it is the first one then insert default values.
- (void)enforceDefaultValues {
    if ([[DataController sharedInstance] isFirstStation]) {
        if (easting.text.length == 0) {
            easting.text = @"0";
        }
        if (northing.text.length == 0) {
            northing.text = @"0";
        }
        if (elevation.text.length == 0) {
            elevation.text = @"100";
        }
    }
}

- (void)updateTabStates {
    Station *station = [[DataController sharedInstance] currentStation];
    if ([[DataController sharedInstance] allowAccessToCoordinatesAndSideShotsForStation:station]) {
        [super enableTab:TI_COORDINATES];
        [super enableTab:TI_SIDE_SHOTS];
    } else {
        // In this situation we need to go to a different tab. Station & Shot entry is the only tab that doesn't get disabled.
        [self.tabBarController setSelectedIndex:TI_STATION_SHOT];
        return;
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
    // Check if we need to adjust it.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = [self getFieldOffsetForKeyboard:keyboardSize] * -1;
        self.view.frame = f;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self updateCheckboxes];
    
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
    [easting resignFirstResponder];
    [northing resignFirstResponder];
    [xyAbsBtn resignFirstResponder];
    [elevation resignFirstResponder];
    [zAbsBtn resignFirstResponder];
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
    [self updateCheckboxes];
    UITextInputAssistantItem* item = [textField inputAssistantItem];
    item.trailingBarButtonGroups = @[self.group];
    self.currentSelectedElementTag = textField.tag;
    return YES;
}

- (void)goToPrevious {
    [self goToPreviousFrom:self.currentSelectedElementTag];
}

// Modified stackoverflow answer from here http://stackoverflow.com/a/1351090
// This solution relies on us propertly tagging the ui elements.
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self updateCheckboxes];
    [self goToNextFrom:textField.tag];
    
    // Return no to avoid inserting linebreaks.
    return NO;
}

# pragma mark - Keyboard field entry.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /// Limit all the fields on this page to numbers and one decimal.
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
        if (![Utils string:string passesRegex:REGEX_INPUT_NUMBERS_AND_DECIMAL]) { // Check the character we're adding
            return NO;
        }
    }
    
    return YES;
}

# pragma mark - NavigatableButtonDelegate functions.

- (void)goToNextFrom:(NSInteger)elementTag {
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



@end
