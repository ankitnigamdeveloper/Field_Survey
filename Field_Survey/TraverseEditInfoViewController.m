//
//  TraverseEditInfoViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/06/17.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "TraverseEditInfoViewController.h"

@interface TraverseEditInfoViewController ()

@end

@implementation TraverseEditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    addStation.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_add_p1", nil) and:NSLocalizedString(@"trav_edit_info_add_p2", nil)];
    insertStation.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_insert_p1", nil) and:NSLocalizedString(@"trav_edit_info_insert_p2", nil)];
    editStation.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_edit_p1", nil) and:NSLocalizedString(@"trav_edit_info_edit_p2", nil)];
    deleteStation.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_delete_p1", nil) and:NSLocalizedString(@"trav_edit_info_delete_p2", nil)];
    firstEdit.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_first_edit_p1", nil) and:NSLocalizedString(@"trav_edit_info_first_edit_p2", nil)];
    err.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_err_p1", nil) and:NSLocalizedString(@"trav_edit_info_err_p2", nil)];
    option1.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_option1_p1", nil) and:NSLocalizedString(@"trav_edit_info_option1_p2", nil)];
    option2.attributedText = [self combine:NSLocalizedString(@"trav_edit_info_option2_p1", nil) and:NSLocalizedString(@"trav_edit_info_option2_p2", nil)];
}

- (NSAttributedString*)combine:(NSString*)str1 and:(NSString*)str2 {
    if (str1 == nil || str2 == nil) {
        return [[NSAttributedString alloc] initWithString:@"" attributes:nil];
    }
    
    NSMutableAttributedString *str1Attrib = [[NSMutableAttributedString alloc] initWithString:str1 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    NSAttributedString *str2Attrib = [[NSAttributedString alloc] initWithString:str2 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                                                                                  NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    [str1Attrib appendAttributedString:str2Attrib];
    
    return str1Attrib;
}

@end
