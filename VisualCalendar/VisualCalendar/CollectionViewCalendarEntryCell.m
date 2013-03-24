//
//  CollectionViewCalendarEntryCell
//  Visual Calendar
//
//  Created by Peter Boctor on 3/23/13.
//  Copyright (c) 2013 Boctor Design. All rights reserved.
//

#import "CollectionViewCalendarEntryCell.h"

@interface CollectionViewCalendarEntryCell ()
@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) UILabel* label;
@end

@implementation CollectionViewCalendarEntryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
      self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
      self.label.textAlignment = NSTextAlignmentCenter;
      self.label.numberOfLines = 0;
      self.label.font = [UIFont boldSystemFontOfSize:30.0];
      self.label.backgroundColor = [UIColor underPageBackgroundColor];
      self.label.textColor = [UIColor blackColor];
      [self.contentView addSubview:self.label];;
      self.label.layer.borderWidth = 1.0f;
      self.label.layer.borderColor = [UIColor whiteColor].CGColor;


      self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
      self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
      // self.imageView.layer.masksToBounds = YES;
      // self.imageView.layer.cornerRadius = 40.f;
      [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void) setupCard:(UIImage*)image title:(NSString*)title
{
  self.imageView.image = image;
  self.label.text = title;
  if (image)
  {
    self.imageView.alpha = 1;
    self.self.label.alpha = 0;
  }
  else
  {
    self.imageView.alpha = 0;
    self.self.label.alpha = 1;
  }
}

@end
