    //
//  ElanceWebLogin.m
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FoursquareWebLogin.h"
#import "Foursquare2.h"


@implementation FoursquareWebLogin
@synthesize delegate;
@synthesize selector;
@synthesize authorizeCallbackDelegate;

#define DEFAULT_HEIGHT 48

@synthesize navigationBar;
@synthesize webView;
@synthesize activityIndicator;

- (id) initWithUrl:(NSString*)url
{
	self = [super init];
	if (self != nil) {
		_url = url;
	}
	return self;
}

-(void)cancel{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSString *url =[[request URL] absoluteString];
	if ([url rangeOfString:@"access_token="].length != 0 || [url rangeOfString:@"code="].length != 0) {
		
		NSHTTPCookie *cookie;
		NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		for (cookie in [storage cookies]) {
			if ([[cookie domain]isEqualToString:@"foursquare.com"]) {
				[storage deleteCookie:cookie];
			}
		}
		
		NSArray *arr = [url componentsSeparatedByString:@"="];
    if ([arr count] <= 1) return NO; //NSArray bounds check
		[self performSelector:selector withObject:[arr objectAtIndex:0] withObject:[arr objectAtIndex:1]];
		[self cancel];
	}else if ([url rangeOfString:@"error="].length != 0) {
		NSArray *arr = [url componentsSeparatedByString:@"="];
    if ([arr count] <= 1) return NO; //NSArray bounds check
		[self performSelector:selector withObject:[arr objectAtIndex:0] withObject:[arr objectAtIndex:1]];
		NSLog(@"Foursquare: %@",[arr objectAtIndex:1]);
	} 
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webViewI{
	[activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webViewI{
	[activityIndicator stopAnimating];
	
	
	NSString *htmlTitle = [webViewI stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self setNavigationBarTitle:htmlTitle];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.webView = nil;
	self.navigationBar = nil;
	self.activityIndicator = nil;
	
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([self.view respondsToSelector:@selector(setContentScaleFactor:)]) {
		[self.view setContentScaleFactor:2];
	}
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	[self.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	
	int width = self.view.bounds.size.width;
	int height = self.view.bounds.size.height;
	
	// Initialize the navigation bar
	UINavigationBar* bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, width, DEFAULT_HEIGHT)];
	self.navigationBar = bar;
	[bar release];
	[navigationBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:@"Loading..."] animated:NO];
	[navigationBar setDelegate:self];
	navigationBar.topItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style: UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(navBarAction:)];
	navigationBar.barStyle = UIBarStyleBlack;
	[navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:navigationBar];
	
	// Initialize the webview
	UIWebView* webV = [[UIWebView alloc] initWithFrame:CGRectMake(0, DEFAULT_HEIGHT, width, height - DEFAULT_HEIGHT)];
	self.webView = webV;
	[webV release];
	if ([webView respondsToSelector:@selector(setContentScaleFactor:)]) {
		[webView setContentScaleFactor:2];
	}
	[webView setDelegate:self];
	[webView setBackgroundColor:[UIColor darkGrayColor]];
	[webView setCenter:CGPointMake(width/2, DEFAULT_HEIGHT + (height - DEFAULT_HEIGHT)/2)];
	webView.scalesPageToFit = YES;
	[webView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	//[webView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)]; // can use this to center the webview and keep same width
	[self.view addSubview:webView];
	
	
	//Initialize the activity indicator
	UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
	self.activityIndicator = aiv;
	[aiv release];
	[activityIndicator setCenter:CGPointMake(width/2, (height - DEFAULT_HEIGHT)/2)];
	[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin)];
	[webView addSubview:activityIndicator];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
	[webView loadRequest:request];

}



+(void)authorizeWithViewController:(UIViewController*)controller
						  Callback:(Foursquare2Callback)callback{
	NSString *url = [Foursquare2 getAuthenticateURL];
	FoursquareWebLogin *loginCon = [[FoursquareWebLogin alloc] initWithUrl:url];
	loginCon.delegate = controller;
	loginCon.selector = @selector(selectKey:andValue:);
	loginCon.authorizeCallbackDelegate = [callback copy];
	
	[controller presentModalViewController:loginCon animated:YES];
	[loginCon release];	
}

-(void)selectKey:(NSString*)key andValue:(NSString*)value{
	if ([key rangeOfString:@"access_token"].length != 0) {
		[self setToken:value Result:nil];
	} else if ([key rangeOfString:@"code"].length != 0) {
		[Foursquare2 getAccessTokenForCode:value callback:^(BOOL success,id result){
			if (success) {
				[self setToken:[result objectForKey:@"access_token"] Result:result];
			}
		}];
	}
}

- (void)setToken:(NSString *)token Result:(id)result {
	[Foursquare2 setBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
	[Foursquare2 setAccessToken:token];
	authorizeCallbackDelegate(YES,result);
	[authorizeCallbackDelegate release];
}


- (void) setNavigationBarTitle:(NSString *)title {
	navigationBar.topItem.title = title;
}

///////////////////////////////////////////////////////
// UINavigationBarDelegate methods
///////////////////////////////////////////////////////

///////////////////////////////////////////////////////
//- (void)navBarAction:
//Called when a user touches a button on the 
//navigation bar.
//////////////////////////////////////////////////////
- (IBAction)navBarAction:(id)sender {
	if( sender == navigationBar.topItem.leftBarButtonItem )
	{
		[self.delegate dismissModalViewControllerAnimated:YES];
	}
}


@end
