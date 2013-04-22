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
    int island_width;
    int island_height;
}

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
         autoScroll:(BOOL)autoscroll {
    self = [self initWithRows:rows
                      columns:columns
                   autoScroll:autoscroll
                    showPages:YES
              scrollDirection:DPScrollDirectionHorizontal];
    return self;
}

- (id) initWithRows:(int)rows
            columns:(int)columns
         autoScroll:(BOOL)autoscroll
          showPages:(BOOL)showpages
    scrollDirection:(DPScrollDirection)scrolldir {

    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    NSArray *content = [apphelper paidMenuOfCategory:-1
                                                lang:apphelper.currentLang];
    
    self = [super initWithContent:content
                       autoScroll:NO
                        showPages:showpages
                  scrollDirection:scrolldir];
    
    if (self) {
        self.scrollableViewDelegate = self;
        self.dataDelegate = self;
        self.rowCount = rows;
        self.colCount = columns;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearPopups];
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
            [self showIslandMenu:self.scrollView.subviews[7]
                      ofCategory:element.Id
                    islandsCount:2];
            break;
        }
            
        case CTGID_SMART:
        case CTGID_LOFT:
        case CTGID_FINLAND:
        case CTGID_COUNTRY:
        case CTGID_CONTAINER:
        case CTGID_VILLAS: {
            DPCategoryViewController *ctgVC = [[DPCategoryViewController alloc]
                                               initWithCategory:element.Id];
            [self.navigationController pushViewController:ctgVC animated:YES];
            
            break;
        }
            
        case CTGID_VIDEOS:
            
            break;
            
        case CTGID_ISLAND_AEGEAN:
            
            break;
            
        case CTGID_ISLAND_CYCLADIC:
            
            break;
            
        case CTGID_ISLAND_IONIAN:
            
            break;
            
        case CTGID_EXCLUSIVE_EXCLUSIVE:
            
            break;
            
        case CTGID_EXCLUSIVE_ART:
            
            break;
            
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
        NSLog(@"Menu - calcImageName - baseName='%@'", elm.imageUrl);
        NSArray *parts = [elm.imageUrl componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            NSString *lang = @"_el"/*CURRENT_LANG*/;
            if ((elm.Id == CTGID_EXCLUSIVE) || (elm.Id == CTGID_VIDEOS))
                lang = @"";
            
            NSString *result = [NSString stringWithFormat:@"MainMenu/main_menu_%@_%@%@.%@",
                                orientation, parts[0], lang, parts[1]];

            if (ishighlight) {
                NSString *high = ishighlight ? @"roll" : @"";

                result = [NSString stringWithFormat:@"MainMenu/main_menu_%@_%@%@_%@.%@",
                                    orientation, parts[0], lang, high, parts[1]];
            }
            return result;
        }
        else
            return elm.imageUrl;
    }
    @catch (NSException* exception) {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
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
    if (!img)
        button.frame = frame;
    else {
        CGSize imgsize = img.size;
        button.frame = CGRectMake((frame.size.width - imgsize.width) / 2.0,
                                  (frame.size.height - imgsize.height) / 2.0,
                                  imgsize.width, imgsize.height);
        [button setImage:img forState:UIControlStateNormal];
    }
    
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
    NSLog(@"Clicked image at index %i named %@", indx, element.title);
    
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
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16]; //HelveticaNeue-CondensedBold"
    else  if (IS_IPHONE)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:9];
    else
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:11];
    UILabel *label = createLabel(frame, title, fnt);
    label.frame = CGRectOffset(label.frame, 0, -2);
    return label;
}
/**/

#pragma END :: DPScrollableDataSourceDelegate

#pragma mark - START :: island's and exclusive popover sbmenus
- (void)handleIslandTap:(UITapGestureRecognizer *)sender {
    [self.popController dismissPopoverAnimated:YES];
    self.popController = nil;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        int indx = sender.view.tag;
        DPDataElement *element = self.islandsContent[indx];
        NSLog(@"Clicked island image at index %i named %@ ", indx, element.title);
        
        [self elementTapped:nil element:element];
    }
}

- (UIView *) doCreateItem:(DPDataElement *)element tag:(int)indx{
    int posX = self.scrollDirection == DPScrollDirectionHorizontal ? island_width * indx : 0;
    int posY = self.scrollDirection == DPScrollDirectionVertical ? island_height * indx : 0;
    CGRect frm = CGRectMake(posX, posY, island_width,  island_height);
    
    UIView *v = [[UIView alloc] initWithFrame: frm];
    v.clipsToBounds = YES;
    
    frm = CGRectMake(0, 0, island_width, island_height);
    UIImageView *iv = [[UIImageView alloc] initWithFrame: frm];
    iv.image = [UIImage imageNamed: element.imageUrl];
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
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16]; //HelveticaNeue-CondensedBold"
    else  if (IS_IPHONE)
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:9];
    else
        fnt = [UIFont fontWithName:@"TrebuchetMS-Bold" size:11];

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
    frm = CGRectMake(frm.origin.x, frm.origin.y + frm.size.height - b.size.height,
                     frm.size.width, b.size.height);
    lv.frame = frm;
    
    [v addSubview:iv];
    [v addSubview:lv];
    
    return v;
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
    if (self.scrollDirection == DPScrollDirectionHorizontal)
        width = width * islandsCount;
    else
        height = height * islandsCount;
    
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
    if (self.scrollDirection == DPScrollDirectionHorizontal) {
        self.popController.arrowDirection = FPPopoverArrowDirectionDown;
        self.popController.contentSize = CGSizeMake(frame.size.width + 20, frame.size.height + 40);
    } else {
        self.popController.arrowDirection = FPPopoverArrowDirectionRight;
        self.popController.contentSize = CGSizeMake(frame.size.width + 40, frame.size.height + 80);

    }
    
    [self.popController presentPopoverFromView:fromView];
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
