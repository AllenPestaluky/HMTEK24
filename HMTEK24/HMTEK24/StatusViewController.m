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
-(UILabel*) newLabel;
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
  
  timeRemainingLabel1 = [self newLabel];
  tempFrame = timeRemainingLabel1.frame;
  tempFrame.origin.y = startingY;
  timeRemainingLabel1.frame = tempFrame;
  
  timeRemainingLabel2 = [self newLabel];
  tempFrame = timeRemainingLabel2.frame;
  tempFrame.origin.y = startingY + lineHeight;
  timeRemainingLabel2.frame = tempFrame;
  
  timeRemainingLabel3 = [self newLabel];
  tempFrame = timeRemainingLabel1.frame;
  tempFrame.origin.y = startingY + lineHeight *2;
  timeRemainingLabel3.frame = tempFrame;
  
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  status.isZombie = NO;
  [self refreshStatusView:status];
}

-(UILabel*) newLabel {
  UILabel* label = [[FontLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0) fontName:@"PRISTINA" pointSize:60.0f];
	label.textColor = [UIColor redColor];
	label.backgroundColor = nil;
	label.opaque = NO;
  label.numberOfLines = 0; // any number of lines
  label.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:label];
  return label;
}

- (void)viewDidUnload
{
  [aliveBackImage release];
  aliveBackImage = nil;
  [zombieBackImage release];
  zombieBackImage = nil;
  
  [timeRemainingLabel1 release];
  timeRemainingLabel1 = nil;
  [timeRemainingLabel2 release];
  timeRemainingLabel2 = nil;
  [timeRemainingLabel3 release];
  timeRemainingLabel3 = nil;
  
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)applicationDidBecomeActive {
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  [self refreshStatusView:status];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refreshStatusView: (PlayerStatus*) status {
  // First hide everything:
  zombieBackImage.hidden = YES;
  aliveBackImage.hidden = YES;
  timeRemainingLabel1.hidden = YES;
  timeRemainingLabel2.hidden = YES;
  timeRemainingLabel3.hidden = YES;
  
  if(status.isZombie) {
    zombieBackImage.hidden = NO;
    
  } else {
    aliveBackImage.hidden = NO;
    
    timeRemainingLabel1.hidden = NO;
    timeRemainingLabel1.text = [NSString stringWithFormat: @"%i hours", 12];
    [self sizeLabel: timeRemainingLabel1];
    
    timeRemainingLabel2.hidden = NO;
    timeRemainingLabel2.text = [NSString stringWithFormat: @"%i minutes", 32 ];
    [self sizeLabel: timeRemainingLabel2];
    
    timeRemainingLabel3.hidden = NO;
    timeRemainingLabel3.text = [NSString stringWithFormat: @"remain"];
    [self sizeLabel: timeRemainingLabel3];
  }
}

-(void) sizeLabel: (UILabel*) label {
  [label sizeToFit];
  CGRect newFrame = label.frame;
  newFrame.origin.x = self.view.frame.size.width / 2 - newFrame.size.width / 2;
  label.frame = newFrame;
}

- (void)dealloc {
  [aliveBackImage release];
  [zombieBackImage release];
  [super dealloc];
}
@end
