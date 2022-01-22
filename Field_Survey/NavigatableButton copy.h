//
//  NavigatableButton.h
//  Field_Survey
//
//  Created by Martin on 2016/04/28.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol NavigatableButtonDelegate <NSObject>
- (void)goToPreviousFrom:(NSInteger)elementTag;
@end

@interface NavigatableButton : UIButton <UIKeyInput>{
}

@property (nonatomic, strong) id<NavigatableButtonDelegate> delegate;

@end