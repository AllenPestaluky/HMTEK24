//
//  HMTEK24ViewController.m
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import "HMTEK24ViewController.h"
#import "FoursquareWebLogin.h"

@interface HMTEK24ViewController()
- (void) onFoursquareAuthenticationComplete;
- (void) doFoursquareAuthentication;
@end

@implementation HMTEK24ViewController

@synthesize statusViewController;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
  self.statusViewController = nil;
  [super dealloc];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
  if(statusViewController == nil) {
    statusViewController = [[StatusViewController alloc] initWithNibName:nil bundle:nil];
  }
  [Foursquare2 checkConstants];
}

- (void) viewDidAppear:(BOOL)animated {
  [self doFoursquareAuthentication];
}

- (void) doFoursquareAuthentication {
  if ([Foursquare2 isNeedToAuthorize]) {
    [FoursquareWebLogin authorizeWithViewController:self 
                                           Callback:^(BOOL success,id result){
                                             if (success) {
                                               [self onFoursquareAuthenticationComplete];
                                             }
                                           }];
  } else {
    [self onFoursquareAuthenticationComplete];
  }
}

- (void) onFoursquareAuthenticationComplete {
  [self presentModalViewController:statusViewController animated:YES];
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

- (IBAction)onTestButtonPress:(id)sender {
  [self onFoursquareAuthenticationComplete];
  
}
@end
