//
//  TabbarViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabbarViewController : UIViewController <UINavigationBarDelegate> {
}

- (IBAction)pressedInsert:(id)sender;
- (void)disableTab:(NSInteger)tab;
- (void)enableTab:(NSInteger)tab;
- (void)updateInsertText;

@end

