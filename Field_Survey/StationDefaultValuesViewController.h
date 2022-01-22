//
//  StationDefaultValuesViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/06/23.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigatableButton.h"
#import "ShotTypeSelectionViewController.h"

@protocol StationDefaultValuesDelegate <NSObject>
- (void)pressedDefaultsCancel;
- (void)createTraverseWithDefaultValues:(NSDictionary*)values atIndex:(NSInteger)index andDisplayNewStation:(BOOL)displayAfter;
@end

@interface StationDefaultValuesViewController : UIViewController <UITextFieldDelegate, ShotTypeSelectionDelegate> {
    IBOutlet NavigatableButton *slopeDistanceBtn;
    IBOutlet NavigatableButton *horizontalDistanceBtn;
    IBOutlet UIButton* typeBtn;
    IBOutlet UITextField *foreAzimuth;
    IBOutlet UITextField *slopeDistance;
    IBOutlet UITextField *horizontalDistance;
    IBOutlet UITextField *slopePercentage;
}
@property (nonatomic, strong) id<StationDefaultValuesDelegate> delegate;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL navigateAfter;

@end
