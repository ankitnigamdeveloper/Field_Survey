//
//  Station.h
//  
//
//  Created by Martin on 6/13/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SideShot, Traverse, StationDefaults;

NS_ASSUME_NONNULL_BEGIN

@interface Station : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)enforceDefaultCoordinateValues;

@end

NS_ASSUME_NONNULL_END

#import "Station+CoreDataProperties.h"
