//
//  Foursquare2.m
//  Foursquare API
//
//  Created by Constantine Fry on 1/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Foursquare2.h"



@interface Foursquare2 (PrivateAPI)
+ (void)        get:(NSString *)methodName
         withParams:(NSDictionary *)params 
		   callback:(Foursquare2Callback)callback;

+ (void)       post:(NSString *)methodName
		 withParams:(NSDictionary *)params
		   callback:(Foursquare2Callback)callback;

+ (void)    request:(NSString *)methodName 
	     withParams:(NSDictionary *)params 
	     httpMethod:(NSString *)httpMethod
		   callback:(Foursquare2Callback)callback;

+ (void)    uploadPhoto:(NSString *)methodName 
			 withParams:(NSDictionary *)params 
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
			  withImage:(NSImage*)image
#else
			  withImage:(UIImage*)image
#endif
			   callback:(Foursquare2Callback)callback;

+(void)setAccessToken:(NSString*)token;
+(NSString*)problemTypeToString:(FoursquareProblemType)problem;
+(NSString*)broadcastTypeToString:(int)broadcast;
+(void)getBroadcastDefault:(Foursquare2Callback)callback;
+(void)resolveBroadcastType:(int)broadcast callback:(Foursquare2Callback)callback;
+(NSString*)sortTypeToString:(FoursquareSortingType)type;
// Declared in HRRestModel
+ (void)setAttributeValue:(id)attr forKey:(NSString *)key;
+ (NSMutableDictionary *)classAttributes;
@end

@implementation Foursquare2


static NSString* hashTag = nil;
static NSString* gameURL = nil; // for advertising the game, ie. the store page
static NSString* oauthKey = nil;
static NSString* oauthSecret = nil;
static NSString* redirectURL = nil;

+(void)checkConstants
{
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:@"FoursquareConfig.plist"];
	NSDictionary* plistDictionary = [NSDictionary dictionaryWithContentsOfFile:finalPath];

	hashTag     = [[plistDictionary valueForKey:@"FOURSQUARE_HASH_TAG"] copy];
	gameURL     = [[plistDictionary valueForKey:@"FOURSQUARE_GAME_URL"] copy];
	oauthKey    = [[plistDictionary valueForKey:@"FOURSQUARE_OAUTH_KEY"] copy];
	oauthSecret = [[plistDictionary valueForKey:@"FOURSQUARE_OAUTH_SECRET"] copy];
	redirectURL = [[plistDictionary valueForKey:@"FOURSQUARE_REDIRECT_URL"] copy];
}

+(NSString*)getHashTag
{
	return hashTag;
}

+(NSString*)getGameURL
{
	return gameURL;
}

+(NSString*)getAuthenticateURL
{
	return [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?display=touch&client_id=%@&response_type=token&redirect_uri=%@", oauthKey, redirectURL];
}

/** Appends a space followed by the game URL to a string only if the resulting string is less than
 140 characters. Otherwise, returns the input string
 */
+ (NSString*)appendGameURLForShouts: (NSString*) shout {
  if(([shout length] + 1 + [[Foursquare2 getGameURL] length]) <= 140) { // 140 is the max length of shouts for foursquare
    shout = [NSString stringWithFormat:@"%@ %@", shout, [self getGameURL]];
  }
  return shout;
}

+ (void)initialize
{
	CLLocationManager *loc = [[CLLocationManager alloc] init];
	loc.delegate = self;
	loc.distanceFilter = kCLDistanceFilterNone;
	loc.desiredAccuracy = kCLLocationAccuracyBest;
	[loc startUpdatingLocation];
	
	[self setFormat:HRDataFormatJSON];
	[self setDelegate:self];
	[self setBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
	NSUserDefaults *usDef = [NSUserDefaults standardUserDefaults];
	if ([usDef objectForKey:@"access_token"] != nil) {
		[[self classAttributes] setObject:[usDef objectForKey:@"access_token"] forKey:@"access_token"];
	}
}

+(void)getAccessTokenForCode:(NSString*)code callback:(id)callback{
	[self setBaseURL:[NSURL URLWithString:@"https://foursquare.com"]];
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:code forKey:@"code"];
	[dic setObject:@"authorization_code" forKey:@"grant_type"];
	[dic setObject:redirectURL forKey:@"redirect_uri"];
	[self get:@"oauth2/access_token" withParams:dic callback:callback];
}

+(void)setAccessToken:(NSString*)token{
	[[self classAttributes] setObject:token forKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults]setObject:token forKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

+(void)removeAccessToken{
	[[self classAttributes]removeObjectForKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

+(BOOL)isNeedToAuthorize{
	return ([[self classAttributes] objectForKey:@"access_token"] == nil);
}

static CLLocation* currentLocation;
+(void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation {
	currentLocation = [newLocation copy];
}


+(NSString*)stringFromArray:(NSArray*)array{
	NSMutableString * str = [NSMutableString string];
	if ([array count]!= 0) {
		for (NSString* p in array) {
			[str appendFormat:@"%@",p];
			
			if (p != [array lastObject]) {
				[str appendString:@","];
			}
		}
	}
	return str;
}
#pragma mark -
#pragma mark Users

+(void)getDetailForUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@",userID];
	[self get:path withParams:nil callback:callback];
}

+(void)searchUserPhone:(NSArray*)phones
				 email:(NSArray*)emails
			   twitter:(NSArray*)twitters
		 twitterSource:(NSString*)twitterSource
		   facebookIDs:(NSArray*)fbid
				  name:(NSString*)name
			  callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:[self stringFromArray:phones] forKey:@"phone"];
	[dic setObject:[self stringFromArray:emails] forKey:@"email"];
	[dic setObject:[self stringFromArray:twitters] forKey:@"twitter"];
	if (twitterSource) {
		[dic setObject:twitterSource forKey:@"twitterSource"];
	}
	[dic setObject:[self stringFromArray:fbid] forKey:@"fbid"];
	if (name) {
		[dic setObject:name forKey:@"name"];
	}
	[self get:@"users/search" withParams:dic callback:callback];
}

+(void)getFriendRequestsCallback:(Foursquare2Callback)callback
{
	[self get:@"users/requests" withParams:nil callback:callback];
}

#pragma mark Aspects


+(void)getBadgesForUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/badges",userID];
	[self get:path withParams:nil callback:callback];
}

+(void)getCheckinsByUser:(NSString*)userID
				   limit:(NSString*)limit
				  offset:(NSString*)offset
		  afterTimestamp:(NSString*)afterTimestamp
		 beforeTimestamp:(NSString*)beforeTimestamp
				callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		[dic setObject:limit forKey:@"limit"];
	}
	if (offset) {
		[dic setObject:offset forKey:@"offset"];
	}
	if (afterTimestamp) {
		[dic setObject:afterTimestamp forKey:@"afterTimestamp"];
	}
	if (beforeTimestamp) {
		[dic setObject:beforeTimestamp forKey:@"beforeTimestamp"];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/checkins",userID];
	[self get:path withParams:dic callback:callback];
	
}

+(void)getFriendsOfUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/friends",userID];
	[self get:path withParams:nil callback:callback];
}



+(void)getTipsFromUser:(NSString*)userID
				  sort:(FoursquareSortingType)sort
			  latitude:(NSString*)lat
			 longitude:(NSString*)lon
			  callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (sort) {
		[dic setObject:[self sortTypeToString:sort] forKey:@"sort"];
	}
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/tips",userID];
	[self get:path withParams:dic callback:callback];
}

+(void)getTodosFromUser:(NSString*)userID
				   sort:(FoursquareSortingType)sort
			   latitude:(NSString*)lat
			  longitude:(NSString*)lon
			   callback:(Foursquare2Callback)callback
{
	if (sort == sortNearby) {
		callback(NO, @"sort is one of recent or popular. Nearby requires geolat and geolong to be provided.");
		return;
	}
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (sort) {
		[dic setObject:[self sortTypeToString:sort] forKey:@"sort"];
	}
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/todos",userID];
	[self get:path withParams:dic callback:callback];
}


+(void)getVenuesVisitedByUser:(NSString*)userID
					 callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/venuehistory",userID];
	[self get:path withParams:nil callback:callback];
}

#pragma mark Actions

+(void)sendFriendRequestToUser:(NSString*)userID
					  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/request",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)removeFriend:(NSString*)userID
		   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/unfriend",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)approveFriend:(NSString*)userID
			callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/approve",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)denyFriend:(NSString*)userID
		 callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/deny",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)setPings:(BOOL)value
	  forFriend:(NSString*)userID
	   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/setpings",userID];
	NSDictionary *params = [NSDictionary dictionaryWithObject:value?@"true":@"false"
													   forKey:@"value"];
	[self post:path withParams:params callback:callback];
}

#pragma mark -


#pragma mark Venues

+(void)getDetailForVenue:(NSString*)venueID
				callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"venues/%@",venueID];
	[self get:path withParams:nil callback:callback];
}

+(void)addVenueWithName:(NSString*)name
				address:(NSString*)address
			crossStreet:(NSString*)crossStreet
				   city:(NSString*)city
				  state:(NSString*)state
					zip:(NSString*)zip
				  phone:(NSString*)phone
			   latitude:(NSString*)lat
			  longitude:(NSString*)lon
	  primaryCategoryId:(NSString*)primaryCategoryId
			   callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (name) {
		[dic setObject:name forKey:@"name"];
	}
	if (address) {
		[dic setObject:address forKey:@"address"];
	}
	if (crossStreet) {
		[dic setObject:crossStreet forKey:@"crossStreet"];
	}
	if (city) {
		[dic setObject:city forKey:@"city"];
	}
	if (state) {
		[dic setObject:state forKey:@"state"];
	}
	if (zip) {
		[dic setObject:name forKey:@"zip"];
	}
	if (phone) {
		[dic setObject:name forKey:@"phone"];
	}
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	if (primaryCategoryId) {
		[dic setObject:primaryCategoryId forKey:@"primaryCategoryId"];
	}
	[self post:@"venues/add" withParams:dic callback:callback];
}

+(void)getVenueCategoriesCallback:(Foursquare2Callback)callback
{
	[self get:@"venues/categories" withParams:nil callback:callback];
}

+(void)searchVenuesNearByQuery:(NSString*)query
						 limit:(NSString*)limit
						intent:(NSString*)intent
					  callback:(Foursquare2Callback)callback
{
	NSString *lat = nil;
	NSString *lon = nil;
	NSString *accuracyLL = nil;
	NSString *altitude = nil;
	NSString *accuracyAlt = nil;
	if (currentLocation) {
		lat = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
		lon = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
		accuracyLL = [NSString stringWithFormat:@"%f", currentLocation.horizontalAccuracy];
		altitude = [NSString stringWithFormat:@"%f", currentLocation.altitude];
		accuracyAlt = [NSString stringWithFormat:@"%f", currentLocation.verticalAccuracy];
	}
	[Foursquare2 searchVenuesNearByLatitude:lat
								  longitude:lon
								 accuracyLL:accuracyLL
								   altitude:altitude
								accuracyAlt:accuracyAlt
									  query:query
									  limit:limit
									 intent:intent
								   callback:callback];
}

+(void)searchVenuesNearByLatitude:(NSString*)lat
						longitude:(NSString*)lon
					   accuracyLL:(NSString*)accuracyLL
						 altitude:(NSString*)altitude
					  accuracyAlt:(NSString*)accuracyAlt
							query:(NSString*)query
							limit:(NSString*)limit
						   intent:(NSString*)intent
						 callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	if (accuracyLL) {
		[dic setObject:accuracyLL forKey:@"llAcc"];
	}
	if (altitude) {
		[dic setObject:altitude forKey:@"alt"];
	}
	if (accuracyAlt) {
		[dic setObject:accuracyAlt forKey:@"altAcc"];
	}
	if (query) {
		[dic setObject:query forKey:@"query"];
	}
	if (limit) {
		[dic setObject:limit forKey:@"limit"];
	}
	if (intent) {
		[dic setObject:intent forKey:@"intent"];
	}
	[self get:@"venues/search" withParams:dic callback:callback];
}

#pragma mark Aspects
+(void)getVenueHereNow:(NSString*)venueID
				 limit:(NSString*)limit
				offset:(NSString*)offset
		afterTimestamp:(NSString*)afterTimestamp
			  callback:(Foursquare2Callback)callback
{
	if(nil == venueID){
		callback(NO,nil);
		return;
	}
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		[dic setObject:limit forKey:@"limit"];
	}
	if (offset) {
		[dic setObject:offset forKey:@"offset"];
	}
	if (afterTimestamp) {
		[dic setObject:afterTimestamp forKey:@"afterTimestamp"];
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/herenow",venueID];
	[self get:path withParams:dic callback:callback];
}

+(void)getTipsFromVenue:(NSString*)venueID
				   sort:(FoursquareSortingType)sort
			   callback:(Foursquare2Callback)callback
{
	if (nil == venueID || sort == sortNearby) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:[self sortTypeToString:sort] forKey:@"sort"];
	NSString *path = [NSString stringWithFormat:@"venues/%@/tips",venueID];
	[self get:path withParams:dic callback:callback];
}

#pragma mark Actions
+(void)markVenueToDo:(NSString*)venueID
				text:(NSString*)text
			callback:(Foursquare2Callback)callback
{
	if (nil == venueID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (text) {
		[dic setObject:text	forKey:@"text"];
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/marktodo",venueID];
	[self post:path withParams:dic callback:callback];
}

+(void)flagVenue:(NSString*)venueID
		 problem:(FoursquareProblemType)problem
		callback:(Foursquare2Callback)callback
{
	if (nil == venueID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:[self problemTypeToString:problem]	forKey:@"problem"];
	NSString *path = [NSString stringWithFormat:@"venues/%@/flag",venueID];
	[self post:path withParams:dic callback:callback];
}


+(void)proposeEditVenue:(NSString*)venueID
				   name:(NSString*)name
				address:(NSString*)address
			crossStreet:(NSString*)crossStreet
				   city:(NSString*)city
				  state:(NSString*)state
					zip:(NSString*)zip
				  phone:(NSString*)phone
			   latitude:(NSString*)lat
			  longitude:(NSString*)lon
	  primaryCategoryId:(NSString*)primaryCategoryId
			   callback:(Foursquare2Callback)callback
{
	if (nil ==venueID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (name) {
		[dic setObject:name forKey:@"name"];
	}
	if (address) {
		[dic setObject:address forKey:@"address"];
	}
	if (crossStreet) {
		[dic setObject:crossStreet forKey:@"crossStreet"];
	}
	if (city) {
		[dic setObject:city forKey:@"city"];
	}
	if (state) {
		[dic setObject:state forKey:@"state"];
	}
	if (zip) {
		[dic setObject:name forKey:@"zip"];
	}
	if (phone) {
		[dic setObject:name forKey:@"phone"];
	}
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	if (primaryCategoryId) {
		[dic setObject:primaryCategoryId forKey:@"primaryCategoryId"];
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/proposeedit",venueID];
	[self post:path withParams:dic callback:callback];
}

#pragma mark -

#pragma mark Checkins

+(void)getDetailForCheckin:(NSString*)checkinID
				  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"checkins/%@",checkinID];
	[self get:path withParams:nil callback:callback];
}

+(void)createCheckinAtVenueID:(NSString*)venueID
					    venue:(NSString*)venue
					    shout:(NSString*)shout
				    broadcast:(int)broadcast
				     callback:(Foursquare2Callback)callback
{
	NSString *lat = nil;
	NSString *lon = nil;
	NSString *accuracyLL = nil;
	NSString *altitude = nil;
	NSString *accuracyAlt = nil;
	if (currentLocation) {
		lat = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
		lon = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
		accuracyLL = [NSString stringWithFormat:@"%f", currentLocation.horizontalAccuracy];
		altitude = [NSString stringWithFormat:@"%f", currentLocation.altitude];
		accuracyAlt = [NSString stringWithFormat:@"%f", currentLocation.verticalAccuracy];
	}
	[Foursquare2 createCheckinAtVenue:venueID
								venue:venue
								shout:shout
							broadcast:broadcast
							 latitude:lat
							longitude:lon
						   accuracyLL:accuracyLL
							altitude:altitude
						  accuracyAlt:accuracyAlt
							 callback:callback];
	
}

+(void)createCheckinAtVenue:(NSString*)venueID
					  venue:(NSString*)venue
					  shout:(NSString*)shout
				  broadcast:(int)broadcast
				   latitude:(NSString*)lat
				  longitude:(NSString*)lon
				 accuracyLL:(NSString*)accuracyLL
				   altitude:(NSString*)altitude
				accuracyAlt:(NSString*)accuracyAlt
				   callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (venueID) {
		[dic setObject:venueID forKey:@"venueId"];
	}
	if (venue) {
		[dic setObject:venue forKey:@"venue"];
	}
	if (shout) {
		[dic setObject:shout forKey:@"shout"];
	}
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	if (accuracyLL) {
		[dic setObject:accuracyLL forKey:@"llAcc"];
	}
	if (altitude) {
		[dic setObject:altitude forKey:@"alt"];
	}
	if (accuracyAlt) {
		[dic setObject:accuracyAlt forKey:@"altAcc"];
	}
	
  [self resolveBroadcastType:broadcast callback:^(BOOL success, id result) {
    if (success) {
      [dic setObject:(NSString*)result forKey:@"broadcast"];
      
      [self post:@"checkins/add" withParams:dic callback:callback];
    }
    else {
      callback(NO, result);
    }
  }];
}

+(void)getRecentCheckinsByFriendsNearByLatitude:(NSString*)lat
									  longitude:(NSString*)lon
										  limit:(NSString*)limit
										 offset:(NSString*)offset
								 afterTimestamp:(NSString*)afterTimestamp
									   callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		[dic setObject:limit forKey:@"limit"];
	}
	if (offset) {
		[dic setObject:offset forKey:@"offset"];
	}
	if (afterTimestamp) {
		[dic setObject:afterTimestamp forKey:@"afterTimestamp"];
	}
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	
	[self get:@"checkins/recent" withParams:dic callback:callback];
}

#pragma mark Actions
+(void)addCommentToCheckin:(NSString*)checkinID
					  text:(NSString*)text
				  callback:(Foursquare2Callback)callback
{
	if (nil ==checkinID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (text) {
		[dic setObject:text forKey:@"text"];
	}
	NSString *path = [NSString stringWithFormat:@"checkins/%@/addcomment",checkinID];
	[self post:path withParams:dic callback:callback];
}

+(void)deleteComment:(NSString*)commentID
		  forCheckin:(NSString*)checkinID
			callback:(Foursquare2Callback)callback
{
	if (nil ==checkinID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (commentID) {
		[dic setObject:commentID forKey:@"commentId"];
	}
	NSString *path = [NSString stringWithFormat:@"checkins/%@/deletecomment",checkinID];
	[self post:path withParams:dic callback:callback];
}
#pragma mark -

#pragma mark Tips


+(void)getDetailForTip:(NSString*)tipID
			  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/",tipID];
	[self get:path withParams:nil callback:callback];
}


+(void)addTip:(NSString*)tip
	 forVenue:(NSString*)venueID
	  withURL:(NSString*)url
	 callback:(Foursquare2Callback)callback
{
	if (nil ==venueID || nil == tip) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:venueID forKey:@"venueId"];
	[dic setObject:tip forKey:@"text"];
	if(url)
		[dic setObject:url forKey:@"url"];
	
	[self post:@"tips/add" withParams:dic callback:callback];
}

+(void)searchTipNearbyLatitude:(NSString*)lat
					 longitude:(NSString*)lon
						 limit:(NSString*)limit
						offset:(NSString*)offset
				   friendsOnly:(BOOL)friendsOnly
						 query:(NSString*)query
					  callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		[dic setObject:limit forKey:@"limit"];
	}
	if (offset) {
		[dic setObject:offset forKey:@"offset"];
	}
	
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	if (friendsOnly) {
		[dic setObject:@"friends" forKey:@"filter"];
	}
	if (query) {
		[dic setObject:query forKey:@"query"];
	}
	
	[self get:@"tips/search" withParams:dic callback:callback];
}
#pragma mark Actions
+(void)markTipTodo:(NSString*)tipID
		  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/marktodo",tipID];
	[self post:path withParams:nil callback:callback];
}

+(void)markTipDone:(NSString*)tipID
		  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/markdone",tipID];
	[self post:path withParams:nil callback:callback];
}

+(void)unmarkTipTodo:(NSString*)tipID
			callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/unmark",tipID];
	[self post:path withParams:nil callback:callback];
}

#pragma mark -


#pragma mark Photos

+(void)getDetailForPhoto:(NSString*)photoID
				callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"photos/%@",photoID];
	[self get:path withParams:nil callback:callback];
}

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+(void)addPhoto:(NSImage*)photo
#else
+(void)addPhoto:(UIImage*)photo
#endif
	  toCheckin:(NSString*)checkinID
			tip:(NSString*)tipID
		  venue:(NSString*)venueID
	  broadcast:(int)broadcast
	   latitude:(NSString*)lat
	  longitude:(NSString*)lon
	 accuracyLL:(NSString*)accuracyLL
	   altitude:(NSString*)altitude
	accuracyAlt:(NSString*)accuracyAlt
	   callback:(Foursquare2Callback)callback;
{
	if (!checkinID && !tipID && !venueID) {
		callback(NO,nil);
		return;
	}
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (lat && lon) {
		[dic setObject:[NSString stringWithFormat:@"%@,%@",lat,lon] forKey:@"ll"];
	}
	if (accuracyLL) {
		[dic setObject:accuracyLL forKey:@"llAcc"];
	}
	if (altitude) {
		[dic setObject:altitude forKey:@"alt"];
	}
	if (accuracyAlt) {
		[dic setObject:accuracyAlt forKey:@"altAcc"];
	}

	if (checkinID) {
		[dic setObject:checkinID forKey:@"checkinId"];
	}
	if (tipID) {
		[dic setObject:tipID forKey:@"tipId"];
	}
	if (venueID) {
		[dic setObject:venueID forKey:@"venueId"];
	}
  
  [self resolveBroadcastType:broadcast callback:^(BOOL success, id result) {
    if (success) {
      [dic setObject:(NSString*)result forKey:@"broadcast"];
      
      [self uploadPhoto:@"photos/add"
             withParams:dic
              withImage:photo
               callback:callback];    }
  }];
}
#pragma mark -

#pragma mark Settings
+(void)getAllSettingsCallback:(Foursquare2Callback)callback
{
	[self get:@"settings/all" withParams:nil callback:callback];
}
+(void)setSendToTwitter:(BOOL)value
			   callback:(Foursquare2Callback)callback;
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:value?@"1":@"0" forKey:@"value"];
	[self post:@"settings/sendToTwitter/set" withParams:dic callback:callback];
}

+(void)setSendToFacebook:(BOOL)value
				callback:(Foursquare2Callback)callback;
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:value?@"1":@"0" forKey:@"value"];
	[self post:@"settings/sendToFacebook/set" withParams:dic callback:callback];
}

+(void)setReceivePings:(BOOL)value
			  callback:(Foursquare2Callback)callback;
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:value?@"1":@"0" forKey:@"value"];
	[self post:@"settings/receivePings/set" withParams:dic callback:callback];
}
#pragma mark -







#pragma mark HRRequestOperation Delegates
+ (void)restConnection:(NSURLConnection *)connection
	  didFailWithError:(NSError *)error 
				object:(id)object 
{
	Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(NO, error);
	[callback release];
}

+ (void)restConnection:(NSURLConnection *)connection 
	   didReceiveError:(NSError *)error 
			  response:(NSHTTPURLResponse *)response 
				object:(id)object 
{
	Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(NO, error);
	[callback release];
}

+ (void)restConnection:(NSURLConnection *)connection
  didReceiveParseError:(NSError *)error 
		  responseBody:(NSString *)string
				object:(id)object
{
	Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(NO, error);
	[callback release];
}

+ (void)restConnection:(NSURLConnection *)connection 
	 didReturnResource:(id)resource 
				object:(id)object
{
	//	NSUInteger code = [response statusCode];
	//	BOOL success = (code >= 200 && code <= 299);
	
	Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(YES, resource);
	[callback release];
}



#pragma mark Private methods

+(void)getBroadcastDefault:(Foursquare2Callback)callback{
  [Foursquare2 getAllSettingsCallback:^(BOOL success, id result) {
    if (success) {
      NSDictionary *dic = [(NSDictionary*)[(NSDictionary*)result valueForKey:@"response"] valueForKey:@"settings"];
      int def = BROADCAST_PUBLIC;
      if ([(NSNumber*)[dic valueForKey:@"sendToTwitter"] intValue] == 1) {
        def |= BROADCAST_TWITTER;
      }
      if ([(NSNumber*)[dic valueForKey:@"sendToFacebook"] intValue] == 1) {
        def |= BROADCAST_FACEBOOK;
      }
      callback(YES, [Foursquare2 broadcastTypeToString:def]);
    }
    else {
      callback(NO, result);
    }
  }];
}

+(void)resolveBroadcastType:(int)broadcast
                   callback:(Foursquare2Callback)callback{
  if (broadcast == BROADCAST_DEFAULT) {
    [Foursquare2 getBroadcastDefault:callback];
  } else {
    callback(YES, [Foursquare2 broadcastTypeToString:broadcast]);
  }
}

+(NSString*)broadcastTypeToString:(int)broadcast{
  NSString *ret = nil;
  if ((broadcast & BROADCAST_PRIVATE) == BROADCAST_PRIVATE) {
    if (ret == nil) {
      ret = @"private";
    } else {
      ret = [NSString stringWithFormat:@"%@,%@", ret, @"private"];
    }
  }
  if ((broadcast & BROADCAST_PUBLIC) == BROADCAST_PUBLIC) {
    if (ret == nil) {
      ret = @"public";
    } else {
      ret = [NSString stringWithFormat:@"%@,%@", ret, @"public"];
    }
  }
  if ((broadcast & BROADCAST_TWITTER) == BROADCAST_TWITTER) {
    if (ret == nil) {
      ret = @"twitter";
    } else {
      ret = [NSString stringWithFormat:@"%@,%@", ret, @"twitter"];
    }
  }
  if ((broadcast & BROADCAST_FACEBOOK) == BROADCAST_FACEBOOK) {
    if (ret == nil) {
      ret = @"facebook";
    } else {
      ret = [NSString stringWithFormat:@"%@,%@", ret, @"facebook"];
    }
  }
  return ret;
}

+(NSString*)problemTypeToString:(FoursquareProblemType)problem{
	switch (problem) {
		case problemClosed:
			return @"closed";
			break;
		case problemDuplicate:
			return @"duplicate";
			break;
		case problemMislocated:
			return @"mislocated";
			break;
		default:
			return nil;
			break;
	}
	
}

+(NSString*)sortTypeToString:(FoursquareSortingType)type{
	switch (type) {
		case sortNearby:
			return @"nearby";
			break;
		case sortPopular:
			return @"popular";
			break;
		case sortRecent:
			return @"recent";
			break;
		default:
			return nil;
			break;
	}
}


+ (void)        get:(NSString *)methodName
         withParams:(NSDictionary *)params 
		   callback:(Foursquare2Callback)callback
{
	[self request:methodName withParams:params httpMethod:@"GET" callback:callback];
}

+ (void)       post:(NSString *)methodName
		 withParams:(NSDictionary *)params
		   callback:(Foursquare2Callback)callback 
{
	[self request:methodName withParams:params httpMethod:@"POST" callback:callback];
}

+(NSDictionary*)generateFinalParamsFor:(NSDictionary *)params 
{	
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSString *accessToken  = [[self classAttributes] objectForKey:@"access_token"];
	if ([accessToken length] > 0) {
		[dict setObject:accessToken forKey:@"oauth_token"];
	} else {
		[dict setObject:oauthKey forKey:@"client_id"];
	}
	
	if (params) {
		for (id key in params) {
			id val = [params objectForKey:key];
			[dict setObject:val forKey:key];
		}
	}
	
	return dict;
}

+ (void)    request:(NSString *)methodName 
	     withParams:(NSDictionary *)params 
	     httpMethod:(NSString *)httpMethod
		   callback:(Foursquare2Callback)callback
{
	callback = [callback copy];
	
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	
	NSString *path = [NSString stringWithFormat:@"/%@", methodName];
	[options setValue:[NSNumber numberWithInt:HRDataFormatJSON] forKey:kHRClassAttributesFormatKey];
	NSDictionary *finalParams = [self generateFinalParamsFor:params];
	
	[options setObject:finalParams forKey:kHRClassAttributesParamsKey];
	
	if ([httpMethod isEqualToString:@"GET"])
		[self getPath:path withOptions:options object:callback];
	else
		[self postPath:path withOptions:options object:callback];
}


+ (void)    uploadPhoto:(NSString *)methodName 
			 withParams:(NSDictionary *)params 
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
			  withImage:(NSImage*)image
#else
			  withImage:(UIImage*)image
#endif
			   callback:(Foursquare2Callback)callback
{
	callback = [callback copy];
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	NSString *path = [NSString stringWithFormat:@"/%@", methodName];
	[options setValue:[NSNumber numberWithInt:33] forKey:kHRClassAttributesFormatKey];
	NSDictionary *finalParams = [self generateFinalParamsFor:params];
	
	[options setObject:finalParams forKey:kHRClassAttributesParamsKey];
	
	NSMutableData *postBody = [NSMutableData data];
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	NSArray *reps = [image representations];
	NSData *data = [NSBitmapImageRep representationOfImageRepsInArray:reps 
																 usingType:NSJPEGFileType
																properties:nil];
#else
	NSData *data = UIImageJPEGRepresentation(image,1.0);
#endif
	 
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",@"0xKhTmLbOuNdArY"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data\"; filename=\"photo.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:data]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",@"0xKhTmLbOuNdArY"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[options setObject:postBody forKey:kHRClassAttributesBodyKey];
	[self postPath:path withOptions:options object:callback];
}
@end
