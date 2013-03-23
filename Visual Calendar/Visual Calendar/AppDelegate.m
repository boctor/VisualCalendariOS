//
//  AppDelegate.m
//  Visual Calendar
//
//  Created by Peter Boctor on 3/23/13.
//  Copyright (c) 2013 Boctor Design. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong, nonatomic) UIImageView *splashView;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
  [self continueShowingDefaultLaunchScreen];
  [self getCalendarPermissions];
  return YES;
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

- (void) continueShowingDefaultLaunchScreen
{
  self.splashView = [[UIImageView alloc] initWithFrame:self.window.frame];
  self.splashView.image = [UIImage imageNamed:@"Default.png"];
  self.splashView.alpha = 1;
  [self.window addSubview:self.splashView];
  [self.window bringSubviewToFront:self.splashView];
}

- (void)getCalendarPermissions
{
  void (^calendarPermissionGrantedBlock)();

  calendarPermissionGrantedBlock = ^
  {
    [UIView animateWithDuration:0.5 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
      self.splashView.alpha = 0;
      NSNotification *notification = [NSNotification notificationWithName:CALENDAR_READY_NOTIFICATION_KEY object:nil userInfo:nil];
      [[NSNotificationCenter defaultCenter] postNotification:notification];
    } completion:^(BOOL finished) {
      [self.splashView removeFromSuperview];
    }];
  };

  self.eventStore = [[EKEventStore alloc] init];

  if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
  {
      [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
       {
           if (granted)
               calendarPermissionGrantedBlock();
           else
             [[[UIAlertView alloc] initWithTitle:@"Oops, we need access to your Calendars!"
                                          message:@"Please visit the Settings app and give us permission!"
                                         delegate:nil
                                cancelButtonTitle:nil 
                                otherButtonTitles:@"OK", nil] show];
       }];
  }
  else
      calendarPermissionGrantedBlock();
}

@end
