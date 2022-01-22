//
//  NavigatableButton.m
//  Field_Survey
//
//  Created by Martin on 2016/04/28.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import "NavigatableButton.h"

@implementation NavigatableButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This works but I'm not certain what sort of performance impact it will have.
        UIBarButtonItem* itemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(goToPreviousFromSelf)];
        UIBarButtonItemGroup* group = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[itemBack] representativeItem:nil];
        
        UITextInputAssistantItem* item = [self inputAssistantItem];
        item.trailingBarButtonGroups = @[group];
    }
    return self;
}

// Subclassed so we can set the padding.
- (BOOL)canBecomeFirstResponder {
    return self.enabled;
}

- (void)insertText:(NSString *)text {
    // Check they hit the return key. If they did, we go to the next field.
    if ([text isEqualToString:@"\n"]) {
        [self goToNextFrom:self.tag];
    }
    // Check if they hit space. If they have, then change the selected state.
    else if ([text isEqualToString:@" "]) {
        self.selected = !self.selected;
    }
}

- (void)deleteBackward {
    // TODO
}

- (BOOL)hasText {
    return YES;
}

- (void)goToPreviousFromSelf {
    [self goToPreviousFrom:self.tag];
}

- (void)goToNextFrom:(NSInteger)elementTag {
    [self.delegate goToNextFrom:elementTag];
}

- (void)goToPreviousFrom:(NSInteger)elementTag {
    [self.delegate goToPreviousFrom:elementTag];
}

@end
