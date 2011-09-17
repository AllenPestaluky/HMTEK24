//
//  FoursquareCheckinList.h
//  
//  Created by Ian MacDonald on 2011/APR/13
//

#import <UIKit/UIKit.h>
#import "FoursquareListDialog.h"
#import "FoursquareWebLogin.h"
#import "Foursquare2.h"

@interface FoursquareCheckinList : FoursquareListDialog {
  NSArray *shoutList;
}

- (id)initWithList:(NSArray *)list shoutList:(NSArray *)shouts;

+ (void)showCheckin:(UIViewController*)controller shoutList:(NSArray *)shouts
           callback:(Foursquare2Callback)callback;

@end
