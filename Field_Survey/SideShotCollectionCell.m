//
//  SideShotCollectionCell.m
//  Field_Survey
//
//  Created by Martin on 2016/04/25.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "SideShotCollectionCell.h"
#import "Utils.h"
#import "AppConstants.h"
#import "NavigatableButton.h"
#import "ActiveRecord.h"

@interface SideShotCollectionCell ()
@property (nonatomic, strong) UIBarButtonItemGroup* group;
@property (atomic, weak) SideShot* sideShot;
@end

@implementation SideShotCollectionCell

# pragma mark - initialization.

- (void)awakeFromNib {
    [super awakeFromNib];
//    turningPoint.delegate = self;

    UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goToPreviousFromSelector:)];
    self.group = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[itemBack] representativeItem:nil];
}

- (void)configureWithData:(NSDictionary*)data forSideShot:(SideShot*)sideshot {
    // Keep a refernce so we can update the side shots values.
    self.sideShot = sideshot;
    // Update the cell appearance.
    title.text = [data objectForKey:CELL_KEY_TITLE];
    turningPoint.enabled = [[data valueForKey:CELL_KEY_SHOW_TURNING_POINT] boolValue];
    turningPoint.hidden = !turningPoint.enabled;
    // Update the displayed data for the side shot it represents.
    [self loadData];
}

- (void)stopListeningForEvents {
    [self dismissFirstResponder];
}

# pragma mark - Save / Load data functions.

- (BOOL)isBeingReused {
    return self.sideShot != nil;
}

- (void)loadData {
    if (self.sideShot) {
        slpPercentage.text = self.sideShot.shSlopePercentage != nil ? [self.sideShot.shSlopePercentage stringValue] : @"";
        slpDistance.text = self.sideShot.shSlopeDistance != nil ? [self.sideShot.shSlopeDistance stringValue] : @"";
        sideShotCode.text = self.sideShot.shShotCode;
        turningPoint.selected = [self.sideShot.shTurningPoint boolValue];
    } else {
        slpPercentage.text = @"";
        slpDistance.text = @"";
        sideShotCode.text = @"";
        turningPoint.selected = NO;
    }
}

- (void)saveDataAndUpdateSource:(BOOL)update {
    if (self.sideShot) {
        self.sideShot.shSlopePercentage = slpPercentage.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:slpPercentage.text] : nil;
        self.sideShot.shSlopeDistance = slpDistance.text.length > 0 ? [NSDecimalNumber decimalNumberWithString:slpDistance.text] : nil;
        self.sideShot.shShotCode = sideShotCode.text;
        self.sideShot.shTurningPoint = [NSNumber numberWithBool:turningPoint.selected];
        // Save changes.
        [self.sideShot commit];
        
        // Update the delegate datasource if needed.
        if (update) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
            [dict setObject:self.sideShot forKey:CELL_KEY_SIDE_SHOT];
            [dict setObject:self.currentCollectionView forKey:CELL_KEY_CURRENT_COLLECTION];
            [dict setValue:[NSNumber numberWithInteger:self.currentCellIndex] forKey:CELL_KEY_INDEX];
            [self.delegate shouldUpdateSideShotDataWith:dict];
        }
    }
}

- (void)clearSideShot {
    self.sideShot = nil;
}

# pragma mark - button presses.

- (IBAction)pressedTurningPoint:(UIButton*)button {
    button.selected = !button.selected;
}

# pragma mark - Keyboard navigation.

- (void)cellGainedFocusWithTag:(NSInteger)tag {
    // Find the first element.
    UIResponder* element = [self.contentView viewWithTag:tag];
    if (element) {
        // Make the element the responder.
        self.currentSelectedElementTag = tag;
        [element becomeFirstResponder];
    }
}

- (void)goToPreviousFromSelector:(id)responder {
    [self goToPreviousFrom:self.currentSelectedElementTag];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITextInputAssistantItem* item = [textField inputAssistantItem];
    item.trailingBarButtonGroups = @[self.group];
    self.currentSelectedElementTag = textField.tag;
    return YES;
}

// Modified stackoverflow answer from here http://stackoverflow.com/a/1351090
// This solution relies on us propertly tagging the ui elements.
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    // Find the next element.
    UIResponder* next = [self.contentView viewWithTag:textField.tag + 1];
    
    if (next && textField.tag+1 != 3) {
        // Make the next element the responder.
        self.currentSelectedElementTag = textField.tag+1;
        [next becomeFirstResponder];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    } else {
        // Dismiss the keyboard.
        [self goToNextCell];
    }
    
    // Return no to avoid inserting linebreaks.
    return NO;
}

# pragma mark - Keyboard field entry.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Limited decimal places.
    if (textField == slpDistance || textField == slpPercentage) {
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
    }
    
    // Only alphabetic characters.
    if (textField == sideShotCode) {
        // Check that we're only adding alphabetic characters and if we're below 4 characters.
        if (![string isEqualToString:@""] && (textField.text.length > 3 || ![Utils string:string passesRegex:REGEX_INPUT_ONLY_ALPHABETIC_CHARACTERS])) {
            return NO;
        }
    }
    
    return YES;
}

# pragma mark - NavigatableButtonDelegate functions.

- (void)goToNextFrom:(NSInteger)elementTag {
    // In our case, we just go to the next cell.
    [self goToNextCell];
}

- (void)goToPreviousFrom:(NSInteger)elementTag {
    // If we're on the first element switch cells.
    if (elementTag <= 1) {
        [self goToPreviousCell];
    }
    // Find the next element.
    else {
        UIResponder* next = [self.contentView viewWithTag:elementTag - 1];
        
        if (next) {
            // Make the next element the responder.
            self.currentSelectedElementTag = elementTag - 1;
            [next becomeFirstResponder];
        } else {
            self.currentSelectedElementTag = elementTag;
        }
    }
}

# pragma mark - SideShotCollectionCellDelegate functions.

- (void)goToNextCell {
    [self.delegate goToNextCell:self];
}

- (void)goToPreviousCell {
    [self.delegate goToPreviousCell:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self.delegate keyboardWillShow:notification onCollectionView:self.currentCollectionView];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self saveDataAndUpdateSource:YES];
    [self.delegate keyboardWillHideOnCollectionView:self.currentCollectionView];
}

- (void)dismissFirstResponder {
    [slpDistance resignFirstResponder];
    [slpPercentage resignFirstResponder];
    [sideShotCode resignFirstResponder];
    [turningPoint resignFirstResponder];
}

@end
