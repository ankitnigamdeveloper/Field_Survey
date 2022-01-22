//
//  TabbarViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "TabbarViewController.h"
#import "DataController.h"
#import "Station.h"

@interface TabbarViewController ()

@end

@implementation TabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem* rightInsertBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navigation_bar_insert_shot", nil) style:UIBarButtonItemStylePlain target:self action:@selector(pressedInsert:)];
    [self.parentViewController.navigationItem setRightBarButtonItems:@[rightInsertBarButton]];
    [self updateInsertText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - Navigation bar buttons

- (IBAction)pressedInsert:(id)sender {
    
}

- (void)updateInsertText {
    // We need to change the insert button title depending on whether or not we're on the last station.
    UIBarButtonItem* rightInsertBarButton = self.parentViewController.navigationItem.rightBarButtonItem;
    if (![[DataController sharedInstance] isLastStation]) {
        // Every other case use insert.
        [rightInsertBarButton setTitle:NSLocalizedString(@"navigation_bar_insert_shot", nil)];
    } else {
        // Last station use add.
        [rightInsertBarButton setTitle:NSLocalizedString(@"navigation_bar_add_shot", nil)];
    }
}

#pragma mark - Tabbar buttons.

// Disables the specific tabbar item.
- (void)disableTab:(NSInteger)tab {
    if ([[self.tabBarController tabBar] items] && [[[self.tabBarController tabBar] items] count] > tab) {
        [[[[self.tabBarController tabBar] items] objectAtIndex:tab] setEnabled:NO];
    }
}

// Enables the specific tabbar item.
- (void)enableTab:(NSInteger)tab {
    if ([[self.tabBarController tabBar] items] && [[[self.tabBarController tabBar] items] count] > tab) {
        [[[[self.tabBarController tabBar] items] objectAtIndex:tab] setEnabled:YES];
    }
}

@end
