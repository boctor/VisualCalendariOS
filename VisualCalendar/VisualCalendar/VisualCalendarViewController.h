//
//  VisualCalendarViewController.h
//  Visual Calendar
//
//  Created by Peter Boctor on 3/23/13.
//  Copyright (c) 2013 Boctor Design. All rights reserved.
//

@interface VisualCalendarViewController : UIViewController <EKCalendarChooserDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView* collectionView;
@property (strong, nonatomic) IBOutlet UIButton* nowButton;
- (IBAction) showNow;
@end
