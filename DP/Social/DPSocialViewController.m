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
#import "DPAppHelper.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>



#define SOCIAL_ITEMS_CNT ((int)3) // 6
#define COL_COUNT ((int)3) // 3
#define ROW_COUNT ((int)1) // 2

#define MARGIN_HORZ ((CGFloat)20.0f)
#define MARGIN_VERT ((CGFloat)16.0f)
#define SPACER_HORZ ((CGFloat)(2.0f * MARGIN_HORZ))
#define SPACER_VERT ((CGFloat)MARGIN_VERT)

#define OUTER_MARGIN_HORZ ((CGFloat)10.0f)
#define OUTER_MARGIN_VERT ((CGFloat)10.0f)




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
    self.onClose = nil;
    [self setFacebookView:nil];
    [self setTwitterView:nil];
    [self setLinkedinView:nil];
    [self setEmailView:nil];
    [self setFavsView:nil];
    [self setOtherView:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [self setBtnClose:nil];
    [self setContentView:nil];
    self.onClose = nil;
    [self setFacebookView:nil];
    [self setTwitterView:nil];
    [self setLinkedinView:nil];
    [self setEmailView:nil];
    [self setFavsView:nil];
    [self setOtherView:nil];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self internalLayoutSubViews];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self styleViews];
}
//- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
////    if (!IS_IPAD)
////        dispatch_async(dispatch_get_main_queue(), ^{
////            [self doOnBtnTap:-1];
////        });
//}

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
    if (indx == -1)
        [[DPAppHelper sharedInstance] playSoundSpitSplat];
    
    if (IS_IPAD) {
        [self dismissViewControllerAnimated:NO completion:^{
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
        if (itemView.tag > 0 && !itemView.hidden)
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

-(BOOL) isSocialItemAvailable:(int)tag {
	switch (tag) {
		case SOCIAL_ACT_FACEBOOK:
			return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];

		case SOCIAL_ACT_TWITTER:
			return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];

		case SOCIAL_ACT_LINKEDIN:
			return NO;

		case SOCIAL_ACT_EMAIL:
			return [MFMailComposeViewController canSendMail];

		case SOCIAL_ACT_FAVS:
			return NO;

		case SOCIAL_ACT_OTHER:
			return NO;

		default:
			return NO;
	}
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
    UIImage *img = [UIImage imageNamed:[self calcSocialBtnImageName:(int)btn.tag highlight:NO]];
    [btn setImage:img forState:UIControlStateNormal];
    img = [UIImage imageNamed:[self calcSocialBtnImageName:(int)btn.tag highlight:YES]];
    [btn setImage:img forState:UIControlStateHighlighted];

    lbl.textColor = [UIColor whiteColor];
    lbl.frame = CGRectMake((IMG_WIDTH - lbl.frame.size.width) / 2.0,
                           IMG_HEIGHT + LBL_BTN_SPACE,
                           lbl.frame.size.width,
                           lbl.frame.size.height);
    CGSize result = CGSizeMake(IMG_WIDTH, IMG_HEIGHT + LBL_BTN_SPACE + lbl.frame.size.height);
    
    return result;
}

-(void) styleViews {
	self.contentView.layer.masksToBounds = YES;
	self.contentView.layer.cornerRadius = 5;
	self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
	self.contentView.layer.borderWidth = 2.0f;

	self.contentView.backgroundColor = IS_IPAD
		? [UIColor blackColor]
		: [UIColor colorWithWhite:0.0f alpha:0.8f];

	if (!IS_IPAD || Is_iOS_Version_GreaterEqualThan(@"8.0"))
		self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.35f];
	else
		self.view.backgroundColor = [UIColor clearColor];

	for (UIView *itemView in self.contentView.subviews)
		if (itemView.tag > 0 && !itemView.hidden) {
			UILabel *lbl = itemView.subviews[0];
			UIButton *btn = itemView.subviews[1];

			if (![self isSocialItemAvailable:(int)itemView.tag]) {
				itemView.userInteractionEnabled = NO;
				btn.alpha = 0.35f;
				lbl.alpha = 0.35f;
			} else {
				itemView.userInteractionEnabled = YES;
				btn.alpha = 1.0f;
				lbl.alpha = 1.0f;
			}
		}
}


-(CGSize) internalLayoutButtonsGridInFrame:(CGRect)frm {
	CGFloat COL_WIDTH = 0;
	CGFloat ROW_HEIGHT = 0;

	CGSize sz = CGSizeZero;

	for (UIView *itemView in self.contentView.subviews)
		if (itemView.tag > 0 && !itemView.hidden) {
			sz = [self layoutItem:itemView];
			COL_WIDTH = MAX(COL_WIDTH, sz.width);
			ROW_HEIGHT = MAX(ROW_HEIGHT, sz.height);
		}

	for (UIView *itemView in self.contentView.subviews)
		if (itemView.tag > 0) {
			int row = (int)(itemView.tag - 1) / COL_COUNT;
			int col = (int)(itemView.tag - 1) % COL_COUNT;

			itemView.backgroundColor = [UIColor clearColor];
			itemView.frame = CGRectMake(MARGIN_HORZ + col * (SPACER_HORZ + COL_WIDTH),
										MARGIN_VERT + row * (SPACER_VERT + ROW_HEIGHT),
										COL_WIDTH, ROW_HEIGHT);
		}

	CGSize res = CGSizeMake(
					 COL_COUNT * COL_WIDTH + (COL_COUNT - 1) * SPACER_HORZ + 2 * MARGIN_HORZ,
					 ROW_COUNT * ROW_HEIGHT + (ROW_COUNT - 1) * SPACER_VERT + 2 * MARGIN_VERT);

	// btn close
	self.btnClose.frame = CGRectMake((res.width - self.btnClose.bounds.size.width) / 2.0,
									 res.height,
									 self.btnClose.bounds.size.width,
									 self.btnClose.bounds.size.height);

	res.height += self.btnClose.bounds.size.height + MARGIN_VERT;

	return res;
}

-(void) internalLayoutSubViews {
    CGSize nextViewSize = [UIApplication sizeInOrientation:INTERFACE_ORIENTATION];
	// layout buttons and calc the required frame to hold them all..
	CGRect frm = CGRectInset(CGRectMake(0.0f, 0.0f, nextViewSize.width, nextViewSize.height),
							 OUTER_MARGIN_HORZ, 0.0f);
	CGSize frmSize = [self internalLayoutButtonsGridInFrame:frm];

	CGPoint frmOrigin;
	if (IS_IPAD && IS_LANDSCAPE && Is_iOS_Version_LessThan(@"8.0")) {
		frmOrigin = CGPointMake((CGRectGetWidth(self.view.frame) - frmSize.width) / 2.0f,
								nextViewSize.height - frmSize.height - OUTER_MARGIN_VERT);
	} else {
		frmOrigin = CGPointMake((nextViewSize.width - frmSize.width) / 2.0f,
								nextViewSize.height - frmSize.height - OUTER_MARGIN_VERT);
	}

	frm = CGRectMake(frmOrigin.x, frmOrigin.y, frmSize.width, frmSize.height);
	self.contentView.frame = frm;
}


@end
