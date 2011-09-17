//
//  StatusViewController.m
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import "StatusViewController.h"
#import "PlayerStatus.h"


@interface StatusViewController()
- (void) calculateTimeToLive;
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
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  status.isZombie = (rand() % 2 == 0) ? YES : NO;
  [self refreshStatusView:status];
}

- (void)viewDidUnload
{
  [aliveBackImage release];
  aliveBackImage = nil;
  [zombieBackImage release];
  zombieBackImage = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)applicationDidBecomeActive {
  PlayerStatus* status = [[[PlayerStatus alloc] init] autorelease];
  status.isZombie = (rand() % 2 == 0) ? YES : NO;
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
  
  if(status.isZombie) {
    zombieBackImage.hidden = NO;
    
  } else {
    aliveBackImage.hidden = NO;
    
  }
}

- (void)dealloc {
  [aliveBackImage release];
  [zombieBackImage release];
  [super dealloc];
}
@end
