/*
 Copyright (c) 2012, Ettore Pasquini
 Copyright (c) 2012, Cubelogic
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of Cubelogic nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */


#import "CLCGTVVC.h"
#import "CLCGMoreCell.h"
#import "clcg_device_utils.h"
#import "clcg_viewport.h"
#import "CLCGUIViewControllerCategory.h"


#define CLCGTVVC_MORE_CID     @"CLCGTVVC_MORE_CID"

@implementation CLCGTVVC


@synthesize page = mPage;
@synthesize perPage = mPerPage;
@synthesize itemsTotal = mItemsTotal;
@synthesize itemsEnd = mItemsEnd;
@synthesize moreButtonText = mMoreButtonText;
@synthesize items = mItems;


//-----------------------------------------------------------------------------
#pragma mark - Init, dealloc, memory mgmt


-(void)dealloc
{
  CLCG_REL(mItems);
  CLCG_REL(mMoreButtonText);
  [super dealloc];
}


// this is called by the super class dealloc and viewDidUnload
-(void)releaseRetainedSubviews
{
  // avoid "message sent to deallocated instance" errors on iOS 7
  [mTableView setDelegate:nil];
  [mTableView setDataSource:nil];

  CLCG_REL(mTableView);
  [super releaseRetainedSubviews];
}


// designated initializer
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    mStyle = UITableViewStylePlain;
    [self doInitCore];
  }
  return self;
}


-(id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    mStyle = style;
    [self doInitCore];
  }
  return self;
}


-(void)doInitCore
{
  mPage = 1;
  mPerPage = -1; // pagination is disabled by default
}


//-----------------------------------------------------------------------------
#pragma mark - View creation


-(void)loadBaseView
{
  UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
  UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:mStyle];
  
  // set views to expand to all available area
  UIViewAutoresizing expandmask;
  expandmask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  [v setAutoresizingMask:expandmask];
  [tv setAutoresizingMask:expandmask];

  // build view hierarchy
  [self setView:v];
  [self setTableView:tv];
  [v addSubview:tv];

  // cleanup
  [v release];
  [tv release];
}


-(void)viewDidLoad
{
  [super viewDidLoad];
  
  CGFloat left_inset;

  if ([mTableView style] == UITableViewStyleGrouped) {
    // necessary to avoid default striped background for grouped tableviews
    [mTableView setBackgroundView:nil];
    left_inset = CLCG_PADDING;
  } else {
    left_inset = 0.0f;
  }
  
  if (clcg_os_geq(@"7")) {
    [mTableView setSeparatorInset:UIEdgeInsetsMake(0, left_inset, 0, 0)];
  }
}


-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if ([self loadState] != CLCG_LOADING) {
    UITableView *tv = [self tableView];
    if ([tv indexPathForSelectedRow])
      [tv deselectRowAtIndexPath:[tv indexPathForSelectedRow] animated:YES];
  }
}


-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [mTableView flashScrollIndicators];
}


//-----------------------------------------------------------------------------
#pragma mark - UITableView behavior


-(UITableView*)tableView
{
  return mTableView;
}


-(void)setTableView:(UITableView *)tv
{
  if (![mTableView isEqual:tv]) {
    [mTableView release];
    mTableView = [tv retain];
    [mTableView setDelegate:self];
    [mTableView setDataSource:self];
  }
}


-(void)deselectAll:(BOOL)animated
{
  NSArray *selips = [mTableView indexPathsForSelectedRows];
  for (NSIndexPath *ip in selips) {
    [mTableView deselectRowAtIndexPath:ip animated:animated];
  }
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
  [super setEditing:editing animated:animated];
  [mTableView setEditing:editing animated:animated];
}


-(BOOL)isMoreRow:(NSIndexPath*)ip
{
  return (mItemsEnd < mItemsTotal && [ip row] == (NSInteger)[mItems count]);
}


-(void)reload
{
  self.page = 1;
  [self.items removeAllObjects];
  [super reload];
}


//-----------------------------------------------------------------------------
#pragma mark - UITableViewDelegate


-(void)tableView:(UITableView*)tv didSelectRowAtIndexPath:(NSIndexPath*)ip
{
  if ([self isMoreRow:ip] && [self supportsPagination]) {
    CLCGMoreCell *more;

    mPage++;
    [self setLoadState:CLCG_OUTDATED];
    [self loadFromServerIfNeeded];
    more = (CLCGMoreCell *)[self tableView:tv moreButtonCellForRow:ip];
    [more didStartRequestingMore];
    [tv deselectRowAtIndexPath:ip animated:YES];
  } else {
    [self tableView:tv didSelectNormalRow:ip];
  }
}


-(void)tableView:(UITableView*)tv didSelectNormalRow:(NSIndexPath*)ip
{
}


-(CGFloat)tableView:(UITableView*)tv heightForRowAtIndexPath:(NSIndexPath*)ip
{
  CGFloat h;

  if ([self isMoreRow:ip] && [self supportsPagination]) {
    h = [CLCGMoreCell cellHeight];
  } else {
    h = [self tableView:tv heightForNormalRowAtIndexPath:ip];
  }

  return h;
}


-(CGFloat)tableView:(UITableView*)tv heightForNormalRowAtIndexPath:(NSIndexPath*)ip
{
  return 0;
}

//-----------------------------------------------------------------------------
#pragma mark - UITableViewDataSource


-(NSInteger)numberOfSectionsInTableView:(UITableView*)tv
{
  return 1;
}


-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)sect
{
  if (mItemsEnd < mItemsTotal && [self supportsPagination]) {
    return [mItems count] + 1; //for the "More..." button
  } else {
    return [mItems count];
  }
}


-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)ip
{
  if ([self isMoreRow:ip] && [self supportsPagination]) {
    return [self tableView:tv moreButtonCellForRow:ip];
  } else {
    return [self tableView:tv normalCellForRowAtIndexPath:ip];
  }
}


-(UITableViewCell*)tableView:(UITableView*)tv
 normalCellForRowAtIndexPath:(NSIndexPath*)ip
{
#ifdef DEBUG
  [NSException raise:NSInternalInconsistencyException
              format:@"You forgot to override tableView:normalCellForRowAtIndexPath:"];
#endif
  return nil;
}


-(UITableViewCell*)tableView:(UITableView*)tv moreButtonCellForRow:(NSIndexPath*)ip
{
  CLCGMoreCell *cell;

  cell = (CLCGMoreCell*)[tv dequeueReusableCellWithIdentifier:CLCGTVVC_MORE_CID];

  if (cell == nil) {
    cell = [[CLCGMoreCell alloc] initReusingId:CLCGTVVC_MORE_CID withText:mMoreButtonText];
    [cell autorelease];
  }

  if (mLoadState != CLCG_LOADING)
    [cell didStopRequestingMore];

  return cell;
}


//------------------------------------------------------------------------------
#pragma mark - Pagination Support


-(BOOL)supportsPagination
{
  return mPerPage > 0;
}


-(void)setSupportsPagination:(BOOL)flag
{
  mPerPage = (flag ? PER_PAGE_DEFAULT : -1);
}


@end

