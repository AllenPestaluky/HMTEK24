//
//  FoursquareShoutList.h
//  Libraries
//
//  Created by iphonedev2 on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoursquareListDialog.h"
#import "Foursquare2.h"

@interface FoursquareShoutList : FoursquareListDialog {
  NSString *venueID;
}

- (id)initWithList:(NSArray *)list venueID:(NSString *)venue;

+ (void)showShout:(UIViewController*)controller shoutList:(NSArray *)list venueID:(NSString *)venue callback:(Foursquare2Callback)callback;

@end
