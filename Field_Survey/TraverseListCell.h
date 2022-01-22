//
//  TraverseListCell.h
//  Field_Survey
//
//  Created by Martin on 2016/04/25.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "Traverse.h"

@import UIKit;

@protocol TraverseListCellDelegate <NSObject>
- (void)pressedInfoOn:(NSIndexPath*)indexPath;
- (void)pressedExportOn:(NSIndexPath*)indexPath;
@end

@interface TraverseListCell : UITableViewCell {
    IBOutlet UILabel* title;
    IBOutlet UILabel* dateCreated;
    IBOutlet UILabel* description;
    IBOutlet UILabel* startingCoordinates;
}

- (IBAction)pressedInfo:(UIButton*)button;
- (IBAction)pressedExport:(UIButton*)button;

- (void)configureCellWithData:(NSDictionary*)data forTraverse:(Traverse*)traverse;

@property (nonatomic, strong) id<TraverseListCellDelegate> delegate;
@property (nonatomic) NSIndexPath* indexPath;

@end

