//
//  LoginViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkingViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, WorkingViewControllerDelegate> {
    IBOutlet UITextField* username;
    IBOutlet UITextField* password;
}

@property (nonatomic) NSInteger currentSelectedElementTag;

@end
