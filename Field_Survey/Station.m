//
//  Station.m
//  
//
//  Created by Martin on 6/13/16.
//
//

#import "Station.h"
#import "SideShot.h"
#import "Traverse.h"
#import "StationDefaults.h"

@implementation Station

// Insert code here to add functionality to your managed object subclass
- (void)enforceDefaultCoordinateValues {
    if (self.coEasting == nil) {
        self.coEasting = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    if (self.coNorthing == nil) {
        self.coNorthing = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    if (self.coElevation == nil) {
        self.coElevation = [NSDecimalNumber decimalNumberWithString:@"100"];
    }
}

@end
