//
//  WorkingViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/06/16.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WorkingViewControllerDelegate <NSObject>
- (void)pressedCancel;
@end

@interface WorkingViewController : UIViewController {
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel* taskDescription;
    IBOutlet UIButton* cancelButton;
}

@property (nonatomic, strong) id<WorkingViewControllerDelegate> delegate;
@property (nonatomic) NSString* taskText;
@property (nonatomic) BOOL cancelButtonIsHidden;

@end
