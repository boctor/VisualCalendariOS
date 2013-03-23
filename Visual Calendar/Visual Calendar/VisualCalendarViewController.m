//
//  VisualCalendarViewController.m
//  Visual Calendar
//
//  Created by Peter Boctor on 3/23/13.
//  Copyright (c) 2013 Boctor Design. All rights reserved.
//

#import "VisualCalendarViewController.h"
#import "AppDelegate.h"
#import "CollectionViewCalendarEntryCell.h"
#import "LineLayout.h"

#define ITEM_SIZE 240.f

@interface VisualCalendarViewController ()
@property (strong, nonatomic) EKCalendarChooser *calendarChooser;
@property (strong, nonatomic) EKCalendar *calendar;
@property (strong, nonatomic) NSArray *events;
@end

@implementation VisualCalendarViewController

- (void)awakeFromNib
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(calendarReady:)
                                               name:CALENDAR_READY_NOTIFICATION_KEY
                                             object:nil];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupCollectionView];
}

- (void) setupCollectionView
{
  [self.collectionView registerClass:[CollectionViewCalendarEntryCell class] forCellWithReuseIdentifier:@"CollectionViewCalendarEntryCell"];
  LineLayout* lineLayout = (LineLayout*)self.collectionView.collectionViewLayout;
  lineLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
  lineLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  lineLayout.sectionInset = UIEdgeInsetsMake(0, ITEM_SIZE, 0, ITEM_SIZE);
  lineLayout.minimumLineSpacing = 40.0;
  self.collectionView.allowsMultipleSelection = YES;
}

- (void) loadOrChooseCalendar
{
  if (![[NSUserDefaults standardUserDefaults] objectForKey:CHOSEN_CALENDAR_IDENTIFIER_PREFS_KEY])
    [self chooseCalendar];
  else
  {
    [self openCalendar];
    [self showCalendar];
  }
}

- (void) calendarReady:(NSNotification *)notification
{
  [self loadOrChooseCalendar];
}

- (void) chooseCalendar
{
  AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  
  self.calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:appDelegate.eventStore];
  self.calendarChooser.delegate = self;
  [self presentViewController:self.calendarChooser animated:YES completion:NULL];
}

- (void) openCalendar
{
  AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  self.calendar = [appDelegate.eventStore calendarWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:CHOSEN_CALENDAR_IDENTIFIER_PREFS_KEY]];
  if (!self.calendar)
  {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CHOSEN_CALENDAR_IDENTIFIER_PREFS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self chooseCalendar];
  }
}

- (void) showCalendar
{
  if (!self.calendar) return;
  [self importEvents];
}

- (void) importEvents
{
  AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  // Get the appropriate calendar
  NSCalendar *calendar = [NSCalendar currentCalendar];

  NSUInteger units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
  NSDateComponents* todayComponents = [calendar components:units fromDate:[NSDate date]]; 
  NSDate *today = [calendar dateFromComponents:todayComponents];

  NSDateComponents* tomorrowComponents = [calendar components:units fromDate:[NSDate date]]; 
  tomorrowComponents.day = tomorrowComponents.day+1;
  NSDate *tomorrow = [calendar dateFromComponents:tomorrowComponents];

  // Create the predicate from the event store's instance method
  NSPredicate *predicate = [appDelegate.eventStore predicateForEventsWithStartDate:today
                                                          endDate:tomorrow
                                                        //calendars:nil];
                                                        calendars:@[self.calendar]];
 
  // Fetch all events that match the predicate
  self.events = [appDelegate.eventStore eventsMatchingPredicate:predicate];
  [self addFreeTimeEvents];
  [self.collectionView reloadData];
}

#pragma mark - EKCalendarChooserDelegate
- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser
{
  self.calendar = [self.calendarChooser.selectedCalendars anyObject];
  [[NSUserDefaults standardUserDefaults] setObject:self.calendar.calendarIdentifier forKey:CHOSEN_CALENDAR_IDENTIFIER_PREFS_KEY];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self dismissViewControllerAnimated:YES completion:NULL];
  [self showCalendar];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser
{
  [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
  return self.events.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  EKEvent *event = [self.events objectAtIndex:indexPath.item];
  CollectionViewCalendarEntryCell *cell = (CollectionViewCalendarEntryCell*)[cv dequeueReusableCellWithReuseIdentifier:@"CollectionViewCalendarEntryCell" forIndexPath:indexPath];
  [cell setupCard:[UIImage imageNamed:[self eventToImage:event]] title:event.title];
  return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSString*) eventToImage:(EKEvent*)event
{
  if ([event.title.lowercaseString rangeOfString:@"bathroom"].location != NSNotFound)
    return @"bathroom.png";
  if ([event.title.lowercaseString rangeOfString:@"breakfast"].location != NSNotFound)
    return @"breakfast.jpg";
  if ([event.title.lowercaseString rangeOfString:@"break"].location != NSNotFound)
    return @"break.png";
  if ([event.title.lowercaseString rangeOfString:@"bus"].location != NSNotFound)
    return @"bus.png";
  if ([event.title.lowercaseString rangeOfString:@"car"].location != NSNotFound)
    return @"car.png";
  if ([event.title.lowercaseString rangeOfString:@"circle"].location != NSNotFound && [event.title.lowercaseString rangeOfString:@"time"].location != NSNotFound)
    return @"circletime.png";
  if ([event.title.lowercaseString rangeOfString:@"computer"].location != NSNotFound)
    return @"computer.png";
  if ([event.title.lowercaseString rangeOfString:@"exercise"].location != NSNotFound)
    return @"exercise.png";
  if ([event.title.lowercaseString rangeOfString:@"dressed"].location != NSNotFound)
    return @"getdressed.png";
  if ([event.title.lowercaseString rangeOfString:@"learn"].location != NSNotFound)
    return @"learningtime.png";
  if ([event.title.lowercaseString rangeOfString:@"library"].location != NSNotFound)
    return @"library.png";
  if ([event.title.lowercaseString rangeOfString:@"lunch"].location != NSNotFound)
    return @"lunchdinner.png";
  if ([event.title.lowercaseString rangeOfString:@"make"].location != NSNotFound && [event.title.lowercaseString rangeOfString:@"bed"].location != NSNotFound)
    return @"makebed.png";
  if ([event.title.lowercaseString rangeOfString:@"music"].location != NSNotFound)
    return @"music.png";
  if ([event.title.lowercaseString rangeOfString:@"story"].location != NSNotFound)
    return @"readingtime.png";
  if ([event.title.lowercaseString rangeOfString:@"recess"].location != NSNotFound)
    return @"recess.png";
  if ([event.title.lowercaseString rangeOfString:@"snack"].location != NSNotFound)
    return @"lunchsnack.png";
  if ([event.title.lowercaseString rangeOfString:@"toys"].location != NSNotFound)
    return @"toys.png";
  if ([event.title.lowercaseString rangeOfString:@"dinner"].location != NSNotFound)
    return @"lunchdinner.png";
  if ([event.title.lowercaseString rangeOfString:@"wash"].location != NSNotFound && [event.title.lowercaseString rangeOfString:@"hand"].location != NSNotFound)
    return @"washhands.png";
  return nil;
}

- (void) addFreeTimeEvents
{
  AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  NSMutableArray* newEvents = [NSMutableArray arrayWithArray:self.events];
  for (NSUInteger i = 0 ; i < newEvents.count ; i++)
  {
    EKEvent* event = newEvents[i];
    EKEvent* nextEvent = nil;
    if (i+1 < newEvents.count)
      nextEvent = newEvents[i+1];
    
    if (event && nextEvent)
    {
      NSTimeInterval intervalBetweenEvents = [nextEvent.startDate timeIntervalSinceDate:event.endDate];
      if (intervalBetweenEvents > 0)
      {
        EKEvent * freeTimeEvent = [EKEvent eventWithEventStore:appDelegate.eventStore];
        freeTimeEvent.title = @"Free Time";
        freeTimeEvent.startDate = event.endDate;
        freeTimeEvent.endDate = nextEvent.startDate;
        [newEvents insertObject:freeTimeEvent atIndex:[newEvents indexOfObjectIdenticalTo:nextEvent]];
      }
    }
  }
  self.events = [NSArray arrayWithArray:newEvents];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
