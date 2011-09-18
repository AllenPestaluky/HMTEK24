//
//  FoursquareCheckinList.m
//
//  Created by Ian MacDonald on 2011/APR/13
//

#import "FoursquareCheckinList.h"
#import "GlossyButton.h"
#import "FoursquareShoutList.h"
#import "FSRoundedRectView.h"

@interface FoursquareCheckinList ()

- (void)click:(id)sender;

@end

static NSMutableDictionary *categoryIcons = nil;

@implementation FoursquareCheckinList

- (id)initWithList:(NSArray *)list shoutList:(NSArray *)shouts {
  if (categoryIcons == nil) {
    categoryIcons = [[NSMutableDictionary alloc] init];
  }
	if ((self = [super initWithList:list])) {
    shoutList = [shouts retain];
	}
	return self;
}

- (void)dealloc {
  [shoutList release];
  [super dealloc];
}

- (void)setupListButtons {
	CGFloat h = scroller.frame.size.height;
	CGRect base = CGRectMake(FLD_BUTTON_SIDE_PADDING, FLD_BUTTON_TOP_PADDING, scroller.frame.size.width - FLD_BUTTON_SIDE_PADDING * 2, FLD_BUTTON_HEIGHT);
	for (NSDictionary *group in _list) {
		NSArray *items = [group valueForKey:@"items"];
		for (NSDictionary *item in items) {
      NSString *buttonTitle = [item valueForKey:@"name"];
			GlossyButton *button = [[GlossyButton alloc] initWithFrame:base];
      NSArray *catArray = (NSArray *)[item valueForKey:@"categories"];
      if ([catArray count] > 0) {
        NSString *url = (NSString *)[(NSDictionary *)[catArray objectAtIndex:0] valueForKey:@"icon"];
        if ([categoryIcons objectForKey:url] == nil) {
          [categoryIcons setObject:[[UIImage alloc] initWithData:[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]]] forKey:url];
        }
        UIImage *buttonImage = (UIImage *)[categoryIcons objectForKey:url];
        [button setImage:buttonImage forState:UIControlStateNormal];
      }
      button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
      
      CGSize textSize = { button.frame.size.width, 1000.0f };		// width and height of button
      CGSize size = [buttonTitle sizeWithFont:button.titleLabel.font constrainedToSize:textSize];
      
      size.height += 10.0f;			// top and bottom margin
      
      if (size.height > FLD_BUTTON_HEIGHT) {
        CGRect buttonFrame = button.frame;
        buttonFrame.size.height = size.height;
        button.frame = buttonFrame;
      }
      
			[button setTitle:buttonTitle forState:UIControlStateNormal];
			[[button layer] setValue:[item valueForKey:@"id"] forKey:@"4sq_location_id"];
			[button addTarget:self action:@selector(click:)
			 forControlEvents:UIControlEventTouchUpInside];
			[scroller addSubview:button];
			base.origin.y += button.frame.size.height + FLD_BUTTON_PADDING;
			[button release];
			h = base.origin.y;
		}
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
  if (shoutList != nil) {
    [self dismissToLeft];
    [FoursquareShoutList showShout:self.delegate shoutList:shoutList venueID:[[sender layer] valueForKey:@"4sq_location_id"] callback:self.checkinCallback];
  }
  else {
    [self dismissToBottom];
    NSString* shout = [NSString stringWithFormat:@"I'm playing %@ on iOS!", [Foursquare2 getHashTag]];
    shout = [Foursquare2 appendGameURLForShouts:shout];
    [Foursquare2  createCheckinAtVenueID:[[sender layer] valueForKey:@"4sq_location_id"]
                                   venue:nil
                                   shout:shout
                               broadcast:BROADCAST_DEFAULT
                                callback:^(BOOL success, id result){
                                  self.checkinCallback(success, result);
                                  [self.checkinCallback release];
                                }];
  }
}

+ (void)doShowCheckin:(UIViewController*)controller
             groupList:(NSArray *)list shoutList:(NSArray *)shouts
              callback:(Foursquare2Callback)callback {
	FoursquareCheckinList *checkinCon = [[FoursquareCheckinList alloc] initWithList:list shoutList:shouts];
  checkinCon.checkinCallback = [callback copy];
	checkinCon.delegate = controller;
	
	[controller.view addSubview:checkinCon];
  
  [checkinCon showFromBottom];
	[checkinCon release];
}

+ (void)doShowCheckin:(UIViewController*)controller shoutList:shouts
              callback:(Foursquare2Callback)callback {
	[Foursquare2 searchVenuesNearByQuery:nil
								   limit:@"10"
								  intent:@"checkin"
								callback:^(BOOL success, id result){
									if (success) {
										[FoursquareCheckinList doShowCheckin:controller
                                               groupList:[(NSDictionary*)[(NSDictionary*)result valueForKey:@"response"] valueForKey:@"groups"]
                                               shoutList:shouts
                                                callback:callback];
									}
                  else {
                    callback(success, result);
                  }
								}];
	
}

+ (void)showCheckin:(UIViewController*)controller shoutList:(NSArray *)shouts 
            callback:(Foursquare2Callback)callback {
	if ([Foursquare2 isNeedToAuthorize]) {
		[FoursquareWebLogin authorizeWithViewController:controller 
											   Callback:^(BOOL success,id result){
												   if (success) {
                             callback(YES, nil);
													   [FoursquareCheckinList doShowCheckin:controller shoutList:shouts callback:callback];
												   }
											   }];
	} else {
		[FoursquareCheckinList doShowCheckin:controller shoutList:shouts callback:callback];
	}
}

- (NSString *)title {
  return @"Where are you?";
}

@end
