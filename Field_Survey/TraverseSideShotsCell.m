//
//  TraverseSideShotsCell.m
//  Field_Survey
//
//  Created by Martin on 2016/04/25.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "TraverseSideShotsCell.h"
#import "AppConstants.h"
#import "Utils.h"

@implementation TraverseSideShotsCell

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        topStationIndex.text = @"";
        topStation.text = @"";
        topColumn3.text = @"";
        topColumn4.text = @"";
        topColumn5.text = @"";
        topColumn6.text = @"";
        topColumn7.text = @"";
    }
    return self;
}

- (void)configureWithData:(NSDictionary*)data {
    botStationIndex.text = [data valueForKey:CELL_KEY_STATION_INDEX];
    botStation.text = [data valueForKey:CELL_KEY_STATION];
    botColumn3.text = [data valueForKey:CELL_KEY_SSL];
    botColumn4.text = [data valueForKey:CELL_KEY_SSR];
    botColumn5.text = [data valueForKey:CELL_KEY_GROUND];
    botColumn6.text = [data valueForKey:CELL_KEY_CREEK];
    botColumn7.text = [data valueForKey:CELL_KEY_LABEL];
    
    // Text colour.
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
    
    if (botColumn3.text.length > 0) {
        botColumn3.backgroundColor = [UIColor whiteColor];
    } else {
        botColumn3.backgroundColor = [Utils lightGrey];
    }
    
    if (botColumn4.text.length > 0) {
        botColumn4.backgroundColor = [UIColor whiteColor];
    } else {
        botColumn4.backgroundColor = [Utils lightGrey];
    }
    
    if (botColumn5.text.length > 0) {
        botColumn5.backgroundColor = [UIColor whiteColor];
    } else {
        botColumn5.backgroundColor = [Utils lightGrey];
    }
    
    if (botColumn6.text.length > 0) {
        botColumn6.backgroundColor = [UIColor whiteColor];
    } else {
        botColumn6.backgroundColor = [Utils lightGrey];
    }
    
    if (botColumn7.text.length > 0) {
        botColumn7.backgroundColor = [UIColor whiteColor];
    } else {
        botColumn7.backgroundColor = [Utils lightGrey];
    }
}

@end
