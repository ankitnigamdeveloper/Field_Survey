//
//  TraverseStationCell.m
//  Field_Survey
//
//  Created by Martin on 2016/04/25.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "TraverseShotsCell.h"
#import "AppConstants.h"
#import "Utils.h"

@implementation TraverseShotsCell

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code        
        topStationIndex.text = @"";
        topStation.text = @"";
        botColumn3.text = @"";
        botColumn4.text = @"";
        botColumn5.text = @"";
        botColumn6.text = @"";
        botColumn7.text = @"";
    }
    return self;
}

- (void)configureWithData:(NSDictionary*)data {
    botStationIndex.text = [data valueForKey:CELL_KEY_STATION_INDEX];
    botStation.text = [data valueForKey:CELL_KEY_STATION];
    topColumn3.text = [data valueForKey:CELL_KEY_SHOT_TYPE];
    topColumn4.text = [data valueForKey:CELL_KEY_FOREAZIM];
    topColumn5.text = [data valueForKey:CELL_KEY_HORIZONTAL_DISTANCE];
    topColumn6.text = [data valueForKey:CELL_KEY_SLOPE_DISTANCE];
    topColumn7.text = [data valueForKey:CELL_KEY_SLOPE_PERCENTAGE];
    
    // Text colour.
    if ([[data valueForKey:CELL_KEY_SHOT_TYPE] isEqualToString:SHOT_TYPE_RS]) {
        topColumn3.textColor = [UIColor blueColor];
    } else if ([[data valueForKey:CELL_KEY_SHOT_TYPE] isEqualToString:SHOT_TYPE_IFS]) {
        topColumn3.textColor = [UIColor redColor];
    } else {
        topColumn3.textColor = [Utils darkGreen];
    }
    
    if ([[data valueForKey:CELL_KEY_PREVIOUS_CELL_SHOT_TYPE] isEqualToString:SHOT_TYPE_RS]) {
        botStation.textColor = [UIColor blueColor];
    } else if ([[data valueForKey:CELL_KEY_PREVIOUS_CELL_SHOT_TYPE] isEqualToString:SHOT_TYPE_IFS]) {
        botStation.textColor = [UIColor redColor];
    } else {
        botStation.textColor = [Utils darkGreen];
    }
    
    if ([[data valueForKey:CELL_KEY_STATION_IS_INVALID] boolValue] == NO) {
        botStationIndex.backgroundColor = [UIColor whiteColor];
        botStationIndex.textColor = [Utils darkGreen];
        topStationIndex.backgroundColor = [Utils lightGrey];
    } else {
        botStationIndex.textColor = [UIColor whiteColor];
        botStationIndex.backgroundColor = [Utils orange];
        topStationIndex.backgroundColor = [Utils orange];
    }
    
    // Background colour.
    if (botStation.text.length > 0) {
        botStation.backgroundColor = [UIColor whiteColor];
    } else {
        botStation.backgroundColor = [Utils lightGrey];
    }
    
    if (topColumn3.text.length > 0) {
        topColumn3.backgroundColor = [UIColor whiteColor];
    } else {
        topColumn3.backgroundColor = [Utils lightGrey];
    }
    
    if (topColumn4.text.length > 0) {
        topColumn4.backgroundColor = [UIColor whiteColor];
    } else {
        topColumn4.backgroundColor = [Utils lightGrey];
    }
    
    if (topColumn5.text.length > 0) {
        topColumn5.backgroundColor = [UIColor whiteColor];
    } else {
        topColumn5.backgroundColor = [Utils lightGrey];
    }
    
    if (topColumn6.text.length > 0) {
        topColumn6.backgroundColor = [UIColor whiteColor];
    } else {
        topColumn6.backgroundColor = [Utils lightGrey];
    }
    
    if (topColumn7.text.length > 0) {
        topColumn7.backgroundColor = [UIColor whiteColor];
    } else {
        topColumn7.backgroundColor = [Utils lightGrey];
    }
}

@end
