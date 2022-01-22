//
//  TraverseListCell.m
//  Field_Survey
//
//  Created by Martin on 2016/04/25.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "TraverseListCell.h"
#import "AppConstants.h"

@implementation TraverseListCell

# pragma mark - initialization.

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    title.text = @"Traverse 001";
    dateCreated.text = @"2016/04/25";
    description.text = @"This is a very detailed and sublime description label.";
    startingCoordinates.text = @"23.1324234123413, -50.13432432234, 0.13211123412";
    self.accessoryView.frame = CGRectMake(0, 0, 30, 30);
}

- (void)configureCellWithData:(NSDictionary*)data forTraverse:(Traverse*)traverse {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:CREATION_DATE_FORMAT];
    
    title.text = traverse.trName;
    dateCreated.text = [formatter stringFromDate:[traverse trCreated]];
    description.text = traverse.trDescription;
    if ([data valueForKey:CELL_KEY_EASTING] && [data valueForKey:CELL_KEY_NORTHING] && [data valueForKey:CELL_KEY_ELEVATION]) {
        startingCoordinates.text = [NSString stringWithFormat:@"%@, %@, %@", [data valueForKey:CELL_KEY_EASTING], [data valueForKey:CELL_KEY_NORTHING], [data valueForKey:CELL_KEY_ELEVATION]];
    } else {
        startingCoordinates.text = @"";
    }
}

# pragma mark - button presses.

- (IBAction)pressedInfo:(UIButton*)button {
    [self pressedInfoOn:self.indexPath];
}

- (IBAction)pressedExport:(UIButton*)button {
    [self pressedExportOn:self.indexPath];
}

# pragma mark - TraverseListCellDelegate functions.

- (void)pressedInfoOn:(NSIndexPath*)indexPath {
    [self.delegate pressedInfoOn:indexPath];
}

- (void)pressedExportOn:(NSIndexPath*)indexPath {
    [self.delegate pressedExportOn:indexPath];
}

@end
