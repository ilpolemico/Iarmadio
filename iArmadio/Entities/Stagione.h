//
//  Stagione.h
//  iArmadio
//
//  Created by Casa Fortunato on 03/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Combinazione, Vestito;

@interface Stagione : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * date_from;
@property (nonatomic, retain) NSString * date_to;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * stagione;
@property (nonatomic, retain) NSNumber * temp_max;
@property (nonatomic, retain) NSNumber * temp_min;
@property (nonatomic, retain) Combinazione *combinazione;
@property (nonatomic, retain) NSSet *vestito;
@end

@interface Stagione (CoreDataGeneratedAccessors)

- (void)addVestitoObject:(Vestito *)value;
- (void)removeVestitoObject:(Vestito *)value;
- (void)addVestito:(NSSet *)values;
- (void)removeVestito:(NSSet *)values;

@end
