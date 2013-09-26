//
//  CLCGImageView.m
//  Goodreads
//
//  Created by Ettore Pasquini on 6/4/12.
//  Copyright (c) 2012 Goodreads. All rights reserved.
//

#import "ASIHTTPRequest.h"

#import "clcg_macros.h"
#import "clcg_str_utils.h"
#import "clcg_device_utils.h"
#import "CLCGImageView.h"


@implementation CLCGImageView
{
  ASIHTTPRequest  *mReq;

  // target and action for "on tap" event
  id              mTapTarget;
  SEL             mTapAction;
}


-(void)dealloc
{
  [mReq clearDelegatesAndCancel];
  CLCG_REL(mReq);

  mTapTarget = nil;
  mTapAction = nil;
  [super dealloc];
}


-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:UIViewAutoresizingNone];
    [self setContentMode:UIViewContentModeScaleAspectFit];
  }
  return self;
}


-(void)addTarget:(id)target onTapAction:(SEL)action
{
  mTapAction = action;

  // we want to keep an "assign" memory policy here to avoid circular references
  // with container classes, who are likely to retain us. For instance, on a 
  // memory warning situation the container or vc will release us, and once 
  // viewDidLoad is re-hit, the client code will reassign the target in there.
  mTapTarget = target;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  if ([touches count] == 1)
    [mTapTarget performSelector:mTapAction withObject:self];
}


-(void)loadImageForURL:(NSString*)normalurl retinaURL:(NSString*)retinaurl
{
  if (mReq) {
    [mReq cancel];
    CLCG_REL(mReq);
  }
  
  mReq = [CLCGImageLoader loadImageForURL:normalurl
                                retinaURL:retinaurl
                                 useCache:YES
                                    block:^(UIImage *img, int http_status) {
                                      if (img) {
                                        [self setImage:img];

                                        //TODO we should resize the image view
                                        //accordingly to `img` size. But if we're
                                        //not sure to always get retina images
                                        //this could lead to displaying an
                                        //image that's too big or too small.

                                      } else {
                                        CLCG_P(@"Error loading image. HTTP status=%d",
                                               http_status);
                                      }
                                      
                                      if (_callback) {
                                        _callback(img, http_status);
                                      }
                                      
                                      CLCG_REL(mReq);
                                    }];
  [mReq retain];
}


@end
