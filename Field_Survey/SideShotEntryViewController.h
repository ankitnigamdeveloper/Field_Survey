//
//  SideShotEntryViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideShotCollectionCell.h"
#import "TabbarViewController.h"
#import "NavigatableButton.h"
#import "StationDefaultValuesViewController.h"

@interface SideShotEntryViewController : TabbarViewController <UICollectionViewDelegate, UICollectionViewDataSource, SideShotCollectionCellDelegate> {
    IBOutlet UIButton *nextBtn;
    IBOutlet UIButton *previousBtn;
    IBOutlet UICollectionView* leftSideShotsCollectionView;
    IBOutlet UICollectionView* rightSideShotsCollectionView;
    IBOutlet NavigatableButton* modeSlopeDistance;
    IBOutlet NavigatableButton* modeHorizontalDistance;
    IBOutlet UILabel* leftShotsSelectedMode1;
    IBOutlet UILabel* rightShotsSelectedMode2;
    IBOutlet UILabel *currentStationInfo;
}

@end
