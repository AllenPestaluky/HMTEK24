//
//  FoursquareShoutList.m
//  Libraries
//
//  Created by iphonedev2 on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FoursquareShoutList.h"
#import "GlossyButton.h"
#import "FSRoundedRectView.h"

@interface FoursquareShoutList ()

- (void)click:(id)sender;

@end


@implementation FoursquareShoutList

- (id)initWithList:(NSArray *)list venueID:(NSString *)venue {
	if ((self = [super initWithList:list])) {
    venueID = [venue retain];
	}
	return self;
}

- (void)dealloc {
  [venueID release];
  [super dealloc];
}

- (void)setupListButtons {
	CGFloat h = scroller.frame.size.height;
	CGRect base = CGRectMake(FLD_BUTTON_SIDE_PADDING, FLD_BUTTON_TOP_PADDING, scroller.frame.size.width - FLD_BUTTON_SIDE_PADDING * 2, FLD_BUTTON_HEIGHT);
	for (NSString *shout in _list) {
    GlossyButton *button = [[GlossyButton alloc] initWithFrame:base];
    button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    CGSize textSize = { button.frame.size.width, 1000.0f };		// width and height of button
		CGSize size = [shout sizeWithFont:button.titleLabel.font constrainedToSize:textSize];
    
		size.height += 10.0f;			// top and bottom margin
    
    if (size.height > FLD_BUTTON_HEIGHT) {
      CGRect buttonFrame = button.frame;
      buttonFrame.size.height = size.height;
      button.frame = buttonFrame;
    }
    
    [button setTitle:shout forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [scroller addSubview:button];
    base.origin.y += button.frame.size.height + FLD_BUTTON_PADDING;
    h = base.origin.y;
    [button release];
	}
	
	base = scroller.frame;
	base.size.height = h - FLD_BUTTON_PADDING + FLD_BUTTON_TOP_PADDING;
	[scroller setContentSize:base.size];
  
  if (base.size.height < scroller.frame.size.height) {
    CGRect dialogFrame = dialogView.frame;
    dialogFrame.size.height = base.size.height + FLD_TITLE_HEIGHT + FLD_SCROLLER_PADDING + FLD_BUTTON_HEIGHT + FLD_BUTTON_PADDING;
    dialogFrame.origin.y = (self.bounds.size.height - dialogFrame.size.height) / 2;
    dialogView.frame = dialogFrame;
    
    CGRect scrollerFrame = scroller.frame;
    scrollerFrame.size.height = base.size.height;
    scroller.frame = scrollerFrame;
  }
}

#pragma mark Checkin methods

- (void)click:(id)sender {
  [self dismissToBottom];
	[Foursquare2  createCheckinAtVenueID:venueID
                                 venue:nil
                                 shout:[sender titleForState:UIControlStateNormal]
                             broadcast:BROADCAST_DEFAULT
                              callback:^(BOOL success, id result){
                                self.checkinCallback(success, result);
                                [self.checkinCallback release];
                              }];
}

+ (void)showShout:(UIViewController*)controller shoutList:(NSArray *)list venueID:(NSString *)venue callback:(Foursquare2Callback)callback {
	FoursquareShoutList *shoutCon = [[FoursquareShoutList alloc] initWithList:list venueID:venue];
  shoutCon.checkinCallback = [callback copy];
	shoutCon.delegate = controller;
	
	[controller.view addSubview:shoutCon];
  
  [shoutCon showFromRight];
	[shoutCon release];
}

- (NSString *)title {
  return @"Shout";
}

- (NSString *)backButtonTitle {
  return @"Cancel";
}

@end
