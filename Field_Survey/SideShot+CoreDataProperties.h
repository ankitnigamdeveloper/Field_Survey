//
//  SideShot+CoreDataProperties.h
//  
//
//  Created by Martin on 6/24/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SideShot.h"

NS_ASSUME_NONNULL_BEGIN

@interface SideShot (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *shShotCode;
@property (nullable, nonatomic, retain) NSDecimalNumber *shSlopeDistance;
@property (nullable, nonatomic, retain) NSDecimalNumber *shSlopePercentage;
@property (nullable, nonatomic, retain) NSNumber *shTurningPoint;
@property (nullable, nonatomic, retain) Station *relStationLeftshots;
@property (nullable, nonatomic, retain) Station *relStationRightshots;

@end

NS_ASSUME_NONNULL_END
