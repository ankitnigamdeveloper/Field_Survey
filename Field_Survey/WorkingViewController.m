//
//  WorkingViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/06/16.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "WorkingViewController.h"

@interface WorkingViewController ()

@end

@implementation WorkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [cancelButton setTitle:NSLocalizedString(@"working_cancel", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [activityIndicator startAnimating];
    cancelButton.hidden = self.cancelButtonIsHidden;
    taskDescription.text = self.taskText != nil ? self.taskText : @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [activityIndicator stopAnimating];
}

- (IBAction)pressedCancel {
    [self.delegate pressedCancel];
}

@end
