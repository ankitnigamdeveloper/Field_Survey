//
//  StationDefaults+CoreDataProperties.h
//  
//
//  Created by Martin on 6/30/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StationDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface StationDefaults (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDecimalNumber *stHorizontalDistance;
@property (nullable, nonatomic, retain) NSDecimalNumber *stSlopeDistance;
@property (nullable, nonatomic, retain) NSDecimalNumber *stSlopePercentage;
@property (nullable, nonatomic, retain) NSString *stType;
@property (nullable, nonatomic, retain) NSDecimalNumber *stForeAzimuth;
@property (nullable, nonatomic, retain) Station *relStation;

@end

NS_ASSUME_NONNULL_END
