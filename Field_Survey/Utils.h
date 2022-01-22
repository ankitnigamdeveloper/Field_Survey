//
//  Utils.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <math.h>

/*************************************************************
  These macros are taken from the Utils.h softree provided us.
  Parameters:  
    HD	horz distance
    SD	slope distance
    s	slope in % = tan*100
 *************************************************************/
#define HDtoSD(HD,s) (HD*(double)sqrt(1.0 + s*s/10000.0))
#define SDtoHD(SD,s) (SD/(double)sqrt(1.0 + s*s/10000.0))
#define SDtoVD(SD,s) (SD/(double)sqrt(1.0 + 10000.0/(s*s)))
#define VDtoSD(VD,s) (VD*(double)sqrt(1.0 + 10000.0/(s*s)))

// This one is ours:
//   HD horizontal distance
//   s  slope %.
#define ExportHDtoSD(HD,s) (HD/cos(atan(s/100.0)))

@interface Utils : NSObject 

+ (UIColor*)darkGreen;
+ (UIColor*)lighterGreen;
+ (UIColor*)lightGrey;
+ (UIColor*)darkishGrey;
+ (UIColor*)orange;
+ (BOOL)string:(NSString*)str passesRegex:(NSString*)regex;
+ (void)displayAlertWithMessage:(NSString*)message onView:(UIViewController*)viewController onOk:(void (^)(void))block;
+ (BOOL)currentSubscriptionValid;
+ (UIViewController *)vcOfClass:(Class)class existsInNavigationController:(UINavigationController*)navigationController;

@end