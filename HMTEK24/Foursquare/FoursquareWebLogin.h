//
//  ElanceWebLogin.h
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"

@interface FoursquareWebLogin : UIViewController <UINavigationBarDelegate, UIWebViewDelegate> {
	NSString *_url;
	UIWebView *webView;
	id delegate;
	SEL selector;
}


@property (nonatomic, retain) UINavigationBar* navigationBar;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) UIWebView* webView;

@property(nonatomic,assign) id delegate;
@property(nonatomic,assign) SEL selector;
@property(nonatomic,assign) Foursquare2Callback authorizeCallbackDelegate;
- (id) initWithUrl:(NSString*)url;
- (void) setNavigationBarTitle:(NSString *)title;
+(void)authorizeWithViewController:(UIViewController*)controller
						  Callback:(Foursquare2Callback)callback;
-(void)selectKey:(NSString*)key andValue:(NSString*)value;
-(void)setToken:(NSString *)token Result:(id)result;
@end
