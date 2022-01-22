//
//  NewTraverseViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "NewTraverseViewController.h"
#import "TraverseListViewController.h"
#import "AppConstants.h"
#import "Traverse.h"
#import "Station.h"
#import "ActiveRecord.h"
#import "DataController.h"
#import "Utils.h"

@interface NewTraverseViewController ()
@property (nonatomic, strong) UIBarButtonItemGroup* group;
@end

@implementation NewTraverseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup field navigation.
    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goToPrevious)];
    self.group = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[itemBack] representativeItem:nil];
    // Set the default date.
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:CREATION_DATE_FORMAT];
    creationDateBtn.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set keyboard selectors.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // Fill fields.
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    NSString *fieldCheck = [self checkFieldData];
    // If its empty then there was no error and we can save the data.
    if (fieldCheck.length == 0) {
        [self saveDataShouldCreateNew:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Save / Load data functions.

- (void)loadData {
    // Check if we already have a traverse to display.
    if (self.selectedTraverse) {
        // Different titles.
        [self.navigationItem setTitle:NSLocalizedString(@"new_trav_title_info", nil)];
        // Set the values.
        name.text = self.selectedTraverse.trName;
        description.text = self.selectedTraverse.trDescription;
        crew.text = self.selectedTraverse.trCrew;
        
        [creationDateBtn setTitle:[formatter stringFromDate:self.selectedTraverse.trCreated] forState:UIControlStateNormal];
        startIndex.text = self.selectedTraverse.trStartIndex;
        startStation.text = [self.selectedTraverse.trStation stringValue];
        creationDate = self.selectedTraverse.trCreated;
        createTraverseBtn.hidden = YES;
    }
    // New traverse.
    else {
        [self.navigationItem setTitle:NSLocalizedString(@"new_trav_title_new", nil)];
        // Set the default value to todays date.
        [creationDateBtn setTitle:[formatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
        creationDate = [NSDate date];
        [createTraverseBtn setTitle:NSLocalizedString(@"new_trav_create_traverse", nil) forState:UIControlStateNormal];
        createTraverseBtn.hidden = NO;
    }
}

- (void)saveDataShouldCreateNew:(BOOL)create {
    // Enforce the default values.
    [self enforceDefaultValues];
    BOOL newTraverse = NO;
    // Create the traverse if it doesn't already exist.
    if (self.selectedTraverse == nil) {
        // If we're not supposed to create a new traverse here then we kick out without saving.
        if (create == NO) {
            return;
        }
        self.selectedTraverse = [Traverse create];
        self.selectedTraverse.trLastModified = [NSDate date];
        // Since its a new traverse create the initial station for it as well.
        Station* station = [[DataController sharedInstance] createNewStation];
        [station commit];
        NSOrderedSet *set = [[NSOrderedSet alloc] initWithObject:station];
        self.selectedTraverse.relStation = set;
        [[DataController sharedInstance] setShouldEnforceDefaultCoordinateValuesOnFirstStation:YES];
        [[DataController sharedInstance] setInvalidStationIndex:0];
        newTraverse = YES;
    }
    // Update the update flags.
    BOOL recalculateIndexes = ![self.selectedTraverse.trStartIndex isEqualToString:startIndex.text] || newTraverse;
    [[DataController sharedInstance] setShouldRecalculateIndexValues:recalculateIndexes];
    BOOL recalculateStationValues = ![[self.selectedTraverse.trStation stringValue] isEqualToString:startStation.text] || newTraverse;
    [[DataController sharedInstance] setShouldRecalculateStationValues:recalculateStationValues];
    
    self.selectedTraverse.trCrew = crew.text;
    self.selectedTraverse.trName = name.text;
    self.selectedTraverse.trStartIndex = startIndex.text;
    self.selectedTraverse.trDescription = description.text;
    self.selectedTraverse.trCreated = creationDate;
    self.selectedTraverse.trStation = startStation.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:startStation.text] : nil;
    
    // Need to call commit with this core data stack to save the changes.
    [self.selectedTraverse commit];
    
    [[DataController sharedInstance] setCurrentTraverse:self.selectedTraverse];
    [[DataController sharedInstance] updateAllCalculatedFieldsAsNeeded];
}

- (void)enforceDefaultValues {
    if (startIndex.text.length == 0) {
        startIndex.text = @"1";
    }
    if (startStation.text.length == 0) {
        startStation.text = @"0";
    }
}

// Returns an empty string if there was no error. Doing it like this enforces better communication of what went wrong.
- (NSString*)checkFieldData {
    NSString *err_msg = @"";
    
    // The only check is whether or not they've entered something for the name.
    if (name.text.length == 0) {
        err_msg = NSLocalizedString(@"new_trav_err_name_required", nil);
    }
    
    return err_msg;
}

- (IBAction)pressedCreate:(id)sender {
    NSString *fieldCheck = [self checkFieldData];
    // If its empty then there was no error.
    if (fieldCheck.length == 0) {
        [self saveDataShouldCreateNew:YES];
        // Navigate to the first station.
        if (self.selectedTraverse != nil && self.selectedTraverse.relStation != nil && self.selectedTraverse.relStation.firstObject != nil) {
            [[DataController sharedInstance] setCurrentTraverse:self.selectedTraverse];
            [[DataController sharedInstance] setCurrentStation:self.selectedTraverse.relStation.firstObject];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            /// Need to change the navigation stack order; it should be: Traverse List, Station Table, Tabbar Controller.
            // Attempt to get an existing instance of the TraverseListViewController; should always succeed.
            UIViewController *traverseList = [Utils vcOfClass:[TraverseListViewController class] existsInNavigationController:self.navigationController];
            if (traverseList == nil) {
                traverseList = (UIViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_traverse_list"];
            }
            // At this point there wouldn't be any existing station list or tabbar in the navigation stack.
            UIViewController *stationsList = (UIViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_stations_list"];
            UITabBarController *stationsTabbar = (UITabBarController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"tbc_station"];
            [stationsTabbar setSelectedIndex:TI_STATION_SHOT];
            [self.navigationController setViewControllers:@[traverseList, stationsList, stationsTabbar]];
        }
    } else {
        // Something went wrong, show the message.
        [Utils displayAlertWithMessage:fieldCheck onView:self onOk:nil];
    }
}

# pragma mark - UIDatePicker functions.

- (IBAction)showDatePickerView:(id)sender {
    [self dismissFirstResponder];
    datePicker.date = creationDate;
    // I'm not sure why, but for some reason the create traverse button is still showing through the date picker, even when the background is set to solid white.
    createTraverseBtn.hidden = YES;
    datePickerView.hidden = NO;
}

- (IBAction)selectedDate:(id)sender {
    if (datePicker.date) {
        [creationDateBtn setTitle:[formatter stringFromDate:datePicker.date] forState:UIControlStateNormal];
        creationDate = datePicker.date;
    } else {
        [creationDateBtn setTitle:[formatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
        creationDate = [NSDate date];
    }
    datePickerView.hidden = YES;
    if (self.selectedTraverse == nil) {
        createTraverseBtn.hidden = NO;
    }
}

- (IBAction)hideDatePickerView:(id)sender {
    datePickerView.hidden = YES;
    if (self.selectedTraverse == nil) {
        createTraverseBtn.hidden = NO;
    }
}

# pragma mark - Field entry logic.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limit the characters for the startIndex field.
    if (textField == startIndex) {
        // Only numbers are valid for this field.
        if (![string isEqualToString:@""] && ![Utils string:string passesRegex:REGEX_INPUT_ONLY_NUMBERS]) {
            return NO;
        }
    }
    // Limit characters on station.
    else if (textField == startStation) {
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
    }
    
    return YES;
}

#pragma mark - Keyboard view shifting functions.

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
        return 0.0 - [self weirdOffsetBugFix];
    } else {
        return keyboardSize.height - distanceToBottom - [self weirdOffsetBugFix];
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
        f.origin.y = 0.0f + [self weirdOffsetBugFix];
        self.view.frame = f;
    }];
}

- (IBAction)handleTapOffTextField {
    if (datePickerView.hidden == YES) {
        [self dismissFirstResponder];
    }
}

- (void)dismissFirstResponder {
    [name resignFirstResponder];
    [description resignFirstResponder];
    [crew resignFirstResponder];
    [dateCreated resignFirstResponder];
    [startIndex resignFirstResponder];
    [startStation resignFirstResponder];
}

// Right, this is bloody weird: For some reason, the navigation bar height and status bar height are not being accounted for. On all the other view controllers this is implemented on, none of them have this issue, which makes me think the problem is in the storyboard somewhere. I've checked all the tags, and constraints but have not found the cause. This function is a work around for the problem. It is reproducible on ios 9.3.1 on devices and simulators.
- (float)weirdOffsetBugFix {
    return [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
}

# pragma mark - Keyboard navigation functions.

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // Check if we need to shift the keyboard up.
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
    [self goToNextFrom:textField.tag];
    
    // Return no to avoid inserting linebreaks.
    return NO;
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
