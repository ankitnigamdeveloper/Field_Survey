//
//  StationShotEntryViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigatableButton.h"
#import "TabbarViewController.h"
#import "ShotTypeSelectionViewController.h"
#import "StationDefaultValuesViewController.h"

@interface StationShotEntryViewController : TabbarViewController <UITextFieldDelegate, NavigatableButtonDelegate, ShotTypeSelectionDelegate> {
    IBOutlet NavigatableButton *slopeDistanceBtn;
    IBOutlet NavigatableButton *horizontalDistanceBtn;
    IBOutlet NavigatableButton *pipeBtn;
    IBOutlet NavigatableButton *boxBtn;
    IBOutlet UIButton *nextBtn;
    IBOutlet UIButton *previousBtn;
    IBOutlet UIButton *typeBtn;
    IBOutlet UITextField *foreAzimuth;
    IBOutlet UITextField *slopeDistance;
    IBOutlet UITextField *horizontalDistance;
    IBOutlet UITextField *slopePercentage;
    IBOutlet UITextField *groundLayer1;
    IBOutlet UITextField *groundLayer1depth;
    IBOutlet UITextField *groundLayer2;
    IBOutlet UITextField *groundLayer2depth;
    IBOutlet UITextField *groundLayer3;
    IBOutlet UITextField *groundLayer3depth;
    IBOutlet UITextField *diameter;
    IBOutlet UITextField *height;
    IBOutlet UITextField *width;
    IBOutlet UITextField *label;
    IBOutlet UILabel *currentStationInfo;
}

@property (nonatomic) NSInteger currentSelectedElementTag;

@end

