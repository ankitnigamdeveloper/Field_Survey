//
//  SettingsViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkingViewController.h"

@interface SettingsViewController : UIViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate, WorkingViewControllerDelegate> {
    IBOutlet UILabel* company;
    IBOutlet UILabel* subscriptionDate;
    IBOutlet UILabel* username;
    IBOutlet UILabel* appVersion;
}

@end
