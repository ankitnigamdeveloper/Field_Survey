//
//  SideShotCollectionCell.h
//  Field_Survey
//
//  Created by Martin on 2016/04/25.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

@import UIKit;
#import "NavigatableButton.h"
#import "SideShot.h"

// Need to forward declare class so we can use a pointer to an object of its type in the protocol.
@class SideShotCollectionCell;

@protocol SideShotCollectionCellDelegate <NSObject>
- (void)goToNextCell:(SideShotCollectionCell*)currentCell;
- (void)goToPreviousCell:(SideShotCollectionCell*)currentCell;
- (void)keyboardWillShow:(NSNotification *)notification onCollectionView:(UICollectionView*)view;
- (void)keyboardWillHideOnCollectionView:(UICollectionView*)view;
- (void)shouldUpdateSideShotDataWith:(NSDictionary*)updateInfo;
@end

@interface SideShotCollectionCell : UICollectionViewCell <UITextFieldDelegate, NavigatableButtonDelegate> {
    IBOutlet UILabel* title;
    IBOutlet UITextField* slpPercentage;
    IBOutlet UITextField* slpDistance;
    IBOutlet UITextField* sideShotCode;
    IBOutlet UIButton* turningPoint;
}

- (IBAction)pressedTurningPoint:(UIButton*)button;
- (void)configureWithData:(NSDictionary*)data forSideShot:(SideShot*)sideshot;
- (void)cellGainedFocusWithTag:(NSInteger)tag;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)saveDataAndUpdateSource:(BOOL)update;
- (void)clearSideShot;
- (void)stopListeningForEvents;

@property (nonatomic) NSInteger currentSelectedElementTag;
@property (nonatomic) NSInteger currentCellIndex;
@property (nonatomic, strong) id<SideShotCollectionCellDelegate> delegate;
@property (nonatomic, weak) UICollectionView* currentCollectionView;

@end
