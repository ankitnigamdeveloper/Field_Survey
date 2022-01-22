//
//  ShotTypeSelectionViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/06/08.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "ShotTypeSelectionViewController.h"
#import "AppConstants.h"

@interface ShotTypeSelectionViewController ()

@end

@implementation ShotTypeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update buttons.
    fsBtn.selected = NO;
    rsBtn.selected = NO;
    ifsBtn.selected = NO;
    
    if ([self.currentSelectedValue isEqualToString:SHOT_TYPE_FS]) {
        currentSelectedButton = fsBtn;
    } else if ([self.currentSelectedValue isEqualToString:SHOT_TYPE_RS]) {
        currentSelectedButton = rsBtn;
    } else if ([self.currentSelectedValue isEqualToString:SHOT_TYPE_IFS]) {
        currentSelectedButton = ifsBtn;
    }
    
    if (currentSelectedButton) {
        currentSelectedButton.selected = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)selectedShotType:(UIButton*)sender {
    // Update buttons.
    currentSelectedButton.selected = NO;
    currentSelectedButton = sender;
    sender.selected = YES;
    
    // Send the selected value to the delegate.
    if (sender == fsBtn) {
        [self selectedType:SHOT_TYPE_FS];
    } else if (sender == rsBtn) {
        [self selectedType:SHOT_TYPE_RS];
    } else if (sender == ifsBtn) {
        [self selectedType:SHOT_TYPE_IFS];
    }
}

#pragma mark - ShotTypeSelectionDelegate functions

- (void)selectedType:(NSString*)type {
    [self.delegate selectedType:type];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
