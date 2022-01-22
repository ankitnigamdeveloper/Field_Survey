//
//  TraverseListViewController.h
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Traverse.h"
#import "TraverseListCell.h"
#import <MessageUI/MessageUI.h>

@interface TraverseListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, TraverseListCellDelegate> {
    IBOutlet UITableView* traverseTable;
}

@end

