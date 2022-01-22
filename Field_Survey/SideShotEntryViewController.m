//
//  SideShotEntryViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "SideShotEntryViewController.h"
#import "SideShotCollectionCell.h"
#import "AppConstants.h"
#import "Utils.h"
#import "Station.h"
#import "ActiveRecord.h"
#import "DataController.h"

@interface SideShotEntryViewController ()
@property (nonatomic, retain) NSMutableOrderedSet *leftShotsDataSource;
@property (nonatomic, retain) NSMutableOrderedSet *rightShotsDataSource;
@property (nonatomic) StationDefaultValuesViewController* stationDefaultsViewController;
@property (nonatomic) UICollectionView* currentCollectionView;
@property (nonatomic) CGFloat previousKeyboardHeight;
@end

@implementation SideShotEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set selectors.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    // Need to set this every time the view appears so the next station button targets the current viewcontroller.
    UIBarButtonItem* rightNextBarButton = [self.parentViewController.navigationItem rightBarButtonItem];
    [rightNextBarButton setTarget:self];
    
    // Load data, update strings.
    [self.parentViewController.navigationItem setTitle:NSLocalizedString(@"side_shot_title", nil)];
    [self loadData];
    [leftSideShotsCollectionView reloadData];
    [rightSideShotsCollectionView reloadData];
    currentStationInfo.text = [NSString stringWithFormat:NSLocalizedString(@"general_station_info_heading", nil), [[DataController sharedInstance] currentStation].calcStation];
    [self updateTabStates];
    [self updatePreviousNextButtons];
    [super updateInsertText];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    
    // Save data.
    [self saveData];
    // Remove the keyboard observer on the cells.
    for (SideShotCollectionCell* cell in leftSideShotsCollectionView.visibleCells) {
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillHideNotification object:nil];
    }
    for (SideShotCollectionCell* cell in rightSideShotsCollectionView.visibleCells) {
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillHideNotification object:nil];
    }
    
    NSInteger currentStationIndex = [[[DataController sharedInstance] currentTraverse].relStation indexOfObject:[[DataController sharedInstance] currentStation]];
    // Check if we're at the invalid index.
    if (currentStationIndex == [[DataController sharedInstance] invalidStationIndex]) {
        [[DataController sharedInstance] recheckValidityOfCurrentInvalidStation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self saveData];
}

- (void)goToNextStation {
    // Run updates.
    [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:[[DataController sharedInstance] currentStation]];
    // Go to the next station.
    [[DataController sharedInstance] nextStation];
    // Now switch to the station & shot tab.
    [self.tabBarController setSelectedIndex:TI_STATION_SHOT];
}

- (void)goToPreviousStation {
    // Run updates.
    [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:[[DataController sharedInstance] currentStation]];
    // Go to the previous station.
    [[DataController sharedInstance] previousStation];
    // Now switch to the station & shot tab.
    [self.tabBarController setSelectedIndex:TI_STATION_SHOT];
}

# pragma mark - Button functions.

- (IBAction)pressedInsert:(id)sender {
    // Save the values.
    [self saveData];
    
    // Check if we can go to the next station.
    NSString *fieldCheck = [[DataController sharedInstance] stationValuesValid:[[DataController sharedInstance] currentStation]];
    // If we didn't find an error and we have an invalid station then set the value.
    NSInteger currentStationIndex = 0;
    if (fieldCheck.length == 0) {
        currentStationIndex = [[[DataController sharedInstance] currentTraverse].relStation indexOfObject:[[DataController sharedInstance] currentStation]];
        // If we made it here then check if there is an invalid station.
        if ([[DataController sharedInstance] allStationsValid] == NO) {
            [[DataController sharedInstance] recheckValidityOfCurrentInvalidStation];
            // Check if there is still a problem.
            if ([[DataController sharedInstance] allStationsValid] == NO) {
                fieldCheck = [NSString stringWithFormat:NSLocalizedString(@"data_controller_err_cant_make_invalid_station_exists", nil), [[DataController sharedInstance] currentInvalidStation].calcStationIndex];
            }
        }
    }
    
    if (fieldCheck.length == 0) {
        // At this point create a new station and go to it.
        [[DataController sharedInstance] insertNewStationAtIndex:currentStationIndex];
        [self goToNextStation];
    } else {
        // Something went wrong, show the message.
        [Utils displayAlertWithMessage:fieldCheck onView:self onOk:nil];
    }
}

- (IBAction)pressedNext:(id)sender {
    // Save the values.
    [self saveData];
    // Go to the next one.
    [self goToNextStation];
}

- (IBAction)pressedPrevious:(id)sender {
    // Save the values.
    [self saveData];
    // Go to the previous one.
    [self goToPreviousStation];
}

// Handles switching from horizontal distance to slope distance.
- (IBAction)pressedSlopeDistance:(UIButton*)sender {
    modeSlopeDistance.selected = true;
    modeHorizontalDistance.selected = false;
    leftShotsSelectedMode1.text = NSLocalizedString(@"side_shot_slope_distance", nil);
    rightShotsSelectedMode2.text = NSLocalizedString(@"side_shot_slope_distance", nil);
}

// Handles switching from slope distance to  horizontal distance.
- (IBAction)pressedHorizontalDistance:(UIButton*)sender {
    modeHorizontalDistance.selected = true;
    modeSlopeDistance.selected = false;
    leftShotsSelectedMode1.text = NSLocalizedString(@"side_shot_horizontal_distance", nil);
    rightShotsSelectedMode2.text = NSLocalizedString(@"side_shot_horizontal_distance", nil);
}

# pragma mark - Save / Load data functions.

- (void)loadData {
    Station *station = [[DataController sharedInstance] currentStation];
    if (station) {
        // Get the left side shots data.
        self.leftShotsDataSource = [[NSMutableOrderedSet alloc] initWithOrderedSet:station.relLeftSidshots];
        // Get the right side shots data.
        self.rightShotsDataSource = [[NSMutableOrderedSet alloc] initWithOrderedSet:station.relRightSideshots];
        // Set the mode.
        if ([station.shDistanceMode intValue] == HORIZONTAL) {
            [self pressedHorizontalDistance:nil];
        } else {
            [self pressedSlopeDistance:nil];
        }
    } else {
        NSLog(@"SideShotEntryViewController: Failed to load station data.");
    }
}

- (void)saveData {
    // Saving occurs at two different points for sideshots: when we navigate away from the view, and when a cell is about to be reused.
    // Here, we only initiate a save to the visible cells. If we have a station we're guaranteed to have side shots (they're created when we make a new station).
    Station *station = [[DataController sharedInstance] currentStation];
    if (station) {
        // Save the changes from all the visible cells.
        for (SideShotCollectionCell* cell in [leftSideShotsCollectionView visibleCells]) {
            [cell saveDataAndUpdateSource:NO];
            [cell clearSideShot];
        }
        for (SideShotCollectionCell* cell in [rightSideShotsCollectionView visibleCells]) {
            [cell saveDataAndUpdateSource:NO];
            [cell clearSideShot];
        }
        // Save the selection mode.
        station.shDistanceMode = modeSlopeDistance.selected ? [NSNumber numberWithInt:SLOPE] : [NSNumber numberWithInt:HORIZONTAL];
        
        [station commit];
    } else {
        NSLog(@"SideShotEntryViewController: Failed to save station data.");
    }
}

- (void)updateTabStates {
    Station *station = [[DataController sharedInstance] currentStation];
    if ([[DataController sharedInstance] allowAccessToCoordinatesAndSideShotsForStation:station]) {
        [super enableTab:TI_COORDINATES];
        [super enableTab:TI_SIDE_SHOTS];
    } else {
        // In this situation we need to go to a different tab. Station & Shot entry is the only tab that doesn't get disabled.
        [self.tabBarController setSelectedIndex:TI_STATION_SHOT];
        return;
    }
}

- (void)updatePreviousNextButtons {
    if ([[DataController sharedInstance] currentTraverse].relStation.count <= 1) {
        nextBtn.hidden = YES;
        previousBtn.hidden = YES;
    } else {
        nextBtn.hidden = [[DataController sharedInstance] isLastStation];
        previousBtn.hidden = [[DataController sharedInstance] isFirstStation];
    }
}

#pragma mark - UICollectionView functions.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == leftSideShotsCollectionView || collectionView == rightSideShotsCollectionView) {
        return MAX_SIDE_SHOTS;
    } else {
        return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SideShotCollectionCell *cell = (SideShotCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SideShotCollectionCell" forIndexPath:indexPath];
    if (cell) {
        // Save the previous data if the cell is currently associated with a sideshot.
        [cell saveDataAndUpdateSource:YES];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (cell) {
        cell.delegate = self;
        // Need to pass these in for saving and navigation logic.
        cell.currentCollectionView = collectionView;
        cell.currentCellIndex = indexPath.row;
        [dict setValue:[NSNumber numberWithBool:(indexPath.row < MAX_SIDE_SHOTS-1)] forKey:CELL_KEY_SHOW_TURNING_POINT];
        if (collectionView == leftSideShotsCollectionView) {
            [dict setValue:[NSString stringWithFormat:NSLocalizedString(@"side_shot_left_cell", nil), [NSNumber numberWithInteger:indexPath.row+1]] forKey:CELL_KEY_TITLE];
            [cell configureWithData:dict forSideShot:self.leftShotsDataSource[indexPath.row]];
        }
        else if (collectionView == rightSideShotsCollectionView) {
            [dict setValue:[NSString stringWithFormat:NSLocalizedString(@"side_shot_right_cell", nil), [NSNumber numberWithInteger:indexPath.row+1]] forKey:CELL_KEY_TITLE];
            [cell configureWithData:dict forSideShot:self.rightShotsDataSource[indexPath.row]];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SideShotCollectionCell *sideShotCell = (SideShotCollectionCell*)cell;
    [sideShotCell saveDataAndUpdateSource:YES];
}

# pragma mark - SideShotCollectionCellDelegate functions.

- (void)goToNextCell:(SideShotCollectionCell*)currentCell {
    NSIndexPath* currPath = [currentCell.currentCollectionView indexPathForCell:currentCell];
    // Subtract 1 from max because row indexes start at 0.
    if (currPath.row < MAX_SIDE_SHOTS-1) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:(currPath.row+1) inSection:0];
        // If the cell isn't visible it will return null when we try to retreive it.
        [currentCell.currentCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        // We delay the select field so that we know the cell is visible.
        double delayInSeconds = 0.35;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            SideShotCollectionCell* cell = (SideShotCollectionCell*)[currentCell.currentCollectionView cellForItemAtIndexPath:path];
            // Continue at the top of the cell.
            [cell cellGainedFocusWithTag:1];
        });
    }
}

- (void)goToPreviousCell:(SideShotCollectionCell*)currentCell {
    NSIndexPath* currPath = [currentCell.currentCollectionView indexPathForCell:currentCell];
    if (currPath.row > 0) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:(currPath.row-1) inSection:0];
        // If the cell isn't visible it will return null when we try to retreive it.
        [currentCell.currentCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        // We delay the select field so that we know the cell is visible.
        double delayInSeconds = 0.35;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            SideShotCollectionCell* cell = (SideShotCollectionCell*)[currentCell.currentCollectionView cellForItemAtIndexPath:path];
            // Continue at the slope distance text field.
            [cell cellGainedFocusWithTag:2];
        });
    }
}

- (void)keyboardWillShow:(NSNotification *)notification onCollectionView:(UICollectionView*)view {
    self.currentCollectionView = view;
    
    // Only push the view up for right if its in landscape mode.
    if (view == rightSideShotsCollectionView && UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        // Determine the collectionview offset
        CGFloat offset = self.view.frame.size.height - (view.frame.origin.y + view.frame.size.height + 10.0);
        
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = (keyboardSize.height - offset) * -1;
            self.view.frame = f;
        }];
    } else if (view == leftSideShotsCollectionView) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = 0.0f;
            self.view.frame = f;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view.frame;
            f.origin.y = 0.0f;
            self.view.frame = f;
        }];
    }
}

- (void)keyboardWillHideOnCollectionView:(UICollectionView*)view {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification {
    CGFloat height = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    // Check the height here so we don't kill the performance when switching between textfields. By checking keyboard height it should only enter here when the orientation has changed.
    if (height != self.previousKeyboardHeight) {
        self.previousKeyboardHeight = height;
        [self keyboardWillShow:notification onCollectionView:self.currentCollectionView];
    }
}

- (IBAction)handleTapOffTextField {
    [self dismissFirstResponder];
}

- (void)dismissFirstResponder {
    [modeSlopeDistance resignFirstResponder];
    [modeHorizontalDistance resignFirstResponder];
    for (SideShotCollectionCell* cell in leftSideShotsCollectionView.visibleCells) {
        [cell stopListeningForEvents];
    }
    for (SideShotCollectionCell* cell in rightSideShotsCollectionView.visibleCells) {
        [cell stopListeningForEvents];
    }
}

// This exists so we can efficiently update the datasource; instead of retrieving all of the objects in a particular relationship, we just update one object in the current datasource without doing additonal reads from core data.
- (void)shouldUpdateSideShotDataWith:(NSDictionary*)updateInfo {
    UICollectionView *collection = [updateInfo objectForKey:CELL_KEY_CURRENT_COLLECTION];
    if (collection == leftSideShotsCollectionView) {
        [self.leftShotsDataSource replaceObjectAtIndex:[[updateInfo valueForKey:CELL_KEY_INDEX] integerValue] withObject:[updateInfo objectForKey:CELL_KEY_SIDE_SHOT]];
    } else {
        [self.rightShotsDataSource replaceObjectAtIndex:[[updateInfo valueForKey:CELL_KEY_INDEX] integerValue] withObject:[updateInfo objectForKey:CELL_KEY_SIDE_SHOT]];
    }
}

# pragma mark - App state change logic.

- (void)appWillResignActive:(NSNotification *)notification {
    [self saveData];
}

- (void)appWillTerminate:(NSNotification *)notification {
    // Save data.
    [self saveData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    
    // Remove the keyboard observer on the cells.
    for (SideShotCollectionCell* cell in leftSideShotsCollectionView.visibleCells) {
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillHideNotification object:nil];
    }
    for (SideShotCollectionCell* cell in rightSideShotsCollectionView.visibleCells) {
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:cell name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    // Reload this as the cells cleared some data when we went to background.
    [self loadData];
    [leftSideShotsCollectionView reloadData];
    [rightSideShotsCollectionView reloadData];
}

# pragma mark - UINavigationBarDelegate functions.

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    return NO;
}

@end
