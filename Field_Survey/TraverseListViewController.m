//
//  TraverseListViewController.m
//  Field_Survey
//
//  Created by Martin on 2016/03/31.
//  Copyright © 2016 BawtreeSoftware. All rights reserved.
//

#import "TraverseListViewController.h"
#import "TraverseListCell.h"
#import "AppConstants.h"
#import "Traverse.h"
#import "ActiveRecord.h"
#import "NewTraverseViewController.h"
#import "DataController.h"
#import "FCFileManager.h"
#import "WorkingViewController.h"
#import "ExportResult.h"
#import "LicenseBackgroundSyncController.h"

@interface TraverseListViewController ()<TraverseListCellDelegate>
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic) NSDateFormatter *formatter;
@property (nonatomic) Traverse *lastSelectedTraverse;
@property (nonatomic) WorkingViewController* workingViewController;
@end

@implementation TraverseListViewController

# pragma mark - initialization.

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dataSource = [Traverse ordered:@"!trLastModified"];
    [traverseTable reloadData];
    
    if ([[LicenseBackgroundSyncController sharedInstance] shouldReturnToLogin] == YES) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *view = (UIViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_login"];
        [self presentViewController:view animated:YES completion:nil];
    }
}

# pragma mark - UITableView & data source.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TraverseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TraverseListCell"];
    if (cell == nil) {
        cell = [[TraverseListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"TraverseListCell"];
    }
    cell.indexPath = indexPath;
    if (!cell.accessoryView) {
        UIImageView *tmp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
        cell.accessoryView = tmp;
    }
    cell.delegate = self;
    
    // Get the coordinate data.
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    Traverse *traverse = self.dataSource[indexPath.row];
    if (traverse.relStation) {
        Station *station = [traverse.relStation lastObject];
        [dict setValue:station.coEasting forKey:CELL_KEY_EASTING];
        [dict setValue:station.coNorthing forKey:CELL_KEY_NORTHING];
        [dict setValue:station.coElevation forKey:CELL_KEY_ELEVATION];
    }
    [cell configureCellWithData:dict forTraverse:traverse];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do this so we reset the styling.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Update the data controller to know which traverse we're working with.
    [[DataController sharedInstance] setCurrentTraverse:self.dataSource[indexPath.row]];
    // Update our validity flag.
    [[DataController sharedInstance] recheckValidityOfAllStations];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Display an alertview prompting the user to delete a traverse.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"trav_list_delete_traverse", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yes = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_yes", nil) style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                        [tableView setEditing:NO];
                                                        
                                                        // Delete the row from the data source
                                                        Traverse *traverseToDelete = self.dataSource[indexPath.row];
                                                        [traverseToDelete delete];
                                                        [Traverse commit];
                                                        
                                                        // Update the datasource and and remove the cell from the tableview.
                                                        self.dataSource = [Traverse ordered:@"!trLastModified"];
                                                        [traverseTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
                                                    }];
        
        UIAlertAction* no = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_no", nil) style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                       [tableView setEditing:NO];
                                                   }];
        
        [alert addAction:yes];
        [alert addAction:no];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

# pragma mark - Segue functions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"new_traverse_screen"]) {
        if (self.lastSelectedTraverse) {
            // We're editing a the traverse's information.
            // Pass the selected traverse so we know which data to display.
            ((NewTraverseViewController*) segue.destinationViewController).selectedTraverse = self.lastSelectedTraverse;
            // Set the last selected one to nil so the logic is reset.
            self.lastSelectedTraverse = nil;
        }
    }
}

# pragma mark - TraverseListCellDelegate functions.

- (void)pressedInfoOn:(NSIndexPath*)indexPath {
    self.lastSelectedTraverse = self.dataSource[indexPath.row];
    [self performSegueWithIdentifier:@"new_traverse_screen" sender:self];
}

- (void)pressedExportOn:(NSIndexPath*)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"trav_list_export_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* email = [UIAlertAction actionWithTitle:NSLocalizedString(@"trav_list_export_email", nil) style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [alert dismissViewControllerAnimated:NO completion:nil];
                                                    // Present the working view and export the data.
                                                    [self displayWorkingViewOnCompletion: ^void(void){
                                                        [self exportTraverse:indexPath forOption:EMAIL];
                                                    }];
                                                }];
    
    UIAlertAction* itunes = [UIAlertAction actionWithTitle:NSLocalizedString(@"trav_list_export_itunes", nil) style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [alert dismissViewControllerAnimated:NO completion:nil];
                                                    // Present the working view and export the data.
                                                    [self displayWorkingViewOnCompletion: ^void(void){
                                                        [self exportTraverse:indexPath forOption:ITUNES];
                                                    }];
                                                }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"general_cancel", nil) style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                       // Do nothing.
                                                }];
    
    [alert addAction:email];
    [alert addAction:itunes];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)exportTraverse:(NSIndexPath*)indexPath forOption:(ExportOption)option {
    // Get the data.
    Traverse *traverse = self.dataSource[indexPath.row];
    ExportResult* result = [[DataController sharedInstance] exportDataFromTraverse:traverse];
    
    // Save the data to a file.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:TRAVERSE_EXPORT_DATE_FORMAT];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.ipd", [traverse.trName stringByReplacingOccurrencesOfString:@" " withString:@"_"], [formatter stringFromDate:[NSDate date]]];
    // Delete the file if it already exists.
    [FCFileManager removeItemAtPath:fileName];
    // Now create it again.
    [FCFileManager createFileAtPath:fileName withContent:result.exportedData];
    
    // If its email then present the email composer.
    if (option == EMAIL) {
        MFMailComposeViewController *emailComposer = [[MFMailComposeViewController alloc] init];
        emailComposer.mailComposeDelegate = self;
        [emailComposer setSubject:[NSString stringWithFormat:NSLocalizedString(@"trav_list_export_email_subject", nil), traverse.trName]];
        [emailComposer setMessageBody:@"" isHTML:NO];
        
        /// Add the file.
        // The file, if we don't specify the directory at creation time, is located in the documents directory.
        NSString *filePath = [FCFileManager pathForDocumentsDirectoryWithPath:fileName];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        [emailComposer addAttachmentData:fileData mimeType:@"ipd" fileName:fileName];
        
        // Dismiss the overlay.
        [self dismissWorkingViewOnCompletion:^void(void){
            if ([MFMailComposeViewController canSendMail]) {
                // Present mail view controller on screen after we've dismissed the overlay.
                [self presentViewController:emailComposer animated:YES completion:NULL];
            }
        }];
    } else if (option == ITUNES) {
        // Dismiss the overlay.
        [self dismissWorkingViewOnCompletion:nil];
        // TODO some sort of sync explanation?
    } else {
        // We shouldn't really reach this point, but dismiss the overlay at this point.
        [self dismissWorkingViewOnCompletion:nil];
    }
}

# pragma mark - Working view functions.

- (void)displayWorkingViewOnCompletion:(void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Initialize the workingViewController if it doesn't exist.
        if (self.workingViewController == nil) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            self.workingViewController = (WorkingViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"vc_working"];
            self.workingViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.workingViewController.cancelButtonIsHidden = YES;
            self.workingViewController.taskText = NSLocalizedString(@"working_exporting_data", nil);
        }
        [self presentViewController:self.workingViewController animated:NO completion:block];
    });
}

- (void)dismissWorkingViewOnCompletion:(void (^)(void))block {
    if (self.workingViewController != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.workingViewController dismissViewControllerAnimated:YES completion:block];
        });
    }
}

# pragma mark - MFMailComposeViewControllerDelegate functions.

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // Do something with the result.
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
}

@end
