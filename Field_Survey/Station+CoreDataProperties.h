//
//  Station+CoreDataProperties.h
//  
//
//  Created by Martin on 6/30/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Station.h"

NS_ASSUME_NONNULL_BEGIN

@interface Station (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDecimalNumber *calcHorizontalDistance;
@property (nullable, nonatomic, retain) NSDecimalNumber *calcSlopeDistance;
@property (nullable, nonatomic, retain) NSString *calcSsl;
@property (nullable, nonatomic, retain) NSString *calcSsr;
@property (nullable, nonatomic, retain) NSString *calcStation;
@property (nullable, nonatomic, retain) NSString *calcStationIndex;
@property (nullable, nonatomic, retain) NSDecimalNumber *coEasting;
@property (nullable, nonatomic, retain) NSDecimalNumber *coElevation;
@property (nullable, nonatomic, retain) NSDecimalNumber *coNorthing;
@property (nullable, nonatomic, retain) NSNumber *shDistanceMode;
@property (nullable, nonatomic, retain) NSNumber *stBoxHeight;
@property (nullable, nonatomic, retain) NSNumber *stBoxWidth;
@property (nullable, nonatomic, retain) NSDecimalNumber *stDepth1;
@property (nullable, nonatomic, retain) NSDecimalNumber *stDepth2;
@property (nullable, nonatomic, retain) NSDecimalNumber *stDepth3;
@property (nullable, nonatomic, retain) NSDecimalNumber *stForeAzimuth;
@property (nullable, nonatomic, retain) NSString *stGround1;
@property (nullable, nonatomic, retain) NSString *stGround2;
@property (nullable, nonatomic, retain) NSString *stGround3;
@property (nullable, nonatomic, retain) NSDecimalNumber *stHorizontalDistance;
@property (nullable, nonatomic, retain) NSString *stLabel;
@property (nullable, nonatomic, retain) NSNumber *stPipeDiameter;
@property (nullable, nonatomic, retain) NSDecimalNumber *stSlopeDistance;
@property (nullable, nonatomic, retain) NSDecimalNumber *stSlopePercentage;
@property (nullable, nonatomic, retain) NSString *stType;
@property (nullable, nonatomic, retain) NSDecimalNumber *calcForeAzimuth;
@property (nullable, nonatomic, retain) StationDefaults *relDefaults;
@property (nullable, nonatomic, retain) NSOrderedSet<SideShot *> *relLeftSidshots;
@property (nullable, nonatomic, retain) NSOrderedSet<SideShot *> *relRightSideshots;
@property (nullable, nonatomic, retain) Traverse *relTraverse;

@end

@interface Station (CoreDataGeneratedAccessors)

- (void)insertObject:(SideShot *)value inRelLeftSidshotsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelLeftSidshotsAtIndex:(NSUInteger)idx;
- (void)insertRelLeftSidshots:(NSArray<SideShot *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRelLeftSidshotsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRelLeftSidshotsAtIndex:(NSUInteger)idx withObject:(SideShot *)value;
- (void)replaceRelLeftSidshotsAtIndexes:(NSIndexSet *)indexes withRelLeftSidshots:(NSArray<SideShot *> *)values;
- (void)addRelLeftSidshotsObject:(SideShot *)value;
- (void)removeRelLeftSidshotsObject:(SideShot *)value;
- (void)addRelLeftSidshots:(NSOrderedSet<SideShot *> *)values;
- (void)removeRelLeftSidshots:(NSOrderedSet<SideShot *> *)values;

- (void)insertObject:(SideShot *)value inRelRightSideshotsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelRightSideshotsAtIndex:(NSUInteger)idx;
- (void)insertRelRightSideshots:(NSArray<SideShot *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRelRightSideshotsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRelRightSideshotsAtIndex:(NSUInteger)idx withObject:(SideShot *)value;
- (void)replaceRelRightSideshotsAtIndexes:(NSIndexSet *)indexes withRelRightSideshots:(NSArray<SideShot *> *)values;
- (void)addRelRightSideshotsObject:(SideShot *)value;
- (void)removeRelRightSideshotsObject:(SideShot *)value;
- (void)addRelRightSideshots:(NSOrderedSet<SideShot *> *)values;
- (void)removeRelRightSideshots:(NSOrderedSet<SideShot *> *)values;

@end

NS_ASSUME_NONNULL_END
