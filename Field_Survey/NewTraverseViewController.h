//
//  NewTraverseViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigatableButton.h"
#import "Traverse.h"

@interface NewTraverseViewController : UIViewController <UITextFieldDelegate, NavigatableButtonDelegate> {
    IBOutlet UITextField* name;
    IBOutlet UITextField* description;
    IBOutlet UITextField* crew;
    IBOutlet UITextField* dateCreated;
    IBOutlet UITextField* startIndex;
    IBOutlet UITextField* startStation;
    IBOutlet UIButton* createTraverseBtn;
    IBOutlet NavigatableButton* creationDateBtn;
    IBOutlet UIView* datePickerView;
    IBOutlet UIDatePicker* datePicker;
    NSDate *creationDate;
    NSDateFormatter *formatter;
}

@property (nonatomic) Traverse* selectedTraverse; // If this has a value we know we're editing an existing traverse.
@property (nonatomic) NSInteger currentSelectedElementTag;

@end

