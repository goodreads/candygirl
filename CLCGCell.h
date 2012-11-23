//
//  CLCGCell.h
//  Goodreads
//
//  Created by Ettore Pasquini on 9/3/12.
//  Copyright (c) 2012 Goodreads. All rights reserved.
//

#import <UIKit/UIKit.h>

// since we don't control the disclosure indicator size (and we need to
// know the width when we calc the cell height in the TV controller) let's
// provide a default size here, slightly bigger than actual to avoid
// calculating a cell height that's too small.
#define CLCGCELL_ACCESSORY_DISCL_W  22.0

/**
 * This cell loads an image on the left side, renders multiline text in its
 * textLabel, adds a 1-line gray detailTextLabel and a standard disclosure
 * indicator on the right side. It also renders itself with a different
 * background color if it's set as a emphasized cell. The layout of
 * all components is performed accordingly, adding padding between elements.
 */
@interface CLCGCell : UITableViewCell
{
  UIFont    *mTextFont;
  UIFont    *mDetailFont;
  NSString  *mImgUrl;
  CGFloat   mImgW;
  CGFloat   mImgH;
  CGFloat   mPadding;
  UIColor   *mEmphasizedColor;
  BOOL      mEmphasized;
  id        mContext;
}

@property(nonatomic,retain) UIFont    *textFont;
@property(nonatomic,retain) UIFont    *detailFont;
@property(nonatomic,retain) NSString  *imgUrl;
@property(nonatomic,assign) BOOL      emphasized;
@property(nonatomic,retain) id        context;//should this be assign?

/** Designated initializer. */
-(id)initWithImageWidth:(CGFloat)w 
                 height:(CGFloat)h
                padding:(CGFloat)padding
                reuseId:(NSString*)cid;

/** Calculates the height in accordance with all dependent parameters. */
+(CGFloat)cellHeightForText:(NSString*)text 
                 detailText:(NSString*)detailtext
                       font:(UIFont*)text_font
                 detailFont:(UIFont*)detail_font 
               cellMaxWidth:(CGFloat)cell_maxw
                     imageW:(CGFloat)imgw
                     imageH:(CGFloat)imgh
                    padding:(CGFloat)padding;

/** Changes the background color according to the current `isNew' state. */
-(void)updateBackgroundColor;

/** Hides (or resets) the image to prevent flicker when scrolling fast. */
-(void)hideImage;

/** Sets the image in the cell and shows it. */
-(void)showImage:(UIImage*)img;

@end
