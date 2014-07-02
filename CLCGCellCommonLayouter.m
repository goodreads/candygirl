//
//  CLCGCellCommonLayouter.m
//  Goodreads
//
//  Created by Ettore Pasquini on 5/1/13.
//
#import <QuartzCore/QuartzCore.h>
#import "CLCGCellCommonLayouter.h"
#import "CLCGCell.h"

@implementation CLCGCellCommonLayouter


-(void)dealloc
{
  [self setCell:nil];
  [super dealloc];
}


-(id)initWithCell:(id<CLCGCell>)cell
{
  self = [super init];
  if (self) {
    [self setCell:cell];
  }
  return self;
}


-(void)updateBackgroundColor
{
  // Note: setting the background color on the contentView or even all the
  // subviews doesn't take care of changing the background of the accessoryView.
  // Setting the background of the accessoryView doesn't seem to work either.
  UIColor *color = ([_cell emphasized] ? [_cell emphasisColor] : [_cell normalColor]);
  [[_cell backgroundView] setBackgroundColor:color];
}


-(void)hideImage
{
  [[[_cell imageView] layer] setOpacity:0.0];
}


-(void)showImage:(UIImage*)img
{
  [self showImage:img animated:([[_cell imageView] image] == nil)];
}


-(void)showImage:(UIImage*)img animated:(BOOL)animated
{
  CALayer *layer = [[_cell imageView] layer];

  if (animated) {
    // once the img view has been layed out once, no need to re-lay it out again
    [_cell setNeedsLayout]; //layout will happen in next update cycle
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [anim setDuration:0.4]; // seconds
    [anim setFromValue:[NSNumber numberWithFloat:0.0]];
    [anim setToValue:[NSNumber numberWithFloat:1.0]];
    [layer addAnimation:anim forKey:@"animateOpacity"];
  }

  [[_cell imageView] setImage:img];
  [layer setOpacity:1.0]; //makes the animation ending value stick
}


-(CGFloat)xRightOfImage
{
  CGRect r = [[_cell imageView] frame];
  return r.origin.x + r.size.width + [_cell innerPadding];
}


@end
