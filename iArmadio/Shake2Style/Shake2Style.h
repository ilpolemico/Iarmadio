//
//  Shake2Style.h
//  iArmadio
//
//  Created by Casa Fortunato on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IarmadioDao.h"
#import "iArmadioAppDelegate.h"

@interface Shake2Style : UIViewController{
    IarmadioDao *dao;
}

@property (nonatomic, retain, readonly) IarmadioDao *dao;


+ (Shake2Style *)shared;
- (Combinazione *)shake2style:(NSArray *)filterStili filterStagione:(NSString *)filterStagione;

-(IBAction)done:(id)sender;

@end
