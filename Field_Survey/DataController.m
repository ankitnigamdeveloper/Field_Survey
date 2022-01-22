//
//  DataController.m
//  Field_Survey
//
//  Created by Martin on 2016/06/15.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import "DataController.h"
#import "ActiveRecord.h"
#import "AppConstants.h"
#import "Utils.h"

@interface DataController ()
// Used when creating the turning point flag for sideshots.
@property (nonatomic, retain) NSArray* turningPointBitShiftValues;
@end

@implementation DataController

@synthesize currentTraverse;
@synthesize currentStation;
@synthesize shouldRecalculateIndexValues;
@synthesize shouldRecalculateStationValues;
@synthesize shouldRecalculateForeAzimuthValues;
@synthesize shouldEnforceDefaultCoordinateValuesOnFirstStation;
@synthesize invalidStationIndex;
@synthesize dataErrorMessage;

#pragma mark - Singleton functions.

+ (id)sharedInstance {
    static DataController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.turningPointBitShiftValues = [[NSArray alloc] initWithObjects:
                                           [NSNumber numberWithInteger:BIT_0],
                                           [NSNumber numberWithInteger:BIT_1],
                                           [NSNumber numberWithInteger:BIT_2],
                                           [NSNumber numberWithInteger:BIT_3],
                                           [NSNumber numberWithInteger:BIT_4],
                                           [NSNumber numberWithInteger:BIT_5],
                                           [NSNumber numberWithInteger:BIT_6],
                                           [NSNumber numberWithInteger:BIT_7],
                                           [NSNumber numberWithInteger:BIT_8],
                                           [NSNumber numberWithInteger:BIT_9],
                                           [NSNumber numberWithInteger:BIT_10],
                                           [NSNumber numberWithInteger:BIT_11], nil];
        self.currentStation = nil;
        self.currentTraverse = nil;
        self.dataErrorMessage = nil;
    }
    return self;
}

- (BOOL)allStationsValid {
    return self.invalidStationIndex == ALL_STATIONS_VALID;
}

- (BOOL)isFirstStation {
    return self.currentTraverse != nil // Check for nils.
        && self.currentStation != nil
        && [self.currentTraverse.relStation lastObject] == self.currentStation; // Check if the last object in the ordered set is the current station.
}

- (BOOL)isLastStation {
    return self.currentTraverse != nil // Check for nils.
        && self.currentStation != nil
        && [self.currentTraverse.relStation firstObject] == self.currentStation; // Check if the first object in the ordered set is the current station.
}

- (Station*)currentInvalidStation {
    if (self.currentTraverse == nil || [self allStationsValid]) {
        return nil;
    }
    
    return [self.currentTraverse.relStation objectAtIndex:self.invalidStationIndex];
}

- (BOOL)allowAccessToCoordinatesAndSideShotsForStationAt:(NSInteger)index {
    Station *station = [[[DataController sharedInstance] currentTraverse].relStation objectAtIndex:index];
    return [self allowAccessToCoordinatesAndSideShotsForStation:station];
}

- (BOOL)allowAccessToCoordinatesAndSideShotsForStation:(Station*)station {
    if (station == nil) {
        return NO;
    }
    
    BOOL allowAccess = YES;
    
    // Check if there is a entry before the cell.
    if (self.currentTraverse != nil && self.currentTraverse.relStation != nil && [self.currentTraverse.relStation lastObject] != station) {
        Station *previousStation = [self.currentTraverse.relStation objectAtIndex:[self.currentTraverse.relStation indexOfObject:station]+1];
        allowAccess = ![previousStation.stType isEqualToString:SHOT_TYPE_RS];
    }
    
    return allowAccess;
}


#pragma mark - Creation functions.

- (Station*)createNewStation {
    // Create a new station & assign default values.
    Station *station = [Station create];
    
    // Create the station defaults.
    StationDefaults *stationDefaults = [StationDefaults create];
    [stationDefaults commit];
    station.relDefaults = stationDefaults;
    
    // Create empty sideshots on the station. Side shots are split between two different relationships: a left side shots relationship, and a right side shots relationship. Set it as a turning point by default.
    NSMutableOrderedSet *leftSideShots = [[NSMutableOrderedSet alloc] initWithCapacity:12];
    NSMutableOrderedSet *rightSideShots = [[NSMutableOrderedSet alloc] initWithCapacity:12];
    for (int i = 0; i < 12; i++) {
        SideShot *lShot = [SideShot create];
        lShot.shTurningPoint = [NSNumber numberWithBool:YES];
        SideShot *rShot = [SideShot create];
        rShot.shTurningPoint = [NSNumber numberWithBool:YES];
        [leftSideShots addObject:lShot];
        [rightSideShots addObject:rShot];
    }
    station.relLeftSidshots = leftSideShots;
    station.relRightSideshots = rightSideShots;
    
    // Assign the default values.
    station.stType = stationDefaults.stType;
    station.stForeAzimuth = stationDefaults.stForeAzimuth;
    station.stSlopeDistance = stationDefaults.stSlopeDistance;
    station.stHorizontalDistance = stationDefaults.stHorizontalDistance;
    station.stSlopePercentage = stationDefaults.stSlopePercentage;
    
    [station commit];
    return station;
}

- (Station*)insertNewStationAtIndex:(NSInteger)index {
    if (self.currentTraverse == nil) {
        return nil;
    }
    
    Station *station = [self createNewStation];
    // Get the list of existing stations and insert the new station.
    NSMutableOrderedSet *tmp = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.currentTraverse.relStation];
    // If they give us a negative index insert it at the start.
    if (index < 0) {
        [tmp insertObject:station atIndex:0];
    }
    // If they give us an index thats too big make it the first station (last station in the ordered set).
    else if (index >= tmp.count) {
        index = tmp.count-1;
        [tmp addObject:station];
        // We've just inserted a new first station so we should enforce defaults.
        self.shouldEnforceDefaultCoordinateValuesOnFirstStation = YES;
    }
    // Otherwise stick it where they want it.
    else {
        [tmp insertObject:station atIndex:index];
    }
    
    // Set the station ordered set on the current traverse and save.
    self.currentTraverse.relStation = tmp;
    [self.currentTraverse commit];
    
    // Set recalculation flags.
    self.shouldRecalculateIndexValues = YES;
    self.shouldRecalculateStationValues = YES;
    self.shouldRecalculateForeAzimuthValues = YES;
    self.invalidStationIndex = index;
    
    return station;
}

#pragma mark - Navivation functions.

// This will not handle creating of a new station.
- (Station*)nextStation {
    if (self.currentStation == nil || self.currentTraverse == nil || [self isLastStation]) {
        return nil;
    }
    
    // If we haven't set the current station then assign it to object 0.
    if (self.currentStation == nil) {
        self.currentStation = [self.currentTraverse.relStation objectAtIndex:0];
    } else {
        NSInteger currentStationIndex = [self.currentTraverse.relStation indexOfObject:self.currentStation];
        // Otherwise go to the next one.
        self.currentStation = [self.currentTraverse.relStation objectAtIndex:currentStationIndex-1];
    }
    
    return self.currentStation;
}

- (Station*)previousStation {
    if (self.currentStation == nil || self.currentTraverse == nil || [self isFirstStation]) {
        return nil;
    }
    
    // If we haven't set the current station then assign it to object 0.
    if (self.currentStation == nil) {
        self.currentStation = [self.currentTraverse.relStation lastObject];
    } else {
        NSInteger currentStationIndex = [self.currentTraverse.relStation indexOfObject:self.currentStation];
        // Otherwise go to the next one.
        self.currentStation = [self.currentTraverse.relStation objectAtIndex:currentStationIndex+1];
    }
    
    return self.currentStation;
}

#pragma mark - Update & Validation functions.

- (NSString*)stationValuesValid:(Station*)station {
    NSString *err_msg = @"";
    
    // Check shot type.
    if (station.stType == nil ||
        !([station.stType isEqualToString:SHOT_TYPE_RS] || [station.stType isEqualToString:SHOT_TYPE_IFS] || [station.stType isEqualToString:SHOT_TYPE_FS])) {
        err_msg = NSLocalizedString(@"station_defaults_err_shot", nil);
    }
    // Check fore azimuth.
    else if (station.stForeAzimuth == nil && station.stType != nil && ![station.stType isEqualToString:SHOT_TYPE_IFS]) {
        err_msg = NSLocalizedString(@"station_defaults_err_fore_azim", nil);
    }
    // Check slope distance and horizontal distance.
    else if (station.stSlopeDistance == nil && station.stHorizontalDistance == nil) {
        err_msg = NSLocalizedString(@"station_defaults_err_distance", nil);
    }
    // Check slope percentage.
    else if (station.stSlopePercentage == nil) {
        err_msg = NSLocalizedString(@"station_defaults_err_slp_per", nil);
    }
    
    // TODO Add other check types.
    
    return err_msg;
}

- (void)updateAllCalculatedFieldsAsNeeded {
    // All functions that have update logic here need to handle nil as an indicator to update all.
    [self updateCalculatedFieldsAsNeededFromStation:nil];
}

- (void)updateCalculatedFieldsAsNeededFromStation:(Station*)station {
    if (self.shouldEnforceDefaultCoordinateValuesOnFirstStation) {
        // If we're doing this then we've either deleted or inserted at the last object.
        self.shouldEnforceDefaultCoordinateValuesOnFirstStation = NO;
        [self enforceDefaultCoordinateValuesOnFirstStation];
    }
    
    // Update the 'index' values.
    if (self.shouldRecalculateIndexValues) {
        // Reset the flag and calculate.
        self.shouldRecalculateIndexValues = NO;
        [self recalculateIndexValuesFrom:station];
    }
    
    // Update the 'station' values.
    if (self.shouldRecalculateStationValues) {
        self.shouldRecalculateStationValues = NO;
        [self recalculateStationValuesFrom:station];
    }
    
    // Update the ForeAzimuth values.
    if (self.shouldRecalculateForeAzimuthValues) {
        self.shouldRecalculateForeAzimuthValues = NO;
        [self recalculateForeAzimuthValuesFrom:station];
    }
}

- (void)enforceDefaultCoordinateValuesOnFirstStation {
    if (self.currentTraverse == nil || self.currentTraverse.relStation == nil || self.currentTraverse.relStation.count == 0) {
        return;
    }
    Station* firstStation = [self.currentTraverse.relStation lastObject];
    [firstStation enforceDefaultCoordinateValues];
    [firstStation commit];
}

- (void)recheckValidityOfAllStations {
    if (self.currentTraverse == nil) {
        return; // Nothing to check.
    }
    self.invalidStationIndex = ALL_STATIONS_VALID;
    
    NSString* valid;
    // Check the traverse for a invalid station.
    for (Station* station in self.currentTraverse.relStation) {
        valid = [self stationValuesValid:station];
        if (valid.length != 0) {
            self.invalidStationIndex = [self.currentTraverse.relStation indexOfObject:station];
            break;
        }
    }
}

- (void)recheckValidityOfCurrentInvalidStation {
    if (self.currentTraverse == nil || [self allStationsValid]) {
        return; // Nothing to check.
    }
    
    Station* station = [self.currentTraverse.relStation objectAtIndex:self.invalidStationIndex];
    
    // Check the traverse for a invalid station.
    NSString* valid = [self stationValuesValid:station];
    if (valid.length == 0) {
        self.invalidStationIndex = ALL_STATIONS_VALID;
    }
}

- (BOOL)stationIsValid:(Station*)station {
    if (station == nil) {
        return NO; // Nothing to check.
    }
    
    // Don't reset the invalid station value here.
    NSString* valid = [self stationValuesValid:station];
    if (valid.length != 0) {
        return NO;
    }
    return YES;
}

- (void)recalculateForeAzimuthValuesFrom:(Station*)station {
    /// Calculate the station ForeAzimuth value for all stations before the change point.
    NSMutableOrderedSet* stations = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.currentTraverse.relStation];
    int changeIndex;
    // Get the change point. If they passed in nil update all the station indexes.
    if (station != nil) {
        changeIndex = (int)[stations indexOfObject:station];
    } else {
        // 0 index = last entry.
        changeIndex = 0;
    }
    
    Station* currStation = nil;
    Station* firstForwardShotStation = [self getFirstForwardShotStationAtOrAfterIndex:changeIndex];

    // Go through the stations and
    for (int i = changeIndex; i < stations.count; i++) {
        // We don't want to run any sort of up on the current station if its invalid.
        if (i != self.invalidStationIndex) {
            currStation = stations[i];
            // If its an ifs station then set the value of the fore azimuth to the fs station after it.
            if ([currStation.stType isEqualToString:SHOT_TYPE_IFS]) {
                if (firstForwardShotStation != nil) {
                    currStation.calcForeAzimuth = firstForwardShotStation.stForeAzimuth;
                } else {
                    currStation.calcForeAzimuth = nil;
                }
                [currStation commit];
            }
            
            // If we encounter another forward shot station we can stop.
            else if ([currStation.stType isEqualToString:SHOT_TYPE_FS] && i != changeIndex) {
                break;
            }
        }
    }
}

// Returns nil if no forward shot station is found.
- (Station*)getFirstForwardShotStationAtOrAfterIndex:(int)index {
    // Can't do anything if there is no traverse set.
    if (self.currentTraverse == nil) {
        return nil;
    }
    
    NSMutableOrderedSet* stations = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.currentTraverse.relStation];
    Station* currStation = nil;
    Station* firstStation = nil;
    
    // Go through the stations of the current traverse and find the
    for (int i = index; i >= 0; i--) {
        currStation = i > 0 ? stations[i] : [stations firstObject];
        if ([currStation.stType isEqualToString:SHOT_TYPE_FS]) {
            firstStation = currStation;
            break;
        }
    }
    return firstStation;
}

- (void)recalculateStationValuesFrom:(Station*)station {
    /// Calculate the station 'station' value for all stations after the change point.
    NSMutableOrderedSet* stations = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.currentTraverse.relStation];
    int changeIndex;
    // Get the change point. If they passed in nil update all the station indexes.
    if (station != nil) {
        changeIndex = (int)[stations indexOfObject:station];
    } else {
        // The last entry is is the one that shows up at the bottom as the first entry.
        changeIndex = (int)stations.count - 1;
    }
    
    Station* prevStation = nil;
    Station* lastCenterlineStation = nil;
    // If we're updating from the not the first entry (the last object) then we need to find the value to update.
    if (changeIndex != stations.count-1) {
        lastCenterlineStation = [self getFirstCenterlineStationBeforeIndex:changeIndex];
    }
    Station* currStation = nil;
    
    // Go through the stations and update the 'station' values.
    for (int i = changeIndex; i >= 0; i--) {
        currStation = stations[i];
        // If its not the last object then we have a previous station to draw on.
        if (i < stations.count-1) {
            // If we encounter the invalid index then just kick out and stop updating.
            if (i+1 == self.invalidStationIndex) {
                break;
            }
            
            prevStation = stations[i+1];
            // Get the last stations value
            NSArray* lastCenterlineStationValue = [lastCenterlineStation.calcStation componentsSeparatedByString:@":"];
            
            // Radial shot.
            if ([prevStation.stType isEqualToString:SHOT_TYPE_RS]) {
                NSArray* prevStationValue = [prevStation.calcStation componentsSeparatedByString:@":"];
                // Get the previous station value and increment the index value.
                if (prevStationValue.count > 1) {
                    // Increment the index.
                    currStation.calcStation = [NSString stringWithFormat:@"%@:%d", lastCenterlineStationValue[0], [prevStationValue[1] intValue]+1];
                } else {
                    // This is the first one for the index.
                    currStation.calcStation = [NSString stringWithFormat:@"%@:1", lastCenterlineStationValue[0]];
                }
            }
            
            // Else its FS and IFS.
            else {
                // Append the previous station's horizontal distance to the last center line station to make the new station value.
                // Either the stHorizontalDistance or calcHorizontalDistance field should have a value at this point.
                double distanceToAdd = prevStation.stHorizontalDistance != nil ? [prevStation.stHorizontalDistance doubleValue] : [prevStation.calcHorizontalDistance doubleValue];
                currStation.calcStation = [NSString stringWithFormat:@"%.1f", [lastCenterlineStationValue[0] doubleValue] + distanceToAdd];
            }

            /// Last centerline shot criteria:
            //    The previous station type needs to be a forward shot.
            if ([prevStation.stType isEqualToString:SHOT_TYPE_FS]) {
                lastCenterlineStation = currStation;
            }
        }
        // No previous traverse so use the value from the traverse object.
        else {
            currStation.calcStation = [self.currentTraverse.trStation stringValue];
            if (self.currentTraverse.trStation == nil) {
                // Should never get here, but if we do just assign 0.
                currStation.calcStation = @"0";
            }
            lastCenterlineStation = currStation;
        }
        [currStation commit];
    }
}

// Returns the first station (last in the set) if it doens't find a valid center line station.
- (Station*)getFirstCenterlineStationBeforeIndex:(int)index {
    // Can't do anything if there is no traverse set.
    if (self.currentTraverse == nil) {
        return nil;
    }
    
    NSMutableOrderedSet* stations = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.currentTraverse.relStation];
    Station* currStation = nil;
    Station* prevStation = nil;
    
    // Go through the stations of the current traverse and find the
    for (int i = index+1; i < stations.count; i++) {
        currStation = stations[i];
        prevStation = i < stations.count - 1 ? stations[i+1] : [stations lastObject];
        /// Last centerline criteria:
        //    The previous shot needs to be a forward shot.
        if ([prevStation.stType isEqualToString:SHOT_TYPE_FS]) {
            break;
        }
    }
    return currStation;
}

- (void)recalculateIndexValuesFrom:(Station*)station {
    /// Calculate the station 'index' for all of the stations after the change point.
    NSMutableOrderedSet* stations = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.currentTraverse.relStation];
    int changeIndex;
    // Get the change point. If they passed in nil update all the station indexes.
    if (station != nil) {
        changeIndex = (int)[stations indexOfObject:station];
    } else {
        // The last entry is is the one that shows up at the bottom as the first entry.
        changeIndex = (int)stations.count - 1;
    }

    Station* prevStation = nil;
    Station* currStation = nil;
    // Go through the stations and update the 'index' values.
    for (int i = changeIndex; i >= 0; i--) {
        currStation = stations[i];
        // If its not the last object then we have a previous station to draw on.
        if (i < stations.count-1) {
            prevStation = stations[i+1];
            
            // Get the previous 'index' value.
            NSArray* prevStationIndex = [prevStation.calcStationIndex componentsSeparatedByString:@":"];
            
            if ([prevStation.stType isEqualToString:SHOT_TYPE_RS] || [prevStation.stType isEqualToString:SHOT_TYPE_IFS]) {
                // If prevStationIndex has a count greater than 1 then we know that it has an index value.
                if (prevStationIndex.count > 1) {
                    // Increment the index.
                    currStation.calcStationIndex = [NSString stringWithFormat:@"%@:%d", prevStationIndex[0], [prevStationIndex[1] intValue]+1];
                } else {
                    // This is the first one for the index.
                    currStation.calcStationIndex = [NSString stringWithFormat:@"%@:1", prevStationIndex[0]];
                }
            }  else { // Else assume FS type.
                currStation.calcStationIndex = [NSString stringWithFormat:@"%d", [prevStationIndex[0] intValue]+1];
            }
        }
        // No previous traverse so use the value from the traverse object.
        else {
            currStation.calcStationIndex = self.currentTraverse.trStartIndex;
            if (self.currentTraverse.trStartIndex == nil || [self.currentTraverse.trStartIndex isEqualToString:@""]) {
                // Should never get here, but if we do just assign 0.
                currStation.calcStationIndex = @"0";
            }
        }
        [currStation commit];
    }
    
    // Reset calculation flag.
    shouldRecalculateIndexValues = NO;
}

# pragma mark - Traverse export functions.

- (ExportResult*)exportDataFromTraverse:(Traverse*)traverse {
    NSMutableString *data = [[NSMutableString alloc] init];
    
    NSDecimalNumberHandler *decimalRoundingBehaviour = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                                    scale:1
                                                                                                         raiseOnExactness:NO
                                                                                                          raiseOnOverflow:NO
                                                                                                         raiseOnUnderflow:NO
                                                                                                      raiseOnDivideByZero:NO];

    // Station,FORE,BACK,H.D.,S.D.,Slp.(%),LABEL-1,LABEL-2,X,Y,Z,TYPE,CRK,RP-AZ,RP-HD,GND1,CL.DP.1,GND2,CL.DP.2,GND3,Inst. H,Target H,SL1-S.D.,SL1-Slp.(%),SL1-DP.1,SL1-DP.2,SL2-S.D.,SL2-Slp.(%),SL2-DP.1,SL2-DP.2,SL3-S.D.,SL3-Slp.(%),SL3-DP.1,SL3-DP.2,SL4-S.D.,SL4-Slp.(%),SL4-DP.1,SL4-DP.2,SR1-S.D.,SR1-Slp.(%),SR1-DP.1,SR1-DP.2,SR2-S.D.,SR2-Slp.(%),SR2-DP.1,SR2-DP.2,SR3-S.D.,SR3-Slp.(%),SR3-DP.1,SR3-DP.2,SR4-S.D.,SR4-Slp.(%),SR4-DP.1,SR4-DP.2,L TP flag,R TP flag
    /// Append header info.
    [data appendString:@"V7   Station,FORE,BACK,H.D.,S.D.,Slp.(%),LABEL-1,LABEL-2,X,Y,Z,TYPE,CRK,RP-AZ,RP-HD,GND1,CL.DP.1,GND2,CL.DP.2,GND3,Inst. H,Target H,"];
    // Side shots headers.
    // Left.
    for (int i = 1; i < 14; i++) {
        [data appendFormat:@"SL%d-S.D.,SL%d-Slp.", i, i];
        // Need to append these separately because of the %.
        [data appendString:@"(%),"];
        [data appendFormat:@"SL%d-DP.1,SL%d-DP.2,SL%d-Code,", i, i, i];
    }
    // Right.
    for (int i = 1; i < 14; i++) {
        [data appendFormat:@"SR%d-S.D.,SR%d-Slp.", i, i];
        // Need to append these separately because of the %.
        [data appendString:@"(%),"];
        [data appendFormat:@"SR%d-DP.1,SR%d-DP.2,SR%d-Code,", i, i, i];
    }
    [data appendString:@"L TP flag,R TP flag\n"];
    
    /// Go through each station and append the information.
    // Use reversed order as the examples we have show the lower numbers at the top and higher numbers at the bottom of the file (essentially the opposite way we store it).
    for (Station *station in [traverse.relStation reversedOrderedSet]) {
        // Station
        [data appendString:station.calcStation != nil ? [NSString stringWithFormat:@"%@,",station.calcStation] : @","];
        // FORE
        if (![station.stType isEqualToString:SHOT_TYPE_IFS]) {
            [data appendString:station.stForeAzimuth != nil ? [NSString stringWithFormat:@"%@,",[station.stForeAzimuth stringValue]] : @","];
        } else {
            [data appendString:station.calcForeAzimuth != nil ? [NSString stringWithFormat:@"%@,",[station.calcForeAzimuth stringValue]] : @","];
        }
        // BACK
        [data appendString:@","]; // We don't use this.
        // H.D.
        if (station.stHorizontalDistance != nil) {
            [data appendFormat:@"%@,",[station.stHorizontalDistance stringValue]];
        } else {
            [data appendString:station.calcHorizontalDistance != nil ? [NSString stringWithFormat:@"%@,",[station.calcHorizontalDistance stringValue]] : @","];
        }
        // S.D.
        if (station.stSlopeDistance != nil) {
            [data appendFormat:@"%@,",[station.stSlopeDistance stringValue]];
        } else {
            [data appendString:station.calcSlopeDistance != nil ? [NSString stringWithFormat:@"%@,",[station.calcSlopeDistance stringValue]] : @","];
        }
        // Slp.(%)
        [data appendString:station.stSlopePercentage != nil ? [NSString stringWithFormat:@"%@,",[station.stSlopePercentage stringValue]] : @","];
        // LABEL-1
        [data appendString:(station.stLabel != nil && station.stLabel.length > 0) ? [NSString stringWithFormat:@"%@,",station.stLabel] : @","];
        // LABEL-2
        [data appendString:@","]; // We don't use this.
        // X,Y,Z
        [data appendString:station.coEasting != nil ? [NSString stringWithFormat:@"%@,",[station.coEasting stringValue]] : @","];
        [data appendString:station.coNorthing != nil ? [NSString stringWithFormat:@"%@,",[station.coNorthing stringValue]] : @","];
        [data appendString:station.coElevation != nil ? [NSString stringWithFormat:@"%@,",[station.coElevation stringValue]] : @","];
        // TYPE
        [data appendFormat:@"%ld,", (long)[self typeFlagForStation:station]];
        // CRK. This one can be diameter or the width * height.
        if (station.stPipeDiameter != nil) {
            [data appendString:[NSString stringWithFormat:@"%@,",[station.stPipeDiameter stringValue]]];
        } else if(station.stBoxWidth != nil && station.stBoxHeight != nil) {
            [data appendString:[NSString stringWithFormat:@"%@x%@,", station.stBoxHeight, station.stBoxWidth]];
        } else {
            [data appendString:@","];
        }
        // RP-AZ
        [data appendString:@","]; // We don't use this.
        // RP-HD
        [data appendString:@","]; // We don't use this.
        /// Ground and depth info.
        // GND1
        [data appendString:(station.stGround1 != nil && station.stGround1.length > 0) ? [NSString stringWithFormat:@"%@,",station.stGround1] : @","];
        // CL.DP.1
        [data appendString:station.stDepth1 != nil ? [NSString stringWithFormat:@"%@,",[station.stDepth1 stringValue]] : @","];
        // GND2
        [data appendString:(station.stGround2 != nil && station.stGround2.length > 0) ? [NSString stringWithFormat:@"%@,",station.stGround2] : @","];
        // CL.DP.2
        [data appendString:station.stDepth2 != nil ? [NSString stringWithFormat:@"%@,",[station.stDepth2 stringValue]] : @","];
        // GND3
        [data appendString:(station.stGround3 != nil && station.stGround3.length > 0) ? [NSString stringWithFormat:@"%@,",station.stGround3] : @","];
        // Inst. H,
        [data appendString:@"0.000,"]; // We don't use this.
        // Target H
        [data appendString:@"0.000,"]; // We don't use this.
        
        NSString* slopeDistanceStr = nil;
        /// Side shots left.
        for (SideShot *leftShot in station.relLeftSidshots) {
            if (leftShot.shSlopeDistance != nil) {
                // If they've used horizontal as the distance mode then we need to convert the value.
                if (station.shDistanceMode == [NSNumber numberWithInt:HORIZONTAL] && leftShot.shSlopePercentage != nil) {
                    double conversion = ExportHDtoSD([leftShot.shSlopeDistance doubleValue], [leftShot.shSlopePercentage doubleValue]);
                    // Create a NSDecimalNumber, round it, and then set the placeholder text.
                    NSDecimalNumber *roundedDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:conversion] decimalValue]];
                    roundedDecimalNumber = [roundedDecimalNumber decimalNumberByRoundingAccordingToBehavior:decimalRoundingBehaviour];
                    slopeDistanceStr = [NSString stringWithFormat:@"%@,",[roundedDecimalNumber stringValue]];
                } else {
                    slopeDistanceStr = [NSString stringWithFormat:@"%@,",[leftShot.shSlopeDistance stringValue]];
                }
            } else {
                slopeDistanceStr = @",";
            }
            
            // SL#-S.D.
            [data appendString:slopeDistanceStr];
            // SL#-Slp.(%)
            [data appendString:leftShot.shSlopePercentage != nil ? [NSString stringWithFormat:@"%@,",[leftShot.shSlopePercentage stringValue]] : @","];
            [data appendString:@",,"]; // These two are for the SL#-DP.1, SL#-DP.1 values that we don't have.
            // Side Shot Code.
            [data appendString:(leftShot.shShotCode != nil && leftShot.shShotCode.length > 0) ? [NSString stringWithFormat:@"%@,",leftShot.shShotCode] : @","];
        }
        // Append these values indicating the end of the shots.
        [data appendString:@"-1,,,,,"];
        
        /// Side shots right.
        for (SideShot *rightShot in station.relRightSideshots) {
            if (rightShot.shSlopeDistance != nil) {
                // If they've used horizontal as the distance mode then we need to convert the value.
                if (station.shDistanceMode == [NSNumber numberWithInt:HORIZONTAL] && rightShot.shSlopePercentage != nil) {
                    double conversion = ExportHDtoSD([rightShot.shSlopeDistance doubleValue], [rightShot.shSlopePercentage doubleValue]);
                    // Create a NSDecimalNumber, round it, and then set the placeholder text.
                    NSDecimalNumber *roundedDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:conversion] decimalValue]];
                    roundedDecimalNumber = [roundedDecimalNumber decimalNumberByRoundingAccordingToBehavior:decimalRoundingBehaviour];
                    slopeDistanceStr = [NSString stringWithFormat:@"%@,",[roundedDecimalNumber stringValue]];
                } else {
                    slopeDistanceStr = [NSString stringWithFormat:@"%@,",[rightShot.shSlopeDistance stringValue]];
                }
            } else {
                slopeDistanceStr = @",";
            }
            
            // SL#-S.D.
            [data appendString:slopeDistanceStr];
            // SL#-Slp.(%)
            [data appendString:rightShot.shSlopePercentage != nil ? [NSString stringWithFormat:@"%@,",[rightShot.shSlopePercentage stringValue]] : @","];
            [data appendString:@",,"]; // These two are for the SR#-DP.1, SR#-DP.2 values that we don't have.
            // Side Shot Code.
            [data appendString:(rightShot.shShotCode != nil && rightShot.shShotCode.length > 0) ? [NSString stringWithFormat:@"%@,",rightShot.shShotCode] : @","];
        }
        // Append these values indicating the end of the shots.
        [data appendString:@"-1,,,,,"];
        
        // Append the turning point strings.
        [data appendFormat:@"%ld,", (long)[self bitwiseTurningPointFlagFromSideShots:station.relLeftSidshots]];
        [data appendFormat:@"%ld", (long)[self bitwiseTurningPointFlagFromSideShots:station.relRightSideshots]];
        [data appendString:@"\n"];
    }
    
    ExportResult* result = [[ExportResult alloc] init];
    result.exportedData = data;
    return result;
}

- (NSInteger)typeFlagForStation:(Station*)station {
    if (station == nil) {
        return 0;
    }
    
    // Default is 0.
    NSInteger flag = 0;
    
    // Add 3 if station is XY absolute.
    if (station.coEasting != nil || station.coNorthing != nil) {
        flag += 3;
    }
    // Add 4 if station is Z absolute.
    if (station.coNorthing != nil) {
        flag += 4;
    }
    // Add 8 if shot is an IFS.
    if ([station.stType isEqualToString:SHOT_TYPE_IFS]) {
        flag += 8;
    }
    // Add 512 if shot is a radial side shot.
    else if ([station.stType isEqualToString:SHOT_TYPE_RS]) {
        flag += 512;
    }
    // Add 16 if SD is used.
    if (station.stSlopeDistance != nil) {
        flag += 16;
    }
    
    return flag;
}

- (NSInteger)bitwiseTurningPointFlagFromSideShots:(NSOrderedSet*)sideShots {
    if (sideShots == nil || sideShots.count == 0) {
        return 0;
    }
    
    NSInteger bitwiseFlag = 0;
    SideShot* shot = nil;
    // Go through each shot and add a 1 to the appropriate bit index.
    for (int i = 0; i < sideShots.count && i < self.turningPointBitShiftValues.count; i++) {
        shot = [sideShots objectAtIndex:i];
        // Apply 1 to the index in the flag if it isn't a turning point.
        if (shot && [shot.shTurningPoint boolValue] == NO) {
            // Bitwise OR it.
            bitwiseFlag = bitwiseFlag | [self.turningPointBitShiftValues[i] integerValue];
        }
    }
    
    return bitwiseFlag;
}

@end
