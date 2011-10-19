//
//  SecondViewController.m
//  iArmadio
//
//  Created by William Pompei on 03/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookViewController.h"

@implementation LookViewController




@synthesize imageView,
            imageViewReflect,
            stile_1,
            stile_2,
            stile_3,
            stagione_1,
            stagione_2,
            stagione_3,
            gradimento_1,
            gradimento_2,
            gradimento_3,
            undoButton, 
            saveButton, 
            tipologiaBtn, 
            tipologiaLabel,
            tipologiaSelected,
            stileLabel,
            stagioneLabel,
            gradimentoLabel,
            addNavigationBar,
            toolbar,
            currTipologia,
            currStile,
            trash,
            addPreferiti,
            preferito;
 


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil setImage:(UIImage *)image{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    newimage = image;
    [newimage retain];
    
    addCloth = YES;
    currTipologia = [CurrState shared].currTipologia;
    currStile = nil;
    currGradimento = nil;
    currStagione = nil;
    preferito = @"";
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil getVestito:(Vestito *)_vestito{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    vestito = _vestito;
    [vestito retain];
    addCloth = NO;
    currTipologia = [CurrState shared].currTipologia;
    currStile = nil;
    currGradimento = nil;
    currStagione = nil;
    return self;
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    dao = [IarmadioDao shared];
    [CurrState shared].currSection = SECTION_CLOTHVIEW;
    
    
    if(vestito != nil){self.preferito = vestito.preferito;}
    [self initInputType];
    lastScaleFactor = 0;
    
    
    self.stileLabel.text = NSLocalizedString(self.stileLabel.text,nil);
    self.stagioneLabel.text = NSLocalizedString(self.stagioneLabel.text,nil);
    self.gradimentoLabel.text = NSLocalizedString(self.gradimentoLabel.text,nil);
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[dao getImageFromSection:[CurrState shared].currSection type:@"background"]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewReflect.contentMode = UIViewContentModeScaleAspectFit;
    
    //Edit image
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    
    tapGesture.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    
    [self.imageView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    
    [self.imageView addGestureRecognizer:rotateGesture];
    [rotateGesture release];
    [self.imageView setUserInteractionEnabled:YES];
    self.imageView.multipleTouchEnabled = YES;
    
    ////////////
    
    
    if(newimage != nil){
        [self.imageView setImage:newimage];
        //[self.imageViewReflect setImage:[newimage reflectedImageWithHeight:200 fromAlpha:0.5 toAlpha:1]];
        //[self.addNavigationBar setHidden:NO];
        NSMutableArray *items = [[toolbar.items mutableCopy] autorelease];
        [items removeObject:trash]; 
        toolbar.items = items;
        
    }
    
    if(vestito != nil){
        [self.imageView setImage:[dao getImageFromVestito:vestito]];
        //[self.imageViewReflect setImage:[[dao getImageFromVestito:vestito] reflectedImageWithHeight:200 fromAlpha:0.5 toAlpha:0]];
       self.preferito = vestito.preferito;
    }
    
    
    

    
    if(newimage != nil){
        if(self.currTipologia){
            Tipologia *tipologiaEntity = [dao getTipoEntity:self.currTipologia];
            [self.tipologiaBtn setImage:[dao getImageFromTipo:tipologiaEntity] forState:UIControlStateNormal];
            self.tipologiaLabel.text = NSLocalizedString(tipologiaEntity.nome,nil);
            self.tipologiaSelected = tipologiaEntity.nome;
        }
        else{
            Tipologia *tipologiaEntity = [dao getTipoEntity:[dao.listTipiKeys objectAtIndex:0]];
            [self.tipologiaBtn setImage:[dao getImageFromTipo:tipologiaEntity] forState:UIControlStateNormal];
            self.tipologiaLabel.text = NSLocalizedString([dao.listTipiKeys objectAtIndex:0],nil);
            self.tipologiaSelected = tipologiaEntity.nome;
        }  
        
        if([[CurrState shared] currStagioneIndex] == nil){
            ([CurrState shared]).currStagioneKey = dao.currStagioneKey;
        }
        
        if([[[CurrState shared] currStagioneIndex] intValue] == 3){
            [self initStagioniEntities:[NSNumber numberWithInt:1]];
        }
        else{
            [self initStagioniEntities:[[CurrState shared] currStagioneIndex]];
        }    
    }
    else if(vestito != nil){
        
        Tipologia *tipo = [[vestito.tipi allObjects] objectAtIndex:0];
        [self.tipologiaBtn setImage:[dao getImageFromTipo:tipo] forState:UIControlStateNormal];
         self.tipologiaLabel.text = NSLocalizedString(tipo.nome,nil);
         self.tipologiaSelected = tipo.nome;
        
        NSNumber *grad = vestito.gradimento;
        
        if(grad != nil){
            choiceGradimento.selectedIndex = grad.intValue;
        } 
        
        NSString *stagioneKey = vestito.perLaStagione.stagione;
        
        
        ([CurrState shared]).currStagioneKey = stagioneKey;
        
        [self initStagioniEntities:[[CurrState shared] currStagioneIndex]];
        
        
        if([vestito.conStile count] > 0){
            NSArray *stili = [vestito.conStile allObjects];
            Stile *tmp = [stili objectAtIndex:0];
            choiceStile.selectedIndex = [tmp.id intValue]-1;
        }
        
    }

   
   
}

- (void)initInputType{
    //Seleziona Stili
    NSArray *stiliKeys = [dao listStiliKeys];
    Stile *stile;
    stile = [dao getStileEntity:[stiliKeys objectAtIndex:0]];
    [self.stile_1 setImage:[dao getImageFromStile:stile] forState: UIControlStateNormal];
    stile = [dao getStileEntity:[stiliKeys objectAtIndex:1]];
    [self.stile_2 setImage:[dao getImageFromStile:stile] forState: UIControlStateNormal];
    stile = [dao getStileEntity:[stiliKeys objectAtIndex:2]];
    [self.stile_3 setImage:[dao getImageFromStile:stile] forState: UIControlStateNormal]; 
    
    segmentStile = [[NSArray alloc] initWithObjects:self.stile_1,self.stile_2,self.stile_3, nil];
    choiceStile = [[ButtonSegmentControl alloc] init:@"stili"];
    choiceStile.delegate = self;
    choiceStile.selectedIndex = 0;
    
    
    NSArray *stagioniKeys = [dao listStagioniKeys];
    Stagione *stagione;
    stagione = [dao getStagioneEntity:[stagioniKeys objectAtIndex:0]];
    [self.stagione_1 setImage:[dao getImageFromStagione:stagione] forState: UIControlStateNormal];
    stagione = [dao getStagioneEntity:[stagioniKeys objectAtIndex:1]];
    [self.stagione_2 setImage:[dao getImageFromStagione:stagione] forState: UIControlStateNormal];
    stagione = [dao getStagioneEntity:[stagioniKeys objectAtIndex:2]];
    [self.stagione_3 setImage:[dao getImageFromStagione:stagione] forState: UIControlStateNormal]; 
    
    segmentStagione = [[NSArray alloc] initWithObjects:self.stagione_1,self.stagione_2,self.stagione_3, nil];
    choiceStagione = [[ButtonSegmentControl alloc] init:@"stagioni"];
    choiceStagione.delegate = self;
    choiceStagione.selectedIndex = 0;
    
    
    [self.gradimento_1 setImage:[dao getImageFromSection:[CurrState shared].currSection type:@"icona_gradimento_1"] forState: UIControlStateNormal];
    [self.gradimento_2 setImage:[dao getImageFromSection:[CurrState shared].currSection type:@"icona_gradimento_2"] forState: UIControlStateNormal];
    [self.gradimento_3 setImage:[dao getImageFromSection:[CurrState shared].currSection type:@"icona_gradimento_3"] forState: UIControlStateNormal]; 
    
    segmentGradimento = [[NSArray alloc] initWithObjects:self.gradimento_1,self.gradimento_2,self.gradimento_3, nil];
    choiceGradimento = [[ButtonSegmentControl alloc] init:@"gradimento"];
    choiceGradimento.delegate = self;
    choiceGradimento.selectedIndex = 0;
    
    
    [self.view setUserInteractionEnabled:NO];
    if((self.preferito != nil)&&([self.preferito length]>0)){
        addPreferiti.selected = YES;
        [addPreferiti setSelected:YES];
        [addPreferiti setHighlighted:YES];
    }    
    else{
        addPreferiti.selected = NO;
        [addPreferiti setSelected:NO];
        [addPreferiti setHighlighted:NO];
    }
    [self.view setUserInteractionEnabled:YES];
     
    
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

   
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction) addPreferiti:(id)sender{
    if(self.view.isUserInteractionEnabled){
     [self performSelector:@selector(keepHighlightButton) withObject:nil afterDelay:0.0];
    }    
    
}

- (void)keepHighlightButton{
    if(!addPreferiti.selected){
        [addPreferiti setSelected:YES];
        [addPreferiti setHighlighted:YES];
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
        NSString *str = [formatter stringFromDate:date];
        NSTimeInterval timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSString *millisecondi = [NSString stringWithFormat:@"-%d",timePassed_ms];
        self.preferito = [str stringByAppendingString:millisecondi];
    } else {
        [addPreferiti setHighlighted:NO];
        [addPreferiti setSelected:NO];
        self.preferito = nil;
    }

}




- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"OK");
}

-(IBAction) deleteCloth:(id) sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Cancella",nil) message:NSLocalizedString(@"Vuoi cancellare il vestito",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Annulla",nil) otherButtonTitles:NSLocalizedString( @"Cancella",nil), nil];
    
    [alert show];
    [alert release];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != 0){
        //[CurrState shared].currSection = [CurrState shared].oldCurrSection;
        [dao delVestitoEntity:vestito];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view.superview cache:YES];
        [self dismissModalViewControllerAnimated:NO];
        [UIView commitAnimations];
    }
     
}

-(IBAction) saveCloth:(id) sender {
	
   NSString *nametipo = self.tipologiaSelected; 
   NSArray *tipi = [[NSArray alloc] initWithObjects:nametipo,nil];
    
        
   
   
   NSMutableArray *stili = [[NSMutableArray alloc] init];
   if(choiceStile.selectedIndex < [dao.listStiliKeys count]){
       [stili addObject:[dao.listStiliKeys objectAtIndex:choiceStile.selectedIndex]];
   }
   
    
    NSString *scelta_stagione = [[dao listStagioniKeys] objectAtIndex:choiceStagione.selectedIndex] ;
    
    if(addCloth){ 
        
        if([[dao getVestitiEntities:tipi filterStagioneKey:nil filterStiliKeys:nil filterGradimento:-1] count]+1 > MAX_CLOTH){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
                                  NSLocalizedString(@"Numero massimo superato",nil) message: NSLocalizedString(@"Il numero massimo dei capi per questo tipo è stato raggiunto",nil) delegate:self cancelButtonTitle: NSLocalizedString(@"Annulla",nil) otherButtonTitles:nil, nil];
            
            [alert show];
            [alert release];
            [tipi release];
            [stili release];
            return;
        }  

        
        
        vestito = [dao addVestitoEntity:[self.imageView.image normal] gradimento:choiceGradimento.selectedIndex tipiKeys:tipi stagioneKey:scelta_stagione stiliKeys:stili preferito:self.preferito];
        [vestito retain];
        
    }
    else{
        UIImage *tmp = nil;
        if(modifyImageCloth){
            tmp = [self.imageView.image normal];
        }    
        
        if(vestito != nil){[vestito autorelease];}
        vestito.preferito = self.preferito;
        vestito = [dao modifyVestitoEntity:vestito image:tmp  isNew:NO gradimento:choiceGradimento.selectedIndex tipiKeys:tipi stagioneKey:scelta_stagione stiliKeys:stili];
            modifyImageCloth = NO;
        [vestito retain];
    }
    
    
    [tipi release];
    [stili release];
    CurrState *currstate = [CurrState shared];
    currstate.currStagioneIndex = [NSNumber numberWithInteger:choiceStagione.selectedIndex]; 
    
    [self dismissModalViewControllerAnimated:YES];
}



-(IBAction) undoCloth:(id) sender{
   //[CurrState shared].currSection = [CurrState shared].oldCurrSection;
   [self dismissModalViewControllerAnimated:YES];
}


- (void)initStagioniEntities:(NSNumber *)stagioneIndex{
    choiceStagione.selectedIndex = [stagioneIndex intValue];
}


-(IBAction) selectImage:(id) sender{
        UIActionSheet *popupAddItem = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Cambia Immagine Vestito",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Fotocamera",nil),NSLocalizedString(@"Album",nil), nil];
        
        popupAddItem.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [popupAddItem showInView:self.view];
        [popupAddItem release];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = nil;
    
    if (buttonIndex != 2) {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
    }   
    
    if (buttonIndex == 0) {
#if !(TARGET_IPHONE_SIMULATOR)
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
#else
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#endif
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
    else if (buttonIndex == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //picker.allowsEditing = YES;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    } 
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo 
{
	[picker dismissModalViewControllerAnimated:NO];
    [self.imageView setImage:image];
    modifyImageCloth = YES;
}


-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender{
    if(sender.view.contentMode == UIViewContentModeScaleAspectFit)
        sender.view.contentMode = UIViewContentModeCenter;
    else
        sender.view.contentMode = UIViewContentModeScaleAspectFit;
}

-(IBAction) handlePinchGesture:(UIGestureRecognizer *)sender{
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    if(factor > 1){
        sender.view.transform = CGAffineTransformMakeScale(lastScaleFactor + (factor-1),lastScaleFactor + (factor-1));
                                                           
    }
    else{
        sender.view.transform = CGAffineTransformMakeScale(lastScaleFactor*factor, lastScaleFactor+factor);
    }
    
    if(sender.state == UIGestureRecognizerStateEnded){
        if(factor > 1){
            lastScaleFactor += (factor-1);
        }
        else{
            lastScaleFactor *=factor;
        }
    }
    
}


-(IBAction) handleRotateGesture:(UIGestureRecognizer *)sender{
    CGFloat rotation = [(UIRotationGestureRecognizer *)sender rotation];
    sender.view.transform = CGAffineTransformMakeRotation(rotation + netRotation);
    
    if(sender.state == UIGestureRecognizerStateEnded){
        netRotation += rotation;
    }
}

-(IBAction) selectTipo:(id) sender{
    
    selectController = [[SelectTypeViewController alloc] initWithNibName:@"SelectTypeViewController" bundle:nil];
    
    [self presentModalViewController:selectController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

}

- (void)viewWillAppear:(BOOL)animated
{
    modifyImageCloth = NO;
    
     
    if((selectController != nil)&&([selectController getIndexPath] != nil)){
        NSString *category = [dao.listCategoryKeys objectAtIndex:[selectController getIndexPath].section];
        
        
        NSArray *tipologie = [dao.category objectForKey:category];
        
        
        Tipologia *entity =  [dao getTipoEntity:[tipologie objectAtIndex:[selectController getIndexPath].row ]];
        
        self.tipologiaLabel.text = NSLocalizedString(entity.nome,nil);
        self.tipologiaSelected = entity.nome;
        
        [self.tipologiaBtn setImage:[dao getImageFromTipo:entity] forState:UIControlStateNormal];
 
        
        [selectController release];
        selectController = nil;    
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (NSArray *)buttons:(ButtonSegmentControl *)buttonSegmentControl{
    if([buttonSegmentControl.tag isEqualToString:@"stili"]){
        return segmentStile;
    }
    else if([buttonSegmentControl.tag isEqualToString:@"stagioni"]){
        return segmentStagione;
    }
    else if([buttonSegmentControl.tag isEqualToString:@"gradimento"]){
        return segmentGradimento;
    }
    return nil;
}


- (void)buttonSegmentControl:(ButtonSegmentControl *)buttonControl  selectedButton:(UIButton *)button selectedIndex:(NSInteger)selectedIndex{
    
    if([buttonControl.tag isEqualToString:@"stili"]){
        choiceStile.selectedIndex = selectedIndex;
    }
    else if([buttonControl.tag isEqualToString:@"stagioni"]){
        choiceStagione.selectedIndex = selectedIndex;
    }
    else if([buttonControl.tag isEqualToString:@"gradimento"]){
        choiceGradimento.selectedIndex = selectedIndex;
    }
    
}

-(void) dealloc{
    if(vestito != nil){
        [vestito release];
    }
    [stile_1 release];
    [stile_2 release];
    [stile_3 release];
    [stagione_1 release];
    [stagione_2 release];
    [stagione_3 release];
    [gradimento_1 release];
    [gradimento_2 release];
    [gradimento_3 release];
    [currStile release];
    [currTipologia release];
    [toolbar release];
    [trash release];
    [imageViewReflect release];
    [imageView release];
    [saveButton release];
    [addNavigationBar release];
    [undoButton release];
    [tipologiaBtn release];
    [tipologiaLabel release];
    [segmentStile release];
    [segmentStagione release];
    [segmentGradimento release];
    [preferito release];
    [super dealloc];
}



@end
