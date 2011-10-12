//
//  SelectTypeViewController.m
//  iArmadio
//
//  Created by Casa Fortunato on 04/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectTypeViewController.h"

@implementation SelectTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)undo:(id)sender{
   [self dismissModalViewControllerAnimated:YES];
}


- (NSInteger) getIndex{
    return selectedIndex;
}

- (void) selectedIndex:(NSInteger )index{
    selectedIndex = index;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IarmadioDao *dao = [IarmadioDao shared];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[dao getImageFromSection:@"SelectTypeView" type:@"background"]];
    
    
    selectedIndex = -1;
    
    armadio = [[ArmadioTableViewController alloc] initWithNibName:@"ArmadioViewTable" bundle:nil delegateController:self];
    
    armadio.view.frame = CGRectMake(0,44,320,420);
    [self.view addSubview:armadio.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc{
    [armadio release];
    [super dealloc];

}



@end
