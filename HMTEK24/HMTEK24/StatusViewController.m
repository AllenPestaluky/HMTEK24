//
//  StatusViewController.m
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import "StatusViewController.h"
#import "PlayerStatus.h"
#import "FontLabel.h"

@interface StatusViewController()
-(void) sizeLabel: (UILabel*) label;
-(UILabel*) newLabel: (BOOL) addToZombieView;
@end

@implementation StatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
  // Do any additional setup after loading the view from its nib.
  
  CGRect tempFrame;
  int startingY = self.view.frame.size.height * 0.05;
  int lineHeight = self.view.frame.size.height * 0.08;
  
  timeRemainingLabel1 = [self newLabel:NO];
  tempFrame = timeRemainingLabel1.frame;
  tempFrame.origin.y = startingY;
  timeRemainingLabel1.frame = tempFrame;
  
  timeRemainingLabel2 = [self newLabel:NO];
  tempFrame = timeRemainingLabel2.frame;
  tempFrame.origin.y = startingY + lineHeight;
  timeRemainingLabel2.frame = tempFrame;
  
  timeRemainingLabel3 = [self newLabel:NO];
  tempFrame = timeRemainingLabel1.frame;
  tempFrame.origin.y = startingY + lineHeight *2;
  timeRemainingLabel3.frame = tempFrame;
  
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  status.isZombie = NO;
  [self refreshStatusView:status];
}

-(UILabel*) newLabel: (BOOL) addToZombieView {
  UILabel* label = [[FontLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0) fontName:@"PRISTINA" pointSize:60.0f];
	label.textColor = [UIColor redColor];
	label.backgroundColor = nil;
	label.opaque = NO;
  label.numberOfLines = 0; // any number of lines
  label.textAlignment = UITextAlignmentCenter;
  if(addToZombieView) {
    [ZombieView addSubview:label];
  } else {
    [AliveView addSubview:label];
  }
  return label;
}

- (void)viewDidUnload
{  
  [timeRemainingLabel1 release];
  timeRemainingLabel1 = nil;
  [timeRemainingLabel2 release];
  timeRemainingLabel2 = nil;
  [timeRemainingLabel3 release];
  timeRemainingLabel3 = nil;
  
  [ZombieView release];
  ZombieView = nil;
  [AliveView release];
  AliveView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)applicationDidBecomeActive {
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  [status getZombieStatus:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refreshStatusView: (PlayerStatus*) status {
  // First hide everything:
  ZombieView.hidden = YES;
  AliveView.hidden = YES;
  
  if(status.isZombie) {
    ZombieView.hidden = NO;
    
  } else {
    
    timeRemainingLabel1.text = [NSString stringWithFormat: @"%i:%i:%i", status.hours, status.minutes, status.seconds];
    [self sizeLabel: timeRemainingLabel1];
    
    timeRemainingLabel2.text = [NSString stringWithFormat: @"remain"];
    [self sizeLabel: timeRemainingLabel2];
    
    AliveView.hidden = NO;
  }
}

- (IBAction)onCheckinAlive:(id)sender {
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  status.isZombie = YES;
  [self refreshStatusView:status];
}

- (IBAction)onCheckinZombie:(id)sender {
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  status.isZombie = NO;
  [self refreshStatusView:status];
}

-(void) sizeLabel: (UILabel*) label {
  [label sizeToFit];
  CGRect newFrame = label.frame;
  newFrame.origin.x = self.view.frame.size.width / 2 - newFrame.size.width / 2;
  label.frame = newFrame;
}

- (void)dealloc {
  [timeRemainingLabel1 release];
  [timeRemainingLabel2 release];
  [timeRemainingLabel3 release];
  [ZombieView release];
  [AliveView release];
  [super dealloc];
}
@end
