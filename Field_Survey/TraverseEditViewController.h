//
//  TraverseEditViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "StationDefaultValuesViewController.h"

@interface TraverseEditViewController : UIViewController <UITableViewDelegate> {
    IBOutlet UITableView* traverseShotTable;
    IBOutlet UIView* sideShotsTableHeader;
    IBOutlet UIView* shotsTableHeader;
    IBOutlet UIButton* shotsTab;
    IBOutlet UIButton* sideShotsTab;
    IBOutlet UIButton* infoButton;
    
    IBOutlet UILabel* shotsColmun1Label;
    IBOutlet UILabel* shotsColmun2Label;
    IBOutlet UILabel* shotsColmun3Label;
    IBOutlet UILabel* shotsColmun4Label;
    IBOutlet UILabel* shotsColmun5Label;
    IBOutlet UILabel* shotsColmun6Label;
    IBOutlet UILabel* shotsColmun7Label;
    
    IBOutlet UILabel* sideShotsColmun1Label;
    IBOutlet UILabel* sideShotsColmun2Label;
    IBOutlet UILabel* sideShotsColmun3Label;
    IBOutlet UILabel* sideShotsColmun4Label;
    IBOutlet UILabel* sideShotsColmun5Label;
    IBOutlet UILabel* sideShotsColmun6Label;
    IBOutlet UILabel* sideShotsColmun7Label;
}

@property (nonatomic) Tabs currentTab;

-(IBAction)pressedShots:(id)sender;
-(IBAction)pressedSideShots:(id)sender;

@end