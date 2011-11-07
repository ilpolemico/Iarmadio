//
//  Tutorial.h
//  iArmadio
//
//  Created by Casa Fortunato on 05/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IarmadioDao.h"

static NSString * const TUTORIAL_PLIST = @"Tutorial";

#define ACTION_START @"startApp"
#define ACTION_ADDCLOTH @"addCloth"
#define ACTION_LOOKVIEW @"lookView"
#define ACTION_LOOKTABLE @"lookTable"
#define ACTION_COVERFLOW @"coverFlow"
#define ACTION_PREFERITI @"preferiti"


@interface Tutorial : NSObject{
    NSMutableDictionary *tutorial;
    IarmadioDao *dao;
}


+(Tutorial *)shared;
- (void) actionInfo:(NSString *)action;
- (void)loadTutorialDictionary;
- (void) showInfo:(NSString *)info;

@end
