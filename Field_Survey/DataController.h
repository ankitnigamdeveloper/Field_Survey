//
//  DataController.h
//  Field_Survey
//
//  Created by Martin on 2016/06/15.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import "Traverse.h"
#import "Station.h"
#import "SideShot.h"
#import "StationDefaults.h"
#import "ExportResult.h"
#import <UIKit/UIKit.h>

@interface DataController : NSObject {
}

@property (atomic, weak) Traverse *currentTraverse;
@property (atomic, weak) Station *currentStation;
@property (nonatomic) BOOL shouldRecalculateIndexValues;
@property (nonatomic) BOOL shouldRecalculateStationValues;
@property (nonatomic) BOOL shouldRecalculateForeAzimuthValues;
@property (nonatomic) BOOL shouldEnforceDefaultCoordinateValuesOnFirstStation;
@property (nonatomic) NSInteger invalidStationIndex;
@property (nonatomic) NSString* dataErrorMessage;

+ (id)sharedInstance;
- (BOOL)allStationsValid;
- (BOOL)isFirstStation;
- (BOOL)isLastStation;
- (Station*)currentInvalidStation;
- (Station*)createNewStation;
- (Station*)insertNewStationAtIndex:(NSInteger)index;
- (Station*)nextStation;
- (Station*)previousStation;
- (NSString*)stationValuesValid:(Station*)station;
- (void)updateAllCalculatedFieldsAsNeeded;
- (void)updateCalculatedFieldsAsNeededFromStation:(Station*)station;
- (void)recheckValidityOfAllStations;
- (void)recheckValidityOfCurrentInvalidStation;
- (ExportResult*)exportDataFromTraverse:(Traverse*)traverse;
- (BOOL)allowAccessToCoordinatesAndSideShotsForStationAt:(NSInteger)index;
- (BOOL)allowAccessToCoordinatesAndSideShotsForStation:(Station*)station;

@end