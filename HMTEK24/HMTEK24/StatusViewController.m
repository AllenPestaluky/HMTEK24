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
#import "Foursquare2.h"

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
  
  ZombieView.hidden = YES;
  AliveView.hidden = YES;
  
//  timeRemainingLabel3 = [self newLabel:NO];
//  tempFrame = timeRemainingLabel1.frame;
//  tempFrame.origin.y = startingY + lineHeight *2;
//  timeRemainingLabel3.frame = tempFrame;
  
//  defaultVenuIcon = [[UIImage alloc] initWithContentsOfFile:@"Resources/default_venue_64.png"];
//  photoOverlay1 = [[UIImage alloc] initWithContentsOfFile:@"Resources/Layer_1_Normal.png"];
//  photoOverlay2 = [[UIImage alloc] initWithContentsOfFile:@"Resources/Layer_2.png"];
//  photoOverlay3 = [[UIImage alloc] initWithContentsOfFile:@"Resources/Layer_3.png"];
  //  photoOverlay4 = [[UIImage alloc] initWithContentsOfFile:@"Resources/Layer_4_Zombie.png"];
  defaultVenuIcon = [[UIImage imageNamed:@"default_venue_64.png"] retain];
  photoOverlay1 = [[UIImage imageNamed:@"Layer_1_Normal.png"] retain];
  photoOverlay2 = [[UIImage imageNamed:@"Layer_2.png"] retain];
  photoOverlay3 = [[UIImage imageNamed:@"Layer_3.png"] retain];
  photoOverlay4 = [[UIImage imageNamed:@"Layer_4_Zombie.png"] retain];

  //[status getZombieStatus:self]; // cause this will never be accurate anyway
  
  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

-(void) tick {
  [status recalcTTL:self fastRefresh: YES];
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
  
  [photoOverlay1 release];
  photoOverlay1 = nil;
  [photoOverlay2 release];
  photoOverlay2 = nil;
  [photoOverlay3 release];
  photoOverlay3 = nil;
  [photoOverlay4 release];
  photoOverlay4 = nil;
  
  [defaultVenuIcon release];
  defaultVenuIcon = nil;
  
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

- (void) viewDidAppear:(BOOL)animated {
  if(self.status == nil) {
    self.status = [[[PlayerStatus alloc] initWithStatusViewController:self] autorelease];
  }
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

- (void)refreshStatusView: (BOOL) fastRefresh {
  if(!fastRefresh) {
    NSLog(@"status description:\n%@", [status description]);
  }
  
  // First hide everything:
  ZombieView.hidden = YES;
  AliveView.hidden = YES;
  
  if(!fastRefresh) {
    UIImage* image = [self newImageFromURL: status.playerIcon];
    [photoImage setImage:image];
    [image release];
  }
  
  
  if(status.isZombie) {
    ZombieView.hidden = NO;
    
    float dimAlphaValue = 0.25;
    venueType1Image.alpha = status.category1 == nil ? dimAlphaValue : 1.0;
    venueType2Image.alpha = status.category2 == nil ? dimAlphaValue : 1.0;
    venueType3Image.alpha = status.category3 == nil ? dimAlphaValue : 1.0;
    venueType4Image.alpha = status.category4 == nil ? dimAlphaValue : 1.0;
    venueType5Image.alpha = dimAlphaValue; // this one doesn't ever exist I guess
    
    if(!fastRefresh) {
      if(status.category1 == nil) {
        UIImage* image = [self newImageFromURL: status.category1];
        if(image) {
        venueType1Image.image = image;
        }
        [image release];
      } else {
        venueType1Image.image = defaultVenuIcon;
      }
      if(status.category2 == nil) {
        UIImage* image = [self newImageFromURL: status.category2];
        if(image) {
          venueType2Image.image = image;
        }
        [image release];
      } else {
        venueType2Image.image = defaultVenuIcon;
      }
      if(status.category3 == nil) {
        UIImage* image = [self newImageFromURL: status.category3];
        if(image) {
          venueType3Image.image = image;
        }
        [image release];
      } else {
        venueType3Image.image = defaultVenuIcon;
      }
      if(status.category4 == nil) {
        UIImage* image = [self newImageFromURL: status.category4];
        if(image) {
          venueType4Image.image = image;
        }
        [image release];
      } else {
        venueType4Image.image = defaultVenuIcon;
      }
    }
//    if(!venueType5Image.hidden) {
//      UIImage* image = [self newImageFromURL: status.category5];
//      venueType5Image.image = image;
//      [image release];
//    }

    zombieReasonTextView.text = [NSString stringWithFormat:@"%@ has been overcome by the horde at %@!", status.playerName, status.zombifiedVenue];
    
    
  } else {
    float zombification = ((status.lastCheckinTime - status.zombieTime) / (18* 3600));
    
    if(zombification > 0.75) {
      photoOverlayImage.image = photoOverlay1;
    } else if (zombification > 0.5) {
      photoOverlayImage.image = photoOverlay2;
    } else if (zombification > 0.25) {
      photoOverlayImage.image = photoOverlay3;
    } else {
      photoOverlayImage.image = photoOverlay4;
    }
    
    timeRemainingLabel1.text = [NSString stringWithFormat: @"%02i:%02i:%02i", status.hours, status.minutes, status.seconds];
    [self sizeLabel: timeRemainingLabel1];
    
    venueStatusTextView.text = [NSString stringWithFormat: @"%@:\n\nZombies killed: %i/%i\nOther survivors: %i", status.lastVenueName, status.zedsKilled, status.zeds, status.fellowSurvivors];
    
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
  [status checkin:self];
}

- (IBAction)onCheckinZombie:(id)sender {
  [status checkin:self];
}

-(void) sizeLabel: (UILabel*) label {
  [label sizeToFit];
  CGRect newFrame = label.frame;
  newFrame.origin.x = self.view.frame.size.width / 2 - newFrame.size.width / 2;
  label.frame = newFrame;
}

- (void)dealloc {
  [photoOverlay1 release];
  [photoOverlay2 release];
  [photoOverlay3 release];
  [photoOverlay4 release];
  [defaultVenuIcon release];
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
