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
- (UIImage*) newImageFromURL: (NSString*) url;
@end

@implementation StatusViewController

@synthesize status;

const int infoButtonTag = 1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.status = [[[PlayerStatus alloc] init] autorelease];
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
  
  /*UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  infoButton.frame = CGRectMake(10, 10, 16, 16);
  infoButton.backgroundColor = [UIColor clearColor];
  [infoButton addTarget:self action:@selector(buttonPressed:) 
       forControlEvents:UIControlEventTouchUpInside];
  infoButton.tag = infoButtonTag;
  [self.view addSubview:infoButton];
  // Change the existing touch area by 40 pixels in each direction
  // Move the x/y starting coordinates so the button remains in the same location
  CGRect rect = CGRectMake(
                           infoButton.frame.origin.x - 20,
                           infoButton.frame.origin.y - 20,
                           infoButton.frame.size.width + 40,
                           infoButton.frame.size.height + 40);
  [infoButton setFrame:rect];*/
  
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
  
  timeRemainingLabel2.text = [NSString stringWithFormat: @"remain"];
  [self sizeLabel: timeRemainingLabel2];
  
//  timeRemainingLabel3 = [self newLabel:NO];
//  tempFrame = timeRemainingLabel1.frame;
//  tempFrame.origin.y = startingY + lineHeight *2;
//  timeRemainingLabel3.frame = tempFrame;

  [self refreshStatusView];
}

-(UILabel*) newLabel: (BOOL) addToZombieView {
  UILabel* label = [[FontLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0) fontName:@"PRISTINA" pointSize:60.0f];
	label.textColor = [UIColor blackColor];
	label.backgroundColor = nil;
	label.opaque = NO;
  label.numberOfLines = 1; // only one line for these
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
  //[timeRemainingLabel3 release];
  //timeRemainingLabel3 = nil;
  
  [ZombieView release];
  ZombieView = nil;
  [AliveView release];
  AliveView = nil;
  [venueType1Image release];
  venueType1Image = nil;
  [venueType2Image release];
  venueType2Image = nil;
  [venueType3Image release];
  venueType3Image = nil;
  [venueType4Image release];
  venueType4Image = nil;
  [venueType5Image release];
  venueType5Image = nil;
  [photoImage release];
  photoImage = nil;
  [photoOverlayImage release];
  photoOverlayImage = nil;
  [zombieReasonTextView release];
  zombieReasonTextView = nil;
  [venueStatusTextView release];
  venueStatusTextView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)applicationDidBecomeActive {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)buttonPressed:(UIButton *)button
{
  if(button.tag == infoButtonTag) {
    // TODO: show info
  }
}

- (void)refreshStatusView {
  NSLog(@"status description:\n%@", [status description]);
  
  // First hide everything:
  ZombieView.hidden = YES;
  AliveView.hidden = YES;
  
  // TODO: replace this with a real URL
  UIImage* image = [self newImageFromURL: @"https://secure.gravatar.com/avatar/9d73f299f9c285733a1b880f48c7c653?s=140&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png"];
  [photoImage setImage:image];
  [image release];
  
  if(status.isZombie) {
    ZombieView.hidden = NO;
    
    // TODO: use some type of status.zombieVenueTypeCount property
    int venueCount = 3;
    venueType1Image.hidden = (venueCount > 0) ? NO : YES;
    if(!venueType1Image.hidden) {
      UIImage* image = [self newImageFromURL: status.category1];
      venueType1Image.image = image;
      [image release];
    }
    venueType2Image.hidden = (venueCount > 0) ? NO : YES;
    if(!venueType2Image.hidden) {
      UIImage* image = [self newImageFromURL: status.category2];
      venueType2Image.image = image;
      [image release];
    }
    venueType3Image.hidden = (venueCount > 0) ? NO : YES;
    if(!venueType3Image.hidden) {
      UIImage* image = [self newImageFromURL: status.category3];
      venueType3Image.image = image;
      [image release];
    }
    venueType4Image.hidden = (venueCount > 0) ? NO : YES;
    if(!venueType4Image.hidden) {
      UIImage* image = [self newImageFromURL: status.category4];
      venueType4Image.image = image;
      [image release];
    }
    venueType5Image.hidden = YES; // this one doesn't ever exist I guess
//    if(!venueType5Image.hidden) {
//      UIImage* image = [self newImageFromURL: status.category5];
//      venueType5Image.image = image;
//      [image release];
//    }

    zombieReasonTextView.text = [NSString stringWithFormat:@"%@ has been overcome by the horde at %@!", @"Player Name", @"Venue Name"];
    
    
  } else {
    
    timeRemainingLabel1.text = [NSString stringWithFormat: @"%i:%i:%i", status.hours, status.minutes, status.seconds];
    [self sizeLabel: timeRemainingLabel1];
    
    venueStatusTextView.text = [NSString stringWithFormat: @"%@ STATISTICS:\n\nZombies killed: %i/%i\nOther survivors: %i", status.lastVenueName, status.zedsKilled, status.zeds, status.fellowSurvivors];
    
    AliveView.hidden = NO;
  }
}

- (UIImage*) newImageFromURL: (NSString*) url {
  NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
  UIImage* image = [[UIImage alloc] initWithData:imageData];
  [imageData release];
  return image;
}

- (IBAction)onCheckinAlive:(id)sender {
  status.isZombie = YES;
  [self refreshStatusView];
}

- (IBAction)onCheckinZombie:(id)sender {
  [status checkinZombie:self];
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
  //[timeRemainingLabel3 release];
  [ZombieView release];
  [AliveView release];
  [venueType1Image release];
  [venueType2Image release];
  [venueType3Image release];
  [venueType4Image release];
  [venueType5Image release];
  [photoImage release];
  [photoOverlayImage release];
  [zombieReasonTextView release];
  [venueStatusTextView release];
  [super dealloc];
}
@end
