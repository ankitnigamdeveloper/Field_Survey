//
//  TraverseEditViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "TraverseEditViewController.h"
#import "TraverseShotsCell.h"
#import "TraverseSideShotsCell.h"
#import "Traverse.h"
#import "Station.h"
#import "SideShot.h"
#import "ActiveRecord.h"
#import "Utils.h"
#import "DataController.h"
#import "StationDefaultValuesViewController.h"
#import "LicenseBackgroundSyncController.h"

@interface TraverseEditViewController ()
@property (nonatomic, retain) NSMutableOrderedSet *dataSource;
@property (nonatomic) StationDefaultValuesViewController* stationDefaultsViewController;
@end

@implementation TraverseEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    sideShotsColmun1Label.text = NSLocalizedString(@"trav_edit_station_index", nil);
    sideShotsColmun2Label.text = NSLocalizedString(@"trav_edit_station", nil);
    sideShotsColmun3Label.text = NSLocalizedString(@"trav_edit_side_ssl", nil);
    sideShotsColmun4Label.text = NSLocalizedString(@"trav_edit_side_ssr", nil);
    sideShotsColmun5Label.text = NSLocalizedString(@"trav_edit_side_gnd", nil);
    sideShotsColmun6Label.text = NSLocalizedString(@"trav_edit_side_crk", nil);
    sideShotsColmun7Label.text = NSLocalizedString(@"trav_edit_side_label", nil);
    
    shotsColmun1Label.text = NSLocalizedString(@"trav_edit_station_index", nil);
    shotsColmun2Label.text = NSLocalizedString(@"trav_edit_station", nil);
    shotsColmun3Label.text = NSLocalizedString(@"trav_edit_shot_type", nil);
    shotsColmun4Label.text = NSLocalizedString(@"trav_edit_shot_fore_azim", nil);
    shotsColmun5Label.text = NSLocalizedString(@"trav_edit_shot_hd", nil);
    shotsColmun6Label.text = NSLocalizedString(@"trav_edit_shot_sd", nil);
    shotsColmun7Label.text = NSLocalizedString(@"trav_edit_shot_slp", nil);
    
    self.currentTab = CLSHOTS;
    
    [self pressedShots:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Update values as needed from the current station.
    [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:[[DataController sharedInstance] currentStation]];
    // Get the latest station values.
    self.dataSource = [[NSMutableOrderedSet alloc] initWithOrderedSet:[[DataController sharedInstance] currentTraverse].relStation];
    [traverseShotTable reloadData];
    
    if ([[LicenseBackgroundSyncController sharedInstance] shouldReturnToLogin] == YES) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *view = (UIViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_login"];
        [self presentViewController:view animated:YES completion:nil];
    }
    // If there is a message concerning the data then display it now.
    else if ([[DataController sharedInstance] dataErrorMessage].length > 0) {
        [Utils displayAlertWithMessage:[[DataController sharedInstance] dataErrorMessage] onView:self onOk:^{
            [[DataController sharedInstance] setDataErrorMessage:@""];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableView & data source.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the information needed for the cell.
    NSDictionary *dict = [self configDictFor:indexPath];
    
    // Return a clshot cell.
    if (self.currentTab == CLSHOTS) {
        TraverseShotsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TraverseShotsCell"];
        if (cell == nil) {
            cell = [[TraverseShotsCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:@"TraverseShotsCell"];
        }
        
        if (!cell.accessoryView) {
            UIImageView *tmp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
            tmp.contentMode = UIViewContentModeScaleAspectFit;
            tmp.frame = CGRectMake(0.0, 0.0, 35, 100);
            cell.accessoryView = tmp;
        }
        
        [cell configureWithData:dict];
        return cell;
    }
    
    // Return a sideshot cell.
    else if (self.currentTab == SIDE_SHOTS) {
        TraverseSideShotsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TraverseSideShotsCell"];
        if (cell == nil) {
            cell = [[TraverseSideShotsCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:@"TraverseSideShotsCell"];
        }
        
        // Update the side shot access varible.
        // Note: This is effectively duplicate code from the "allowAccessToCoordinatesAndSideShotsForStationAt:..." function in the DataController.
        //       We're doing this is because in this instance it is more efficient to use the data if we already ahve it available.
        //       Unlike the shots cells, the display here is doing calculations at Run time. If you find that this efficiency here isn't needed
        //       any more then just replace it with:
        //          cell.hasSideShotAccess = [[DataController sharedInstance] allowAccessToCoordinatesAndSideShotsForStationAt:indexPath.row];
        cell.hasSideShotAccess = ![[dict valueForKey:CELL_KEY_PREVIOUS_CELL_SHOT_TYPE] isEqualToString:SHOT_TYPE_RS];
        
        UIImageView *tmp;
        if (cell.hasSideShotAccess == NO) {
            tmp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure_empty"]];
        } else {
            tmp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
        }
        tmp.contentMode = UIViewContentModeScaleAspectFit;
        tmp.frame = CGRectMake(0.0, 0.0, 35, 100);
        cell.accessoryView = tmp;
        
        [cell configureWithData:dict];
        return cell;
    }
    
    return nil;
}

- (NSDictionary*)configDictFor:(NSIndexPath*)indexPath {
    NSMutableDictionary* cellDict = [[NSMutableDictionary alloc] init];
    if (indexPath == nil) {
        return cellDict;
    }
    // Get the station(s) data.
    Station *prevStation = nil;
    if (indexPath.row < self.dataSource.count-1) {
        prevStation = self.dataSource[indexPath.row+1];
    }
    Station* station = self.dataSource[indexPath.row];
    
    /// Setup the values.
    // Index; we store the calculated value.
    [cellDict setValue:station.calcStationIndex forKey:CELL_KEY_STATION_INDEX];
    [cellDict setValue:[NSNumber numberWithBool:(indexPath.row == [[DataController sharedInstance] invalidStationIndex])] forKey:CELL_KEY_STATION_IS_INVALID];
    
    
    // Station; need to check if the station has absolute coordinates set.
    if (station.coEasting != nil || station.coNorthing != nil || station.coElevation != nil) {
        [cellDict setValue:[NSString stringWithFormat:@"* %@", station.calcStation] forKey:CELL_KEY_STATION];
    } else {
        [cellDict setValue:station.calcStation forKey:CELL_KEY_STATION];
    }
    
    // Shot type.
    [cellDict setValue:station.stType forKey:CELL_KEY_SHOT_TYPE];
    
    // Previous cell type. Used to determine colouring of certain fields.
    if (prevStation) {
        [cellDict setValue:prevStation.stType forKey:CELL_KEY_PREVIOUS_CELL_SHOT_TYPE];
    } else {
        [cellDict setValue:@"" forKey:CELL_KEY_PREVIOUS_CELL_SHOT_TYPE];
    }

    // C/L Shots tab.
    if (self.currentTab == CLSHOTS) {
        // Fore Azimuth: if its not IFS then use the value they entered; otherwise use the calculated value.
        if (![station.stType isEqualToString:SHOT_TYPE_IFS]) {
            [cellDict setValue:(station.stForeAzimuth != nil ? [station.stForeAzimuth stringValue] : @"") forKey:CELL_KEY_FOREAZIM];
        } else {
            [cellDict setValue:(station.calcForeAzimuth != nil ? [station.calcForeAzimuth stringValue] : @"") forKey:CELL_KEY_FOREAZIM];
        }
        
        // Horizontal Distance.
        [cellDict setValue:(station.stHorizontalDistance != nil ? [station.stHorizontalDistance stringValue] : [station.calcHorizontalDistance stringValue]) forKey:CELL_KEY_HORIZONTAL_DISTANCE];
        
        // Slope Distance.
        [cellDict setValue:(station.stSlopeDistance != nil ? [station.stSlopeDistance stringValue] : [station.calcSlopeDistance stringValue]) forKey:CELL_KEY_SLOPE_DISTANCE];
        
        // Slope Percentage.
        [cellDict setValue:[station.stSlopePercentage stringValue] forKey:CELL_KEY_SLOPE_PERCENTAGE];
    }
    
    // Sideshots tab.
    else {
        // SSL.
        NSString* ssl = [self sideShotsStringFor:station.relLeftSidshots];
        [cellDict setValue:ssl forKey:CELL_KEY_SSL];
        
        // SSR.
        NSString* ssr = [self sideShotsStringFor:station.relRightSideshots];
        [cellDict setValue:ssr forKey:CELL_KEY_SSR];
        
        // Ground; need to create the ground string.
        NSMutableString *gnd = [NSMutableString stringWithString:@""];
        if (station.stGround1 != nil && station.stGround1.length > 0 && station.stDepth1 != nil) {
            [gnd appendString:[NSString stringWithFormat:@"%@/%@", station.stGround1, [station.stDepth1 stringValue]]];
        }
        if (station.stGround2 != nil && station.stGround2.length > 0 && station.stDepth2 != nil) {
            if (gnd.length > 0) {
                [gnd appendString:@"/"];
            }
            [gnd appendString:[NSString stringWithFormat:@"%@/%@", station.stGround2, [station.stDepth2 stringValue]]];
        }
        if (station.stGround3 != nil && station.stGround3.length > 0) {
            if (gnd.length > 0) {
                [gnd appendString:@"/"];
            }
            [gnd appendString:[NSString stringWithFormat:@"%@", station.stGround3]];
        }
        [cellDict setValue:gnd forKey:CELL_KEY_GROUND];
        
        // Culvert info.
        if (station.stPipeDiameter != nil) {
            [cellDict setValue:[station.stPipeDiameter stringValue] forKey:CELL_KEY_CREEK];
        } else if (station.stBoxWidth != nil && station.stBoxHeight != nil) {
            [cellDict setValue:[NSString stringWithFormat:@"%ldx%ld", (long)[station.stBoxHeight integerValue], (long)[station.stBoxWidth integerValue]] forKey:CELL_KEY_CREEK];
        }
        
        // Label.
        [cellDict setValue:station.stLabel forKey:CELL_KEY_LABEL];
    }
    
    return cellDict;
}

// Creates a string summarizing shot data for display.
- (NSString*)sideShotsStringFor:(NSOrderedSet*)sideshots {
    NSMutableString* str = [NSMutableString stringWithString:@""];
    NSMutableString* potentialValueStr = [NSMutableString stringWithString:@""];
    NSString *slpPercentage = @"";
    NSString *slpDistance = @"";
    for (SideShot *shot in sideshots) {
        if (shot.shSlopeDistance == nil && shot.shSlopePercentage == nil) {
            // Used to account for the user leaving gaps.
            [potentialValueStr appendString:@"/,"];
        } else {
            // Only stick a comma in if its not the first one and something already exists in the string.
            if (shot != sideshots.firstObject && str.length > 0) {
                [str appendFormat:@","];
            }
            // Create the slope percentage / slope distance entry.
            slpPercentage = shot.shSlopePercentage != nil ? [NSString stringWithFormat:@"%.1f", [shot.shSlopePercentage floatValue]] : @"";
            slpDistance = shot.shSlopeDistance != nil ? [NSString stringWithFormat:@"%.1f", [shot.shSlopeDistance floatValue]] : @"";
            [str appendFormat:@"%@%@/%@", potentialValueStr, slpPercentage, slpDistance];
            
            // Reset the potential value if we got here.
            if (potentialValueStr.length > 0) {
                potentialValueStr = [NSMutableString stringWithString:@""];
            }
            
            // Stick a t on it if it is a turning point.
            if ([shot.shTurningPoint boolValue] == YES) {
                [str appendString:@" T"];
            }
        }
    }
    
    if (str.length > 0) {
        // If we have string and it doesn't end with a / then add a finishing /..
        unichar ch = [str characterAtIndex:str.length-1];
        if (![[NSString stringWithFormat:@"%C", ch] isEqualToString:@"/"]) {
            [str appendString:@"/.."];
        } else {
            [str appendString:@".."];
        }
    }
    return str;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If its not the last object in the table (the first station) then we can delete it.
    return (indexPath.row != self.dataSource.count-1) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do this so we reset the styling.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Set the current station to the one we just tapped.
    [[DataController sharedInstance] setCurrentStation:self.dataSource[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"trav_edit_delete_shot", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yes = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_yes", nil) style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [tableView setEditing:NO];
                                 
                                 // Delete the row from the data source. This should be all thats needed to update it.
                                 Station *stationToDelete = self.dataSource[indexPath.row];
                                 [stationToDelete delete];
                                 [Station commit];
                                 
                                 // Get the datasource.
                                 self.dataSource = [[NSMutableOrderedSet alloc] initWithOrderedSet:[[DataController sharedInstance] currentTraverse].relStation];
                                 
                                 // Check if we need to update the invalid index.
                                 if ([[DataController sharedInstance] allStationsValid] == NO &&
                                     [[DataController sharedInstance] invalidStationIndex] >= indexPath.row) {
                                     [[DataController sharedInstance] recheckValidityOfAllStations];
                                 }
                                 
                                 // The table needs to update the calculated fields.
                                 if (self.dataSource.count > 0) {
                                     [[DataController sharedInstance] setShouldRecalculateIndexValues:YES];
                                     [[DataController sharedInstance] setShouldRecalculateStationValues:YES];
                                     [[DataController sharedInstance] setShouldRecalculateForeAzimuthValues:YES];
                                     if (indexPath.row <= self.dataSource.count-1) {
                                         [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:self.dataSource[indexPath.row]];
                                     }
//                                     else {
//                                         // We just deleted the first entry so we need to enforce defaults.
//                                         [[DataController sharedInstance] setShouldEnforceDefaultCoordinateValuesOnFirstStation:YES];
//                                         [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:self.dataSource[self.dataSource.count-1]];
//                                     }
                                 }
                                 
                                 // Remove the row and reload the data.
                                 self.dataSource = [[NSMutableOrderedSet alloc] initWithOrderedSet:[[DataController sharedInstance] currentTraverse].relStation];
                                 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
                                 [tableView reloadData];
                             }];
        
        UIAlertAction* no = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_no", nil) style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [tableView setEditing:NO];
                             }];
        
        [alert addAction:yes];
        [alert addAction:no];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)newCellPromptFor:(NSIndexPath*)path {
    UITableViewCell *cell = [traverseShotTable cellForRowAtIndexPath:path];
    /// Display a prompt for inserting a new cell.
    // No highlighted cell means we have no cell.
    if (cell.isHighlighted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"trav_edit_insert_new_entry", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* insertAbove = [UIAlertAction actionWithTitle:NSLocalizedString(@"trav_edit_insert_above", nil) style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                        [self insertCellAtIndex:path.row];
                                                    }];
        
//        UIAlertAction* insertBelow = [UIAlertAction actionWithTitle:NSLocalizedString(@"trav_edit_insert_below", nil) style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {
//                                                        [alert dismissViewControllerAnimated:YES completion:nil];
//                                                        [self insertCellAtIndex:path.row+1];
//                                                    }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_cancel", nil) style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                    }];
        
        [alert addAction:insertAbove];
//        [alert addAction:insertBelow];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)insertCellAtIndex:(NSInteger)index {
    // only insert if a station is valid
    if ([[DataController sharedInstance] allStationsValid]) {
        // Create the new station at the right index.
        Station* newStation = [[DataController sharedInstance] insertNewStationAtIndex:index];
        [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:newStation];
        // Update and reload the data source.
        self.dataSource = [[NSMutableOrderedSet alloc] initWithOrderedSet:[[DataController sharedInstance] currentTraverse].relStation];
        [traverseShotTable reloadData];
    } else {
        // Invalid station exists, display a message.
        NSString* err = [NSString stringWithFormat:NSLocalizedString(@"data_controller_err_cant_make_invalid_station_exists", nil), [[DataController sharedInstance] currentInvalidStation].calcStationIndex];
        [Utils displayAlertWithMessage:err onView:self onOk:nil];
    }
}

# pragma mark - Segue functions

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL shouldSegue = YES;
    
    // If its side shots then we need to check the cell type.
    if (self.currentTab == SIDE_SHOTS && sender != infoButton) {
        TraverseSideShotsCell *cell = (TraverseSideShotsCell*)sender;
        shouldSegue = cell.hasSideShotAccess;
    }
    
    return shouldSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Runs when we tap a c/l shot cell.
    if ([segue.identifier isEqualToString:@"open_station_coordinates"]) {
        [segue.destinationViewController setSelectedIndex:TI_STATION_SHOT];
    }
    // Runs when we tap a side shots cell.
    else if ([segue.identifier isEqualToString:@"open_station_side_shots"]) {
        [segue.destinationViewController setSelectedIndex:TI_SIDE_SHOTS];
    }
}

# pragma mark - button events.

- (IBAction)pressedPlus:(id)sender {
    // Create a new station if there are no invalid stations.
    if ([[DataController sharedInstance] allStationsValid]) {
        Station *newCurrent = [[DataController sharedInstance] insertNewStationAtIndex:0];
        [[DataController sharedInstance] updateCalculatedFieldsAsNeededFromStation:newCurrent];
        // Set the new station as the current one in the data controller.
        [[DataController sharedInstance] setCurrentStation:newCurrent];
        // Go to the station
        [self performSegueWithIdentifier:@"open_station_coordinates" sender:self];
    }
    // Otherwise show a message stating which station is invalid.
    else {
        NSString* err = [NSString stringWithFormat:NSLocalizedString(@"data_controller_err_cant_make_invalid_station_exists", nil), [[DataController sharedInstance] currentInvalidStation].calcStationIndex];
        [Utils displayAlertWithMessage:err onView:self onOk:nil];
    }
}

- (IBAction)pressedShots:(id)sender {
    // Reload the table to show shot info.
    self.currentTab = CLSHOTS;
    // Hide the sideshots ui.
    sideShotsTab.backgroundColor = [Utils lighterGreen];
    sideShotsTableHeader.hidden = true;
    // Show the shots ui.
    shotsTab.backgroundColor = [Utils darkGreen];
    shotsTableHeader.hidden = false;
    [traverseShotTable reloadData];
}

- (IBAction)pressedSideShots:(id)sender {
    // Reload the table to show side shot info.
    self.currentTab = SIDE_SHOTS;
    // Hide the shots ui.
    shotsTab.backgroundColor = [Utils lighterGreen];
    shotsTableHeader.hidden = true;
    // Show the sideshots ui.
    sideShotsTab.backgroundColor = [Utils darkGreen];
    sideShotsTableHeader.hidden = false;
    [traverseShotTable reloadData];
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Get the location in the table
        CGPoint p = [sender locationInView:traverseShotTable];
        // Get the cell index path from the point.
        NSIndexPath *indexPath = [traverseShotTable indexPathForRowAtPoint:p];
        if (indexPath != nil) {
            [self newCellPromptFor:indexPath];
        }
    }
}

@end
