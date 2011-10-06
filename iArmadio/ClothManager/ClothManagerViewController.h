//
//  CreateViewController.h
//  iArmadio
//
//  Created by William Pompei on 03/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iArmadioAppDelegate.h"
#import "ClothViewController.h"
#import "ClothTableViewController.h"



@interface ClothManagerViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{

    
    IarmadioDao *dao;
    IBOutlet UINavigationController *navcontroler;
    IBOutlet UIBarButtonItem *addItemBtn;
    IBOutlet UIBarButtonItem *modifyBtn;
    Tipologia *tipologia;
    CurrState *currstate;
  
}

@property (nonatomic, retain) Tipologia *tipologia;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addItemBtn;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *modifyBtn;
@property(nonatomic,retain, readonly) IBOutlet UINavigationController *navcontroler;



- (void)addIterator:(NSNotification *)notification;
- (IBAction) addItem:(id) sender;
- (IBAction) modify:(id) sender;

@end
