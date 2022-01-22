//
//  Field_Survey_UITests.m
//  Field_Survey_UITests
//
//  Created by Martin on 4/18/16.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Field_Survey_UITests : XCTestCase

@end

@implementation Field_Survey_UITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)tapButtonWithLabel:(NSString*)buttonLabel forElement:(XCUIElement*)element {
    [element.buttons[buttonLabel] tap];
}

- (void)testNewTraverse{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"login_login_btn"] tap];
    [app.navigationBars[@"Traverse List"].buttons[@"New Traverse"] tap];
    
    XCUIElement *newTraverseNameTextField = app.textFields[@"new_traverse_name"];
    [newTraverseNameTextField tap];
    [newTraverseNameTextField typeText:@"Cindy Traverse"];
    
    XCUIElement *newTraverseDescriptionTextField = app.textFields[@"new_traverse_description"];
    //[newTraverseDescriptionTextField tap];
    [newTraverseDescriptionTextField typeText:@"Test1"];
    
    XCUIElement *newTraverseCrewTextField = app.textFields[@"new_traverse_crew"];
    [newTraverseCrewTextField tap];
    [newTraverseCrewTextField typeText:@"Martin and Cindy"];
    
    XCUIElement *newTraverseStartIndexTextField = app.textFields[@"new_traverse_start_index"];
    [newTraverseStartIndexTextField tap];
    [newTraverseStartIndexTextField typeText:@"120"];
    
    XCUIElement *newTraverseStartStationTextField = app.textFields[@"new_traverse_start_station"];
    [newTraverseStartStationTextField tap];
    [newTraverseStartStationTextField typeText:@"1"];
    [app.navigationBars[@"New Traverse"].buttons[@"Traverse List"] tap];
    
}

- (void)testSecondTraverse{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"login_login_btn"] tap];
    [app.navigationBars[@"Traverse List"].buttons[@"New Traverse"] tap];
    
    XCUIElement *newTraverseNameTextField = app.textFields[@"new_traverse_name"];
    [newTraverseNameTextField tap];
    [newTraverseNameTextField typeText:@"Cindy"];
    [app.navigationBars[@"New Traverse"].buttons[@"Traverse List"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [[[[tablesQuery childrenMatchingType:XCUIElementTypeCell] matchingIdentifier:@"trav_list_cell"] elementBoundByIndex:0].staticTexts[@"This is a very detailed and sublime description label."] tap];
    [app.buttons[@"edit_trav_list_side_shots_tab"] tap];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"2"].staticTexts[@"SR"] tap];
    // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"1:1"].staticTexts[@"SR"] tap];
    // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
    [app.buttons[@"coord_entry_xy_abs_btn"] tap];
    [app.buttons[@"coord_entry_z_abs_btn"] tap];
    [app.navigationBars[@"Traverse 001"].buttons[@"Station Table"] tap];
    [app.navigationBars[@"Station Table"].buttons[@"Traverse List"] tap];
}

- (void)testThirdTraverse{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"login_login_btn"] tap];
    [[[[app.tables childrenMatchingType:XCUIElementTypeCell] matchingIdentifier:@"trav_list_cell"] elementBoundByIndex:0].staticTexts[@"23.1324234123413, -50.13432432234, 0.13211123412"] tap];
    [app.buttons[@"edit_trav_list_add_new"] tap];
    
    XCUIElement *coordEntryEastingTextField = app.textFields[@"coord_entry_easting"];
    [coordEntryEastingTextField.buttons[@"Clear text"] tap];
    [coordEntryEastingTextField typeText:@"123"];
    
    XCUIElement *coordEntryNorthingTextField = app.textFields[@"coord_entry_northing"];
    [coordEntryNorthingTextField.buttons[@"Clear text"] tap];
    [coordEntryNorthingTextField tap];
    [coordEntryNorthingTextField typeText:@"321"];
    
    XCUIElement *coordEntryElevationTextField = app.textFields[@"coord_entry_elevation"];
    [coordEntryElevationTextField tap];
    [coordEntryElevationTextField tap];
    [app.navigationBars[@"Traverse 001"].buttons[@"Station Table"] tap];
}



//- (void)testLogin {
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    
//    // Enter login info and tap login.
//    XCUIElement *usernameTextField = app.textFields[@"Username"];
//    [usernameTextField tap];
//    [usernameTextField typeText:@"hello"];
//    XCUIElement *passwordSecureTextField = app.secureTextFields[@"Password"];
//    [passwordSecureTextField tap];
//    [passwordSecureTextField typeText:@"world"];
//    [self tapButtonWithLabel:@"Login" forElement:app];
//}
//
//- (void)testSettingToggles {
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    
//    // Open settings and press the toggle buttons.
//    [app.navigationBars[@"Traverse List"].buttons[@"Settings"] tap];
//    XCUIElement *settingsTgUsernameSwitch = app.switches[@"settings_tg_username"];
//    XCUIElement *settingsTgAutoLoginSwitch = app.switches[@"settings_tg_auto_login"];
//    [settingsTgUsernameSwitch tap];
//    [settingsTgAutoLoginSwitch tap];
//    [settingsTgAutoLoginSwitch tap];
//    [settingsTgUsernameSwitch tap];
//}
//
//- (void)testPasswordChange {
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    
//    // Close settings and navigate back to it from inside a new traverse.
//    [app.navigationBars[@"Settings"].buttons[@"Traverse List"] tap];
//    XCUIElement *traverseListNavigationBar = app.navigationBars[@"Traverse List"];
//    [self tapButtonWithLabel:@"New Traverse" forElement:traverseListNavigationBar];
//    XCUIElement *traverseeditviewNavigationBar = app.navigationBars[@"TraverseEditView"];
//    [self tapButtonWithLabel:@"Settings" forElement:traverseeditviewNavigationBar];
//    
//    // Enter info into change password.
//    [self tapButtonWithLabel:@"Change Password" forElement:app];
//    XCUIElement *pcOldPasswordSecureTextField = app.secureTextFields[@"pc_old_password"];
//    [pcOldPasswordSecureTextField tap];
//    [pcOldPasswordSecureTextField typeText:@"aaaaaaaaa"];
//    
//    XCUIElement *pcNewPasswordSecureTextField = app.secureTextFields[@"pc_new_password"];
//    [pcNewPasswordSecureTextField tap];
//    [pcNewPasswordSecureTextField typeText:@"bbbbbbbbb"];
//    
//    XCUIElement *pcReNewPasswordSecureTextField = app.secureTextFields[@"pc_re_new_password"];
//    [pcReNewPasswordSecureTextField tap];
//    [pcReNewPasswordSecureTextField typeText:@"ccccccccc"];
//    
//    [self tapButtonWithLabel:@"Submit" forElement:app];
//    
//    // Navigate backout, then back into settings, and logout.
//    XCUIElement *settingsNavigationBar = app.navigationBars[@"Settings"];
//    [[[[settingsNavigationBar childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
//    [self tapButtonWithLabel:@"Traverse List" forElement:traverseeditviewNavigationBar];
//    [self tapButtonWithLabel:@"Settings" forElement:traverseListNavigationBar];
//    [self tapButtonWithLabel:@"Logout" forElement:app];
//    XCUIElement *usernameTextField = app.textFields[@"Username"];
//    [usernameTextField tap];
//    [usernameTextField typeText:@"goodbye world"];
//}

@end
