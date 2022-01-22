//
//  TabbarViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/06/08.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShotTypeSelectionDelegate <NSObject>
- (void)selectedType:(NSString*)type;
@end

@interface ShotTypeSelectionViewController : UIViewController {
    IBOutlet UIButton* fsBtn;
    IBOutlet UIButton* rsBtn;
    IBOutlet UIButton* ifsBtn;
    UIButton* currentSelectedButton;
}
@property (nonatomic, strong) id<ShotTypeSelectionDelegate> delegate;
@property (nonatomic) NSString* currentSelectedValue;

@end

