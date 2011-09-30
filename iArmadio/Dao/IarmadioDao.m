//
//  iarmadioDao.m
//  captureCloth
//
//  Created by luke on 06/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IarmadioDao.h"




@implementation IarmadioDao

static IarmadioDao *singleton;


+ (IarmadioDao *)shared{
    if(singleton == nil){
        singleton = [[IarmadioDao alloc] initDao];
    }
    return singleton;
}

- (IarmadioDao*)initDao{
    srand(time(NULL));
    singleton = self;
    return self;
}


- (UIImage *)getImageFromVestito:(Vestito *)vestitoEntity{
    return [self getImageFromFile:vestitoEntity.immagine];
}


- (UIImage *)getImageFromFile:(NSString *)file{
    NSString *filename = [self filePathDocuments:file];
    return [UIImage imageWithContentsOfFile:filename];
}

- (NSString *)getNewID{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    NSString *str = [formatter stringFromDate:date];
    NSTimeInterval timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
    
    int d1 = rand() % 9;
    int d2 = rand() % 9;
    int d3 = rand() % 9;
    int d4 = rand() % 9;
    NSString *tail_casual = [NSString stringWithFormat:@"_%d%d%d%d%d",timePassed_ms,d1,d2,d3,d4];
    
    return  [str stringByAppendingString:tail_casual];
}


- (NSArray *)getVestitiEntities:(NSArray *)filterTipiKeys filterStagioniKeys:(NSArray *)filterStagioniKeys filterStiliKeys:(NSArray *)filterStiliKeys filterGradimento:(NSInteger)filterGradimento
    {
   
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Vestito" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:ed];
    
    
    NSMutableArray *predicates = [[[NSMutableArray alloc] init] autorelease];     
    if((filterTipiKeys != nil)&&([filterTipiKeys count] > 0)){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY tipi.nome in %@",filterTipiKeys];
        [predicates addObject:predicate];
    }
    
    
    if((filterStagioniKeys != nil)&&([filterStagioniKeys count] > 0)){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY perLaStagione.stagione in %@",filterStagioniKeys];
        [predicates addObject:predicate];
    }  
    
    
    if((filterStiliKeys != nil)&&([filterStiliKeys count] > 0)){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY conStile.stile in %@",filterStiliKeys];
        [predicates addObject:predicate];
    }    
    
    if(filterGradimento != -1){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gradimento >= %d",filterGradimento];
        
        [predicates addObject:predicate];
    }
     
    
    if([predicates count] > 0){
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [fetchRequest setPredicate: predicate];
    }
    
    NSError *error = nil;
    NSArray *vestiti = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( vestiti == nil)
    {
       NSLog(@"GetVestitiEntities error %@, %@", error, [error userInfo]);
       abort(); 
    }
    
    [vestiti retain];
    [vestiti autorelease];
    return vestiti;
}


- (Vestito *)addVestitoEntity:(UIImage *)image gradimento:(NSInteger)gradimento  tipiKeys:(NSArray *)tipiKeys stagioniKeys:(NSArray *)stagioniKeys stiliKeys:(NSArray *)stiliKeys; {
    
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    NSString *imageFilename; 
    NSString *id = [self getNewID];
    imageFilename = [id stringByAppendingString:@".png"];
    [imageData writeToFile:[self filePathDocuments:imageFilename] atomically:YES];
    
    Vestito *vestito = [NSEntityDescription insertNewObjectForEntityForName:@"Vestito" inManagedObjectContext:self.managedObjectContext];
    
    
    
    [vestito setValue:id forKey:@"id"];
    [vestito setValue:imageFilename forKey:@"immagine"];
    
    vestito = [self modifyVestitoEntity:vestito isNew:YES gradimento:gradimento  tipiKeys:tipiKeys stagioniKeys:stagioniKeys stiliKeys:stiliKeys];
    
    [self saveContext];
    
    [vestito retain];
    [vestito autorelease];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ADD_CLOTH_EVENT
     object:self];
    return vestito;
    

}

- (Vestito *)modifyVestitoEntity:(Vestito *)vestito isNew:(BOOL)new gradimento:(NSInteger)gradimento  tipiKeys:(NSArray *)tipiKeys stagioniKeys:(NSArray *)stagioniKeys stiliKeys:(NSArray *)stiliKeys{

    [vestito setValue:[NSNumber numberWithInteger:gradimento] forKey:@"gradimento"];
    
    if((tipiKeys != nil )&&([tipiKeys count] > 0)){
        NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
        for (NSString *key in tipiKeys) {
            [tmp addObject:[self getTipoEntity:key]];
        }
        vestito.tipi = [NSSet setWithArray: tmp];
    }
    if((stiliKeys != nil )&&([stiliKeys count] > 0)){
        NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
        for (NSString *key in stiliKeys) {
            [tmp addObject:[self getStileEntity:key]];
        }
        vestito.conStile = [NSSet setWithArray:tmp];
    }
    if((stagioniKeys != nil )&&([stagioniKeys count] > 0)){
        NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
        for (NSString *key in stagioniKeys) {
            [tmp addObject:[self getStagioneEntity:key]];
        }
        vestito.perLaStagione = [NSSet setWithArray:tmp];
    }


    if(!new){
        [self saveContext];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:MOD_CLOTH_EVENT
         object:self];
    }
    
    return vestito;
}


- (void)delVestitoEntity:(Vestito *)vestitoEntity{
    
    NSSet *inCombinazioni = vestitoEntity.inCombinazioni;
    
    for(Combinazione *combinazione in inCombinazioni){
        if([combinazione.fattaDi count] == 1){
            [self delCombinazioneEntity:combinazione]; 
        }
    }
    
    
    
    if((vestitoEntity.immagine != nil)&&([vestitoEntity.immagine length] > 0)){ 
        [[NSFileManager defaultManager] 
            removeItemAtPath:[self filePathDocuments:vestitoEntity.immagine]
            error:nil
        ];
    }
    
    [self.managedObjectContext deleteObject:vestitoEntity];
    [self saveContext];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:DEL_CLOTH_EVENT
     object:self];
    
}

- (void)modifyVestitiEntities{
    [self saveContext];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:MOD_CLOTH_EVENT
     object:self];
}


- (NSArray *)getCombinazioniEntities:(NSInteger)filterGradimento filterStagioniKeys:(NSArray *)filterStagioniKeys filterStiliKeys:(NSArray *)filterStiliKeys{
    
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Combinazione" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:ed];
    
    
    NSMutableArray *predicates = [[[NSMutableArray alloc] init] autorelease];     
    
    
    if((filterStagioniKeys != nil)&&([filterStagioniKeys count] > 0)){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY perLaStagione.stagione in %@",filterStagioniKeys];
        [predicates addObject:predicate];
    }  
    
    
    if((filterStiliKeys != nil)&&([filterStiliKeys count] > 0)){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY conStile.stile in %@",filterStiliKeys];
        [predicates addObject:predicate];
    }    
    
    
    if(filterGradimento != -1){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gradimento >= %d",filterGradimento];
        
        [predicates addObject:predicate];
    }
    
    
    if([predicates count] > 0){
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [fetchRequest setPredicate: predicate];
    }
    
    NSError *error = nil;
    NSArray *combinazioni = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if( combinazioni == nil)
    {
         NSLog(@"GetCombinazioniEntities error %@, %@", error, [error userInfo]);
         abort();
    }
    
    [combinazioni retain];
    [combinazioni autorelease];
    return combinazioni;

    
    
}


- (Combinazione *)addCombinazioneEntity:(NSSet *)vestitiEntities gradimento:(NSInteger)gradimento stagioniKeys:(NSArray *)stagioniKeys stiliKeys:(NSArray *)stiliKeys{
    
    Combinazione *combinazione = [NSEntityDescription insertNewObjectForEntityForName:@"Combinazione" inManagedObjectContext:self.managedObjectContext];
    
    NSString *id = @"1";
    [combinazione setValue:id forKey:@"id"];
    [combinazione setValue:[NSNumber numberWithInteger:gradimento] forKey:@"gradimento"];
    
    
    
    if((stiliKeys != nil )&&([stiliKeys count] > 0)){
        NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
        for (NSString *key in stiliKeys) {
            [tmp addObject:[self getStileEntity:key]];
        }
        combinazione.conStile = [NSSet setWithArray:tmp];
    }
    if((stagioniKeys != nil )&&([stagioniKeys count] > 0)){
        NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
        for (NSString *key in stagioniKeys) {
            [tmp addObject:[self getStagioneEntity:key]];
        }
        combinazione.perLaStagione = [NSSet setWithArray:tmp];
    }
    combinazione.fattaDi = vestitiEntities;
    
    [self saveContext];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:ADD_LOOK_EVENT
     object:self];
    [combinazione retain];
    [combinazione autorelease];
    return combinazione;    
}

- (Combinazione *)modifyCombinazioneEntity:(Combinazione *)combinazione gradimento:(NSInteger)gradimento  tipiKeys:(NSArray *)tipiKeys stagioniKeys:(NSArray *)stagioniKeys stiliKeys:(NSArray *)stiliKeys{
    
    
    [self saveContext];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:MOD_LOOK_EVENT
     object:self];
    
    return combinazione;
}


- (void)delCombinazioneEntity:(Combinazione *)combinazione{
    [self.managedObjectContext deleteObject:combinazione];
    [self saveContext];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:DEL_LOOK_EVENT
     object:self];
}


- (void)modifyCombinazioniEntities{
    [self saveContext];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:MOD_LOOK_EVENT
     object:self];
}



- (NSMutableDictionary *)tipiEntities{
	if([tipiEntities count] == 0){
		NSFetchRequest *allItem = [[[NSFetchRequest alloc] init] autorelease];
		[allItem setEntity:[NSEntityDescription entityForName:@"Tipologia" inManagedObjectContext:self.managedObjectContext]];
		NSError * error = nil;
		NSArray *entities = [self.managedObjectContext executeFetchRequest:allItem error:&error];
        
        if(entities == nil){
            NSLog(@"tipiEntities error %@, %@", error, [error userInfo]);
            abort();
        }    
        
        tipiEntities = [[NSMutableDictionary alloc] init];
        for (Tipologia *obj in entities) {
            [tipiEntities setObject:obj forKey:obj.nome];
        }
        
	}
	return tipiEntities;
};


- (NSArray *)listTipiKeys{

    if(listTipiKeys == nil){
        listTipiKeys = [[self.tipiEntities allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        [listTipiKeys retain];
    }
    return listTipiKeys;
};

- (NSArray *)listStagioniKeys{
    if(listStagioniKeys == nil){
        listStagioniKeys = [self.stagioniEntities allKeys]  ;
    }
    
    return listStagioniKeys;
};




- (NSArray *)listStiliKeys{
 
    if(listStiliKeys == nil){
        listStiliKeys = [self.stiliEntities allKeys]  ;
    }
    
    return listStiliKeys;
};

- (Tipologia *) getTipoEntity:(NSString *)tipo{
   return (Tipologia *)[self.tipiEntities objectForKey:tipo];
}

- (NSMutableDictionary *)stiliEntities{
	if([stiliEntities count] == 0){
        NSFetchRequest *allItem = [[[NSFetchRequest alloc] init] autorelease];
		[allItem setEntity:[NSEntityDescription entityForName:@"Stile" inManagedObjectContext:self.managedObjectContext]];
		NSError *error = nil;
		NSArray *entities = [self.managedObjectContext executeFetchRequest:allItem error:&error];
        
        if(entities == nil){
            NSLog(@"stiliEntities error %@, %@", error, [error userInfo]);
            abort();
        }
        
        stiliEntities = [[NSMutableDictionary alloc] init];
        for (Stile *obj in entities) {
            [stiliEntities setObject:obj forKey:obj.stile];
        }
        
        
        
	}
	return stiliEntities;
};


- (Stile *) getStileEntity:(NSString *)stileKey{
    return (Stile *)[self.stiliEntities objectForKey:stileKey];
}


- (NSMutableDictionary *)stagioniEntities{
	if([stagioniEntities count] == 0){
		NSFetchRequest *allItem = [[[NSFetchRequest alloc] init] autorelease];
		[allItem setEntity:[NSEntityDescription entityForName:@"Stagione" inManagedObjectContext:self.managedObjectContext]];
		NSError *error = nil;
		NSArray *entities = [self.managedObjectContext executeFetchRequest:allItem error:&error];
        
        if(entities == nil){
             NSLog(@"stagioniEntities error %@, %@", error, [error userInfo]);
             abort();
        }
        
        stagioniEntities = [[NSMutableDictionary alloc] init];
        for (Stagione *obj in entities) {
            [stagioniEntities setObject:obj forKey:obj.stagione];
        }
	}
	return stagioniEntities;
};

- (Stagione *) getStagioneEntity:(NSString *)stagioneKey{
    return (Stagione *)[self.stagioniEntities objectForKey:stagioneKey];
}



/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)loadTipologie:(NSString *)namefile{
	NSFetchRequest * allItem = [[[NSFetchRequest alloc] init] autorelease];
    [allItem setEntity:[NSEntityDescription entityForName:@"Tipologia" inManagedObjectContext:self.managedObjectContext]];
    [allItem setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:allItem error:&error];
    
    if(entities == nil){
        NSLog(@"loadTipologie error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if([entities count] == 0){
        NSString *path=[[NSBundle mainBundle] pathForResource:namefile ofType:@"plist"];
        NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:path];
        
        NSEnumerator *keys = [dict keyEnumerator];
        NSString *key;
        while ((key = [keys nextObject])) {
            NSDictionary *type = (NSDictionary *)[dict objectForKey:key];
            NSString *value = (NSString *)[type objectForKey:@"name"];
            NSManagedObject *tipologia = [NSEntityDescription insertNewObjectForEntityForName:@"Tipologia" inManagedObjectContext:self.managedObjectContext];
            [tipologia setValue:key forKey:@"id"];
            [tipologia setValue:value forKey:@"nome"];
            
        }
        
        [self saveContext];
        
        for (NSString *key in self.tipiEntities) {
            NSMutableSet *array = [[NSMutableSet alloc] init];
            Tipologia *tipo = [self.tipiEntities objectForKey:key];
            NSDictionary *type = (NSDictionary *)[dict objectForKey:tipo.id];
            NSString *allow = (NSString *)[type objectForKey:@"allow"];
            NSArray *tipologieAllow = [allow componentsSeparatedByString:@","];
            for (NSString *tipoallow in tipologieAllow){
                tipoallow = [tipoallow stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                 Tipologia *t = [self getTipoEntity:tipoallow];
                 if(t != nil){
                    [array addObject:[self getTipoEntity:tipoallow]];
                 }    
            }
            tipo.allow = array;
            [array autorelease];
        }
        [self saveContext];
    }
}



- (void)loadStili:(NSString *)namefile{
	NSFetchRequest * allItem = [[[NSFetchRequest alloc] init] autorelease];
    [allItem setEntity:[NSEntityDescription entityForName:@"Stile" inManagedObjectContext:self.managedObjectContext]];
    [allItem setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:allItem error:&error];
    
    if(entities == nil){
        NSLog(@"LoadStili error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if([entities count] == 0){
        NSString *path=[[NSBundle mainBundle] pathForResource:namefile ofType:@"plist"];
        NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:path];
        
        NSEnumerator *keys = [dict keyEnumerator];
        NSString *key;
        while ((key = [keys nextObject])) {
            NSString *value = (NSString *)[dict objectForKey:key];
            Stile *stile = [NSEntityDescription insertNewObjectForEntityForName:@"Stile" inManagedObjectContext:self.managedObjectContext];
            [stile setValue:key forKey:@"stile"];
            [stile setValue:value forKey:@"id"]; ;
            
        }
        
        [self saveContext];
    }
}


- (void)loadStagioni:(NSString *)namefile{
	NSFetchRequest * allItem = [[[NSFetchRequest alloc] init] autorelease];
    [allItem setEntity:[NSEntityDescription entityForName:@"Stagione" inManagedObjectContext:self.managedObjectContext]];
    [allItem setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:allItem error:&error];
    
    if(entities == nil){
        NSLog(@"loadStagioni error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if([entities count] == 0){
        NSString *path=[[NSBundle mainBundle] pathForResource:namefile ofType:@"plist"];
        NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:path];
        
        NSEnumerator *keys = [dict keyEnumerator];
        NSString *key;
        while ((key = [keys nextObject])) {
            NSDictionary *prop = [dict objectForKey:key];
            Stagione *stagione = [NSEntityDescription insertNewObjectForEntityForName:@"Stagione" inManagedObjectContext:self.managedObjectContext];
            
            
            [stagione setValue:[prop objectForKey:@"temp_min"] forKey:@"temp_min"];
            [stagione setValue:[prop objectForKey:@"temp_max"] forKey:@"temp_max"];
            [stagione setValue:[prop objectForKey:@"date_from"] forKey:@"date_from"];
            [stagione setValue:[prop objectForKey:@"date_to"] forKey:@"date_to"];
            [stagione setValue:key forKey:@"stagione"];
        }
        
        [self saveContext];
    }
}









-(void)setupDB
{
    [self loadTipologie:TIPOLOGIA_PLIST];
    [self loadStagioni:STAGIONE_PLIST];
    [self loadStili:STILE_PLIST];
    //[self debugDB];
}


-(void)debugDB{
    NSLog(@"Inzio test DB...");
    
    
    NSMutableArray *_tipi = [[NSMutableArray alloc] init];
    NSMutableArray *_stili = [[NSMutableArray alloc] init];
    NSMutableArray *_stagioni = [[NSMutableArray alloc] init];
    
    
    //NSArray *_curr_stagioni = [self getCurrStagioni];
    
    
    [_tipi addObject:[self getTipoEntity:@"giacca"]];
    [_stili addObject:[self getStileEntity:@"casual"]];
    [_stagioni addObject:[self getStagioneEntity:@"estiva"]];
    
    UIImage *image = [UIImage imageWithContentsOfFile:@"2011-09-09-04-01-11.png"];
    
    Vestito *v1=[self addVestitoEntity:image gradimento:-1  tipiKeys:_tipi stagioniKeys:_stagioni stiliKeys:_stili];
    
    
    
    //[_tipi addObject:[self getTipo:@"giacca"]];
    [_stili addObject:[self getStileEntity:@"casual"]];
    [_stagioni addObject:[self getStagioneEntity:@"estiva"]];
    
    Vestito *v2 = [self addVestitoEntity:image gradimento:-1  tipiKeys:_tipi stagioniKeys:_stagioni stiliKeys:_stili];

    
    NSMutableArray *a = [NSMutableArray arrayWithObjects:v1,v2,nil];
    
    
    //NSMutableArray *filterTipi = [[NSMutableSet alloc] init];
    //NSMutableArray *filterStili = [[NSMutableSet alloc] init];
    
    
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:a];
    
    
    [self addCombinazioneEntity:set  gradimento:-1 stagioniKeys:nil stiliKeys:nil];
    
    //NSArray *res = [self getCombinazioni:-1 filterStagioni:nil filterStili:nil];
    
    
    //Combinazione *combinazione = (Combinazione *)[res objectAtIndex:0];
    
    /*
    NSSet *vestiti = [combinazione.fattaDi copy];
    
    for(Vestito *vestito in vestiti){
        [self delVestito:vestito];
    }*/
    
    //[managedObjectContext refreshObject:combinazione mergeChanges:YES];
    //[managedObjectContext refreshObject:combinazione mergeChanges:NO];
    /*vestiti = combinazione.fattaDi;
    
    for(Vestito *vestito in vestiti){
        NSLog(@"%@",vestito);
    }*/
    
    [set release];
    [_tipi release];
    [_stili release];
    [_stagioni release];
    //[vestiti release];
    
}


- (void)setCurrStagioneKeyFromTemp:(int)temperatura{
    NSPredicate *predicate;
    
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Stagione" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:ed];
  
    NSMutableArray *predicates = [[[NSMutableArray alloc] init] autorelease];
    
    if(temperatura != 999){
        predicate = [NSPredicate predicateWithFormat:@"temp_min <= %d AND temp_max >=%d",temperatura,temperatura];
        [predicates addObject:predicate];
    }
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"MM-dd"];
    NSString *filterdate = [formatter stringFromDate:date];
    
    predicate = [NSPredicate predicateWithFormat:@"date_from <= %@ AND date_to >=%@",filterdate,filterdate];
    
    [predicates addObject:predicate];
    
    
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error]; 
    
    
    
    if([results count] > 0){
        if(!currStagioneKey){ [currStagioneKey release];} 
       currStagioneKey = ((Stagione *)[results objectAtIndex:0]).stagione;
        [currStagioneKey retain];
    }
    else{
        currStagioneKey = @"estiva";
        NSLog(@"error get stagioni -> No season found");
    }
}

- (NSString *)currStagioneKey{
    if(currStagioneKey == nil){
            [self setCurrStagioneKeyFromTemp:999];
    }
    
    //NSLog(@"%@",currStagioneKey);
    
    return currStagioneKey;
}



/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
	if (managedObjectContext != nil) { 
		return managedObjectContext;
	}
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) { 
		managedObjectContext = [[NSManagedObjectContext alloc] init]; 
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	} 
	return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel != nil) { 
		return managedObjectModel;
	} 
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iArmadio" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
	return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iarmadioDB.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
    return persistentStoreCoordinator;
}

- (void)saveContext {
    
    NSError *error = nil;
	if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    
} 



- (void)dealloc{
	[managedObjectContext release];
	[managedObjectModel release];
    [persistentStoreCoordinator release]; 
    [stiliEntities release];
    [tipiEntities release];
    [listTipiKeys release];
    [listStagioniKeys release];
    [listStiliKeys release];
    [stagioniEntities release];
    [currStagioneKey release];
    [singleton release];
	[super dealloc];
}

@end
