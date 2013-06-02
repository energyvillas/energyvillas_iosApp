//
//  DPMenuViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/5/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPMenuViewController.h"
#import "DPConstants.h"
#import "DPDataElement.h"
#import "DPCategoryViewController.h"
#import "DPAppHelper.h"

@interface DPMenuViewController ()

@property (strong, nonatomic) FPPopoverController *popController;
@property (strong, nonatomic) UIViewController *islandPopupViewController;
@property (strong, nonatomic) NSArray *islandsContent;

@end

@implementation DPMenuViewController {
    int menulevel;
    int island_width;
    int island_height;
}

@synthesize currentMenuPage = _currentMenuPage;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithRows:(int)rows
            columns:(int)columns
         autoScroll:(BOOL)autoscroll
          showPages:(BOOL)showpages
    scrollDirection:(DPScrollDirection)scrolldir
          menulevel:(int)level
        initialPage:(int)initialPage {

    menulevel = level;
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    NSArray *content = [apphelper paidMenuOfCategory:-1
                                                lang:apphelper.currentLang];
    
    self = [super initWithContent:content
                             rows:rows
                          columns:columns
                       autoScroll:NO
                        showPages:showpages
                  scrollDirection:scrolldir
                      initialPage:initialPage];
    
    if (self) {
        self.scrollableViewDelegate = self;
        self.dataDelegate = self;
    }
    
    return self;
}

- (void) scrolledToPage:(int)newPage {
    _currentMenuPage = newPage;
    NSLog(@"scrolledToPage:%d", _currentMenuPage);
}

- (int) getCurrentMenuPage {
    return _currentMenuPage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPAID_SelectedCategoryChanged_Notification
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
//                                                                                               forKey:@"menuCategory"]];
//    });
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearPopups];
    
//    if (menulevel == 1)
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPAID_SelectedCategoryChanged_Notification
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
//                                                                                               forKey:@"menuCategory"]];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self clearPopups];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeRows:(int)rows columns:(int)columns {
    // dismiss popover since the positioning will be wrong
    [self clearPopups];
    [super changeRows:rows columns:columns];
}

- (void) clearPopups {
    if (self.popController) {
        [self.popController dismissPopoverAnimated:YES];
        self.popController = nil;
    }
    
    self.islandPopupViewController = nil;
    self.islandsContent = nil;
}

/*
//- (void) doLayoutSubviews:(BOOL)fixtop {
//   
////    CGRect vf = self.view.frame;
////    int h = vf.size.height;//sv.bounds.size.height;
////    int w = vf.size.width;//sv.bounds.size.width;
//    //self.view.frame = CGRectMake(0, 0, w, h);
////    self.scrollView.frame = CGRectMake(0, 0, w, h);
////    self.pageControl.frame = CGRectMake(0, h - PAGE_CONTROL_HEIGHT, w, PAGE_CONTROL_HEIGHT);
//    
//    [self changeRows:self.rowCount columns:self.colCount];
//}
*/

- (void) elementTapped:(id)sender element:(id)tappedelement {
    DPDataElement *element = tappedelement;
    if (element == nil) return;
    
    switch (element.Id) {
        case CTGID_ISLAND: {
            [self showIslandMenu:self.scrollView.subviews[3]
                      ofCategory:element.Id
                    islandsCount:3];
            break;
        }
            
        case CTGID_EXCLUSIVE:{
            [self showIslandMenu:self.scrollView.subviews[6]
                      ofCategory:element.Id
                    islandsCount:2];
            break;
        }
            
        case CTGID_SMART:
        case CTGID_LOFT:
        case CTGID_FINLAND:
        case CTGID_COUNTRY:
        case CTGID_CONTAINER:
        case CTGID_VILLAS:

        case CTGID_ISLAND_AEGEAN:
        case CTGID_ISLAND_CYCLADIC:
        case CTGID_ISLAND_IONIAN:
        
        case CTGID_EXCLUSIVE_DESIGNER:
        case CTGID_EXCLUSIVE_ART:

        case CTGID_VIDEOS:{
//            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:element.Id]
                                                                                                       forKey:@"menuCategory"]];
//            });

            if (menulevel == 0) {
                DPCategoryViewController *ctgVC = [[DPCategoryViewController alloc]
                                                   initWithCategory:element.Id];
                [self.navigationController pushViewController:ctgVC animated:YES];
            } else {
                UIViewController *top = [self.navigationController topViewController];
                if ([top isKindOfClass:[DPCategoryViewController class]])
                    [((DPCategoryViewController *)top) showCategory:element.Id];
            }
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - START :: DPScrollableDataSourceDelegate
-(NSString *) resolveImageName:(DPDataElement *)elm {
    return [self calcImageName:elm isHighlight:NO];
}
-(NSString *) resolveHighlightImageName:(DPDataElement *)elm {
    return [self calcImageName:elm isHighlight:YES];
}
//- (NSString *) calcImageName:(NSString *)baseName {
//    return [self calcImageName:baseName isHighlight:NO];
//}
- (NSString *) calcImageName:(DPDataElement *)elm isHighlight:(BOOL)ishighlight {
    @try {
#ifdef LOG_MENU
        NSLog(@"Menu - calcImageName - baseName='%@'", elm.imageUrl);
#endif
        NSArray *parts = [elm.imageUrl componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *result = elm.imageUrl;
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";            
            NSString *high = ishighlight ? @"_roll" : @"";

            if (menulevel == 0)
                result = [NSString stringWithFormat:@"MainMenu/main_menu_%@_%@%@.%@",
                                    orientation, parts[0], high, parts[1]];
            else
                result = [NSString stringWithFormat:@"MenuLevel1/menu_level-1_%@_%@%@.%@",
                          orientation, parts[0], high, parts[1]];

            return result;
        }
        else
            return elm.imageUrl;
    }
    @catch (NSException* exception) {
        return elm.imageUrl;
    }
}

- (UIView *) createViewFor:(int)contentIndex
                     frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
    
    DPDataElement *element = self.contentList[contentIndex];
    
    NSString *imgname =[self resolveImageName:element];
    UIImage *img = [UIImage imageNamed:imgname];

    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = frame;
    [button setImage:img forState:UIControlStateNormal];

//    if (!img)
//        button.frame = frame;
//    else {
//        CGSize imgsize = img.size;
//        button.frame = CGRectMake((frame.size.width - imgsize.width) / 2.0,
//                                  (frame.size.height - imgsize.height) / 2.0,
//                                  imgsize.width, imgsize.height);
//        [button setImage:img forState:UIControlStateNormal];
//    }
    
    NSString *imghighname =[self resolveHighlightImageName:element];
    if (imghighname) {
        img = [UIImage imageNamed:imghighname];
        if (img)
            [button setImage:img forState:UIControlStateHighlighted];
    }
    
    [button setTag: contentIndex];
    
    return button;
}

- (void) onTap:(id)sender {
    int indx = ((UIButton *)sender).tag;
    DPDataElement * element = self.contentList[indx];
#ifdef LOG_MENU
    NSLog(@"Clicked image at index %i named %@", indx, element.title);
#endif
    
    [self elementTapped:sender element:element];
    
    // navigation logic goes here. create and push a new view controller;
    //        DPTestViewController *vc = [[DPTestViewController alloc] init];
    //        [self.navigationController pushViewController: vc animated: YES];
    
}

/**/
- (UILabel *) createLabelFor:(int)contentIndex
                       frame:(CGRect)frame
                       title:(NSString *)title {
    UIFont *fnt = nil;
    if (IS_IPAD)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size: IS_PORTRAIT ? 16 : 15.0f]; //HelveticaNeue-CondensedBold"
    else  if (IS_IPHONE)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size: IS_PORTRAIT ? 8.7f : 8.4f];
    else
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:8.0f];
    UILabel *label = createLabel(frame, title, fnt);
    int offsetV = [self calcLabelOffset];
    label.frame = CGRectOffset(label.frame, 0, offsetV);
    return label;
}
/**/

-(int) calcLabelOffset {
    switch (menulevel) {
        case 0:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? -6 : -5;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? -16 : -4;
            } else {
                return IS_PORTRAIT ? -15 : -27;
            }
            break;
            
        case 1:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? -9 : -5;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? -9 : -5;
            } else {
                return IS_PORTRAIT ? -24 : -26;
            }
            break;
    }
    
    return 0;
}

#pragma END :: DPScrollableDataSourceDelegate

#pragma mark - START :: island's and exclusive popover sbmenus
- (void)handleIslandTap:(UITapGestureRecognizer *)sender {
    [self.popController dismissPopoverAnimated:YES];
    self.popController = nil;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        int indx = sender.view.tag;
        DPDataElement *element = self.islandsContent[indx];
#ifdef LOG_MENU
        NSLog(@"Clicked island image at index %i named %@ ", indx, element.title);
#endif
        [self elementTapped:nil element:element];
    }
}

- (UIView *) doCreateItem:(DPDataElement *)element tag:(int)indx{
    int posX = 0, posY = 0;
    if (menulevel == 0 && IS_LANDSCAPE) {
        posX = 0;
        posY = island_height * indx;
    } else {
        posX = self.scrollDirection == DPScrollDirectionHorizontal ? island_width * indx : 0;
        posY = self.scrollDirection == DPScrollDirectionVertical ? island_height * indx : 0;
    }
    
    CGRect frm = CGRectMake(posX, posY, island_width,  island_height);
    
    UIView *v = [[UIView alloc] initWithFrame: frm];
    v.clipsToBounds = YES;
    
    frm = CGRectMake(0, 0, island_width, island_height);
    UIImageView *iv = [[UIImageView alloc] initWithFrame: frm];

    NSString *imgname =[self resolveImageName:element];
    iv.image = [UIImage imageNamed:imgname];
    iv.contentMode = UIViewContentModeScaleAspectFit; 
    iv.tag = indx;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleIslandTap:)];
    [iv addGestureRecognizer:tapper];
    iv.userInteractionEnabled = YES;
    
    UILabel *lv = [[UILabel alloc] initWithFrame: frm];
    lv.textAlignment = NSTextAlignmentCenter;
    
    UIFont *fnt = nil;
    if (IS_IPAD)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:19]; //HelveticaNeue-CondensedBold"
    else  if (IS_IPHONE)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:9];
    else
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10.0f];

    lv.font = fnt;
//    if (IS_IPAD)
//        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
//    else
//        lv.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    lv.adjustsFontSizeToFitWidth = YES;
    lv.text = element.title;
    lv.backgroundColor = [UIColor clearColor];
    lv.textColor = [UIColor whiteColor];
    [lv sizeToFit];
    CGRect b = lv.bounds;
    int offsetV = [self calcPopupLabelOffset];
    frm = CGRectMake(frm.origin.x, frm.origin.y + offsetV,
                     frm.size.width, b.size.height);
    lv.frame = frm;
    
    [v addSubview:iv];
    [v addSubview:lv];
    
    return v;
}

-(int) calcPopupLabelOffset {
    switch (menulevel) {
        case 0:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? 2 : 2;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? 2 : 2;
            } else {
                return IS_PORTRAIT ? 6 : 6;
            }
            break;
            
        case 1:
            if (IS_IPHONE) {
                return IS_PORTRAIT ? 2 : 2;
            } else if (IS_IPHONE_5) {
                return IS_PORTRAIT ? 2 : 2;
            } else {
                return IS_PORTRAIT ? 6 : 6;
            }
            break;
    }
    
    return 0;
}

-(id) doCreateIslandViewController:(int)ctgId islandsCount:(int)islandsCount frame:(CGRect)vframe {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.frame = vframe;
    
    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
    self.islandsContent = [appHelper paidMenuOfCategory:ctgId lang:appHelper.currentLang];
    
    for (int i = 0; i < self.islandsContent.count; i++) {
        DPDataElement *element = self.islandsContent[i];
        [vc.view addSubview:[self doCreateItem:element tag:i]];
    }
    
    return vc;
}

-(void) showIslandMenu:(id)fromView ofCategory:(int)ctgId islandsCount:(int)islandsCount {
    [self clearPopups];
    CGRect mmfrm = self.view.superview.frame;
    
    island_width = mmfrm.size.width / self.colCount;
    island_height = mmfrm.size.height / self.rowCount;
    CGFloat ratio = (1.0 * island_width) / island_height;
    island_width = island_width - 7;
    island_height = island_width / ratio;
    
    int width = island_width;
    int height = island_height;
    if (menulevel == 0) {
        width = IS_PORTRAIT ? width * islandsCount : width;
        height = IS_PORTRAIT ? height : height * islandsCount;
    } else {
        if (self.scrollDirection == DPScrollDirectionHorizontal)
            width = width * islandsCount;
        else
            height = height * islandsCount;
    }
    
    CGRect frame = CGRectMake(0, //island_width * islandsCount,
                              0,
                              width,//island_width,
                              height);//island_height);

    //the view controller you want to present as popover
    if (!self.islandPopupViewController)
        self.islandPopupViewController = [self doCreateIslandViewController:ctgId
                                                               islandsCount:islandsCount
                                                                      frame:frame];
    
    self.islandPopupViewController.title = nil;
    
    //our popover
    self.popController = [[FPPopoverController alloc]
                          initWithViewController:self.islandPopupViewController];
    self.popController.delegate = self;
    self.popController.border = YES;
    self.popController.tint = FPPopoverBlackTint;
    if (menulevel == 0) {
        if (IS_PORTRAIT) {
            self.popController.arrowDirection = FPPopoverArrowDirectionDown;
            self.popController.contentSize = CGSizeMake(frame.size.width + 20, frame.size.height + 40);
        } else {
            self.popController.arrowDirection = FPPopoverArrowDirectionLeft;
            self.popController.contentSize = CGSizeMake(frame.size.width + 40,
                                                        frame.size.height + (islandsCount == 3 ? 20 : 20));
        }
    } else {
        if (self.scrollDirection == DPScrollDirectionHorizontal) {
            self.popController.arrowDirection = FPPopoverArrowDirectionDown;
            self.popController.contentSize = CGSizeMake(frame.size.width + 20, frame.size.height + 40);
        } else {
            self.popController.arrowDirection = FPPopoverArrowDirectionRight;
            self.popController.contentSize = CGSizeMake(frame.size.width + 40,
                                                        frame.size.height +
                                                        (islandsCount == 3 ? (IS_IPAD ? 250 : 80): (IS_IPAD ? 40 : 20)));
        }
    }
    
    if (menulevel == 0) {
        if (IS_PORTRAIT)
            [self.popController presentPopoverFromView:fromView];
        else {
            CGPoint p = CGPointZero;
            
            if (!IS_IPAD)
                p = CGPointMake(mmfrm.origin.x + island_width,
                                mmfrm.origin.y + island_height * (islandsCount == 3 ? 2.3 : 3.3));
            else
                p = CGPointMake(mmfrm.origin.x + island_width,
                                mmfrm.origin.y + island_height * (islandsCount == 3 ? 1.9 : 2.4));
            
            [self.popController presentPopoverFromPoint:p];
        }
    } else {
        if (IS_PORTRAIT) {
            CGPoint p = CGPointMake(mmfrm.origin.x + (island_width / 2.0),
                                    mmfrm.origin.y + (island_height / 2.0) + (IS_IPAD ? -45.0: 10.0));
            [self.popController presentPopoverFromPoint:p];
        } else {
            CGPoint p = CGPointMake(mmfrm.origin.x + 10.0, mmfrm.origin.y + island_height);
            [self.popController presentPopoverFromPoint:p];
        }
    }
}


- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    
}
#pragma END :: islands and exclusive popover sbmenus



@end
