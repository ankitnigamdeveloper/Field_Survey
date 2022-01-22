//
//  TraverseStationCell.h
//  Field_Survey
//
//  Created by Martin on 2016/04/25.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

@import UIKit;

@protocol TraverseShotsCellDelegate <NSObject>
@end

@interface TraverseShotsCell : UITableViewCell {
    IBOutlet UILabel* topStationIndex;
    IBOutlet UILabel* topStation;
    IBOutlet UILabel* topColumn3;
    IBOutlet UILabel* topColumn4;
    IBOutlet UILabel* topColumn5;
    IBOutlet UILabel* topColumn6;
    IBOutlet UILabel* topColumn7;
    
    IBOutlet UILabel* botStationIndex;
    IBOutlet UILabel* botStation;
    IBOutlet UILabel* botColumn3;
    IBOutlet UILabel* botColumn4;
    IBOutlet UILabel* botColumn5;
    IBOutlet UILabel* botColumn6;
    IBOutlet UILabel* botColumn7;
}

@property (nonatomic, strong) id<TraverseShotsCellDelegate> delegate;

- (void)configureWithData:(NSDictionary*)data;

@end

