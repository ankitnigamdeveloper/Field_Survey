//
//  ExportResult.m
//  Field_Survey
//
//  Created by Martin on 2016/06/29.
//

#import "ExportResult.h"

@implementation ExportResult

- (id) init {
    if (self = [super init]) {
        self.exportedData = @"";
        self.exportedMessage = @"";
    }
    return self;
}

@end