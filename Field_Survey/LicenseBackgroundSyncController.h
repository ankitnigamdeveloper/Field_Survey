//
//  LicenseBackgroundSyncController.h
//  Field_Survey
//
//  Created by Martin on 2016/07/22.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LicenseBackgroundSyncController : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate> {
}

@property (nonatomic) BOOL shouldReturnToLogin;
@property (nonatomic) NSString* messageToDisplayAtLogin;

+ (id)sharedInstance;
- (void)syncLicenseInBackgroundIfNeededKickoutIfExpired:(BOOL)kickout;
- (void)syncLicenseInBackgroundKickoutIfExpired:(BOOL)kickout;

@end