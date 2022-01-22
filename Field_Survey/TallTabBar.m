//
//  TallTabBar.m
//  Field_Survey
//
//  Created by Martin on 2016/04/28.
//  Copyright © 2016 Bawtree Software. All rights reserved.
//

#import "TallTabBar.h"

@implementation TallTabBar

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = 80;
    
    return sizeThatFits;
}

@end