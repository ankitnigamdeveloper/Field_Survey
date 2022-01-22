//
//  CoordinateEntryViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigatableButton.h"
#import "TabbarViewController.h"
#import "StationDefaultValuesViewController.h"

@interface CoordinateEntryViewController : TabbarViewController <NavigatableButtonDelegate> {
    IBOutlet UIButton *nextBtn;
    IBOutlet UIButton *previousBtn;
    IBOutlet NavigatableButton *xyAbsBtn;
    IBOutlet NavigatableButton *zAbsBtn;
    IBOutlet UITextField *easting;
    IBOutlet UITextField *northing;
    IBOutlet UITextField *elevation;
    IBOutlet UILabel *currentStationInfo;
}

@property (nonatomic) NSInteger currentSelectedElementTag;

- (IBAction)pressedButton:(UIButton*)sender;

@end

