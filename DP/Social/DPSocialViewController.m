//
//  DPSocialViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPSocialViewController.h"
#import "DPConstants.h"
#import "UIApplication+ScreenDimensions.h"
#import <QuartzCore/QuartzCore.h>


#define SOCIAL_ITEMS_CNT ((int)6)

@interface DPSocialViewController ()

@property (strong) void (^onClose)(int tag);

@end


@implementation DPSocialViewController {
    CGRect actualFrame;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCompletion:(void (^)(int tag))completion {
    self = [super init];
    if (self) {
        self.onClose = completion;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    actualFrame = CGRectZero;
    
    [self.view bringSubviewToFront:self.contentView];
    [self doLocalize];
    [self internalLayoutSubViews];
}

- (void)viewDidUnload {
    [self setBtnClose:nil];
    [self setContentView:nil];
    [self setBackView:nil];
    self.onClose = nil;
    [self setFacebookView:nil];
    [self setTwitterView:nil];
    [self setLinkedinView:nil];
    [self setEmailView:nil];
    [self setFavsView:nil];
    [self setOtherView:nil];
    [self setBackgroundView:nil];
    [super viewDidUnload];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self internalLayoutSubViews];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    if (!IS_IPAD)
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self doOnBtnTap:-1];
//        });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)socialBtnTapped:(id)sender {
    int btntag = ((UIButton *)sender).tag;
    [self doOnBtnTap:btntag];
}

-(void) doOnBtnTap:(int)indx {
    if (IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.onClose != nil)
                self.onClose(indx);
        }];
    } else {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (self.onClose != nil)
            self.onClose(indx);
    }
}

-(CGRect) calcFrame {
    [self internalLayoutSubViews];
    return actualFrame;
}

-(void) doLocalize {
    [self.btnClose setTitle:DPLocalizedString(@"SOCIAL_BTN_Close") forState:UIControlStateNormal];
    
    for (UIView *itemView in self.contentView.subviews)
        if (itemView.tag != 0)
            [self localizeItem:itemView];
}
-(void) localizeItem:(UIView *)itemView {
    UILabel *lbl = itemView.subviews[0];
    UIButton *btn = itemView.subviews[1];
    [btn setTitle:DPLocalizedString([NSString stringWithFormat:@"SOCIAL_BTN_%.2d", btn.tag])
         forState:UIControlStateNormal];
    lbl.text = DPLocalizedString([NSString stringWithFormat:@"SOCIAL_BTN_%.2d", btn.tag]);
    [lbl sizeToFit];
}

-(NSString *) calcSocialBtnImageName:(int)tag highlight:(BOOL)highlight {
    switch (tag) {
        case SOCIAL_ACT_FACEBOOK:
            return [NSString stringWithFormat:@"Social/Social_%@%@.png",
                    @"facebook", highlight ? @"_roll" : @""];
            
        case SOCIAL_ACT_TWITTER:
            return [NSString stringWithFormat:@"Social/Social_%@%@.png",
                    @"twitter", highlight ? @"_roll" : @""];
            
        case SOCIAL_ACT_LINKEDIN:
            return [NSString stringWithFormat:@"Social/Social_%@%@.png",
                    @"linkedin", highlight ? @"_roll" : @""];
            
        case SOCIAL_ACT_EMAIL:
            return [NSString stringWithFormat:@"Social/Social_%@%@.png",
                    @"mail", highlight ? @"_roll" : @""];
            
        case SOCIAL_ACT_FAVS:
            return [NSString stringWithFormat:@"Social/Social_%@%@.png",
                    @"favorites", highlight ? @"_roll" : @""];
            
        case SOCIAL_ACT_OTHER:
            return [NSString stringWithFormat:@"Social/Social_%@%@.png",
                    @"youtube", highlight ? @"_roll" : @""];
            
        default:
            return @"";
    }
}
-(CGSize) layoutItem:(UIView *)itemView {
    int LBL_BTN_SPACE = 4;
    int IMG_WIDTH = IS_IPAD ? 72 : 57;
    int IMG_HEIGHT = IS_IPAD ? 72 : 57;

    UILabel *lbl = itemView.subviews[0];
    UIButton *btn = itemView.subviews[1];
    
    btn.frame = CGRectMake(0, 0, IMG_WIDTH, IMG_HEIGHT);
    btn.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *img = [UIImage imageNamed:[self calcSocialBtnImageName:btn.tag highlight:NO]];
    [btn setImage:img forState:UIControlStateNormal];
    img = [UIImage imageNamed:[self calcSocialBtnImageName:btn.tag highlight:YES]];
    [btn setImage:img forState:UIControlStateHighlighted];

    lbl.textColor = [UIColor whiteColor];
    lbl.frame = CGRectMake((IMG_WIDTH - lbl.frame.size.width) / 2.0,
                           IMG_HEIGHT + LBL_BTN_SPACE,
                           lbl.frame.size.width,
                           lbl.frame.size.height);
    CGSize result = CGSizeMake(IMG_WIDTH, IMG_HEIGHT + LBL_BTN_SPACE + lbl.frame.size.height);
    
    return result;
}

-(void) internalLayoutSubViews {
    CGSize nextViewSize = [UIApplication sizeInOrientation:INTERFACE_ORIENTATION];
    if (IS_IPAD)
        self.backView.hidden = YES;
    else
        self.backView.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);
    
    CGRect cf;
    if (IS_IPHONE) {
        cf = CGRectInset(CGRectMake(0, 0, nextViewSize.width, nextViewSize.height),
                         16, 16);
    } else if (IS_IPHONE_5) {
        cf = CGRectInset(CGRectMake(0, 0, nextViewSize.width, nextViewSize.height),
                         16, 16);
        //CGRectMake(0, IS_PORTRAIT ? 105 : 18,
        //                nextViewSize.width, nextViewSize.height);
    } else /*if (IS_IPAD)*/ {
        cf = CGRectMake(0, IS_PORTRAIT ? 165 : 180,
                        nextViewSize.width, nextViewSize.height);
    }
    
    self.contentView.frame = cf;
    
    CGFloat OUTER_MARGIN_HORZ = 10;
    CGFloat OUTER_MARGIN_VERT = 10;
    CGRect frm = CGRectMake(OUTER_MARGIN_HORZ, 0,
                            nextViewSize.width - 2 * OUTER_MARGIN_HORZ,
                            nextViewSize.height);
    // button grid
    CGFloat COL_WIDTH = 0;
    CGFloat ROW_HEIGHT = 0;
    
    CGSize sz = CGSizeZero;

    for (UIView *itemView in self.contentView.subviews)
        if (itemView.tag != 0) {            
            sz = [self layoutItem:itemView];
            COL_WIDTH = MAX(COL_WIDTH, sz.width);
            ROW_HEIGHT = MAX(ROW_HEIGHT, sz.height);
        }
    
    int COLS = 3;
    int ROWS = 2;
//    CGFloat HORZ_MARGIN = (frm.size.width - COLS * COL_WIDTH) / (2 * COLS) ;
//    CGFloat VERT_MARGIN = HORZ_MARGIN;
//    CGFloat HORZ_SPACER = 2 * HORZ_MARGIN;
//    CGFloat VERT_SPACER = VERT_MARGIN;  
    CGFloat HORZ_MARGIN = 16;
    CGFloat VERT_MARGIN = 16;
    CGFloat HORZ_SPACER = 2 * HORZ_MARGIN; //(frm.size.width - 2 * HORZ_MARGIN - COLS * COL_WIDTH) / (COLS - 1);
    CGFloat VERT_SPACER = VERT_MARGIN;
    
    for (UIView *itemView in self.contentView.subviews)
        if (itemView.tag != 0) {
            int row = (itemView.tag - 1) / COLS;
            int col = (itemView.tag -1) % COLS;
            
            itemView.backgroundColor = [UIColor clearColor];
            itemView.frame = CGRectMake(HORZ_MARGIN + col * (HORZ_SPACER + COL_WIDTH),
                                        VERT_MARGIN + row * (VERT_SPACER + ROW_HEIGHT),
                                        COL_WIDTH, ROW_HEIGHT);
        }
    
    frm = CGRectMake(frm.origin.x, frm.origin.y,
                     COLS * COL_WIDTH + (COLS - 1) * HORZ_SPACER + 2 * HORZ_MARGIN,
                     ROWS * ROW_HEIGHT + (ROWS - 1) * VERT_SPACER + 2 * VERT_MARGIN);
    
    // btn close
//    self.btnClose.frame = CGRectMake((frm.size.width - self.btnClose.bounds.size.width) / 2.0,
//                                     frm.origin.y + frm.size.height,
//                                     self.btnClose.bounds.size.width,
//                                     self.btnClose.bounds.size.height);
    self.btnClose.frame = CGRectMake((frm.size.width - self.btnClose.bounds.size.width) / 2.0,
                                     frm.origin.y + frm.size.height,
                                     self.btnClose.bounds.size.width,
                                     self.btnClose.bounds.size.height);
    
    frm = CGRectMake(frm.origin.x, frm.origin.y,
                     frm.size.width,
                     frm.size.height + self.btnClose.bounds.size.height + VERT_MARGIN);
//    frm = CGRectMake(frm.origin.x, frm.origin.y,
//                     frm.size.width,
//                     frm.size.height);
    
    cf = CGRectOffset(frm, 0.0, nextViewSize.height - frm.size.height - OUTER_MARGIN_VERT);

    self.backgroundView.frame = cf;
    self.backgroundView.center = CGPointMake(nextViewSize.width / 2.0,
                                             //nextViewSize.height / 2.0);
                                             self.backgroundView.center.y);
    
    if (IS_IPAD)
        self.backgroundView.backgroundColor = [UIColor blackColor];
    else
        self.backgroundView.backgroundColor = [UIColor colorWithRed:0.0f
                                                              green:0.0f
                                                               blue:0.0f
                                                              alpha:0.8f];

    self.contentView.frame = self.backgroundView.frame;

    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.layer.cornerRadius = 5;
    self.backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backgroundView.layer.borderWidth = 2.0f;
    
    if (IS_IPAD) {
        self.backgroundView.frame = CGRectMake(0, 0, cf.size.width, cf.size.height);
        self.contentView.frame = self.backgroundView.frame;
        
        actualFrame = CGRectMake((nextViewSize.width - cf.size.width) / 2.0,
                                 (nextViewSize.height - cf.size.height) / 2.0,
                                 cf.size.width, cf.size.height);
    }
}


@end
