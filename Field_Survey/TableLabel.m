//
//  TableLabel.m
//  Field_Survey
//
//  Created by Martin on 2016/04/28.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import "TableLabel.h"

@implementation TableLabel

// Subclassed so we can set the padding.
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 5, 0, 5};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end