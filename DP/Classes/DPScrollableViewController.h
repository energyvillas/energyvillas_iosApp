//
//  DPScrollableDetailViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/21/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPScrollableViewDelegate.h"
#import "DPDataElement.h"

typedef NS_ENUM(NSInteger, DPScrollDirection) {
    DPScrollDirectionHorizontal,
    DPScrollDirectionVertical
};


@interface DPScrollableViewController : UINavContentViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *contentList;

@property (nonatomic) int rowCount;
@property (nonatomic) int colCount;
@property (nonatomic, readonly, getter = getScrollDir) DPScrollDirection scrollDirection;

@property (nonatomic, weak) id <DPScrollableViewDelegate> scrollableViewDelegate;
@property (nonatomic, weak) id <DPScrollableDataSourceDelegate> dataDelegate;


- (id) initWithContent:(NSArray *)content
            autoScroll:(BOOL)autoscroll
             showPages:(BOOL)showpages
       scrollDirection:(DPScrollDirection)scrolldir;

- (id) initWithContent:(NSArray *)content
            autoScroll:(BOOL)autoscroll;

- (void) changeRows:(int)rows columns:(int)columns;
- (void) changeRows:(int)rows columns:(int)columns scrollDirection:(DPScrollDirection)scrolldir;
- (void) changeScrollDirection:(DPScrollDirection)scrolldir;


// protected virtual
- (void) contentLoaded:(NSArray *)content;

// for local url return the image name for indx
- (NSString *) resolveImageName:(DPDataElement *)elm ;
// for local url return the highlight image name for indx or nil if does not have one
- (NSString *) resolveHighlightImageName:(DPDataElement *)elm ;

- (NSString *) calcImageName:(NSString *)baseName;
- (void) loadImageAsync:(DPDataElement *)elm inView:(UIImageView *)imgView cacheImage:(BOOL)cacheimage;
- (BOOL) isLocalUrl:(NSString *)urlstr;
- (UILabel *) createLabel:(CGRect)frame title:(NSString *)title;

@end

