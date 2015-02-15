//
//  NumNaoAppDelegate.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "NumLaiAppDelegate.h"
#import "NumLaiIAPHelper.h"
#import "QuizManager.h"
#import "GAI.h"

@implementation NumLaiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  // Load the FBLoginView class (needed for login)
  sleep(1);
  [FBLoginView class];
  [[QuizManager sharedInstance] checkQuizUpdateWithServer];
  [[NumLaiIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {

  }];
  
  // Optional: automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  
  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
  [GAI sharedInstance].dispatchInterval = 20;
  
  // Optional: set Logger to VERBOSE for debug information.
  [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
  
  // Initialize tracker. Replace with your tracking ID.
  [[GAI sharedInstance] trackerWithTrackingId:@"UA-54545219-1"];
  
  // Let the device know we want to receive push notifications
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
   (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  
  return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
  NSString *tokenOriginal = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];

  NSString *tokenString = [tokenOriginal stringByReplacingOccurrencesOfString:@" " withString:@""];
  NSLog(@"My test string is: %@", tokenString);
  
  [[QuizManager sharedInstance] sendDeviceTokenToServerWithToken:tokenString];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
  NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  
  BOOL urlWasHandled =
  [FBAppCall handleOpenURL:url
         sourceApplication:sourceApplication
           fallbackHandler:
   ^(FBAppCall *call) {
     // Parse the incoming URL to look for a target_url parameter
     NSString *query = [url query];
     NSDictionary *params = [self parseURLParams:query];
     // Check if target URL exists
     NSString *appLinkDataString = [params valueForKey:@"al_applink_data"];
     if (appLinkDataString) {
       NSError *error = nil;
       NSDictionary *applinkData =
       [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding]
                                       options:0
                                         error:&error];
       if (!error &&
           [applinkData isKindOfClass:[NSDictionary class]] &&
           applinkData[@"target_url"]) {
         self.refererAppLink = applinkData[@"referer_app_link"];
         NSString *targetURLString = applinkData[@"target_url"];
         // Show the incoming link in an alert
         // Your code to direct the user to the
         // appropriate flow within your app goes here
         [[[UIAlertView alloc] initWithTitle:@"Received link:"
                                     message:targetURLString
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] show];
       }
     }
   }];
  
  return urlWasHandled;
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val = [[kv objectAtIndex:1]
                     stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [params setObject:val forKey:[kv objectAtIndex:0]];
  }
  return params;
}

@end
