//
//  Traverse+CoreDataProperties.h
//  
//
//  Created by Martin on 6/24/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Traverse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Traverse (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *trCreated;
@property (nullable, nonatomic, retain) NSString *trCrew;
@property (nullable, nonatomic, retain) NSString *trDescription;
@property (nullable, nonatomic, retain) NSDate *trLastModified;
@property (nullable, nonatomic, retain) NSString *trName;
@property (nullable, nonatomic, retain) NSString *trStartIndex;
@property (nullable, nonatomic, retain) NSDecimalNumber *trStation;
@property (nullable, nonatomic, retain) NSOrderedSet<Station *> *relStation;

@end

@interface Traverse (CoreDataGeneratedAccessors)

- (void)insertObject:(Station *)value inRelStationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelStationAtIndex:(NSUInteger)idx;
- (void)insertRelStation:(NSArray<Station *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRelStationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRelStationAtIndex:(NSUInteger)idx withObject:(Station *)value;
- (void)replaceRelStationAtIndexes:(NSIndexSet *)indexes withRelStation:(NSArray<Station *> *)values;
- (void)addRelStationObject:(Station *)value;
- (void)removeRelStationObject:(Station *)value;
- (void)addRelStation:(NSOrderedSet<Station *> *)values;
- (void)removeRelStation:(NSOrderedSet<Station *> *)values;

@end

NS_ASSUME_NONNULL_END
