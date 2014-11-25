//
//  DPCallUsViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPCallUsViewController.h"
#import "DPAppHelper.h"
#import "DPConstants.h"
#import "UIApplication+ScreenDimensions.h"

@interface DPCallUsViewController ()

@property (strong) void (^onClose)(int tag);

@end

@implementation DPCallUsViewController {
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

- (void) dealloc {
    self.backView = nil;
    self.contentView = nil;
    self.btnCall = nil;
    self.btnMail = nil;
    self.btnCancel = nil;
    self.onClose = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.contentView];
    [self doLocalize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackView:nil];
    [self setContentView:nil];
    [self setBtnCall:nil];
    [self setBtnCancel:nil];
    [self setBtnMail:nil];
    [super viewDidUnload];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self internalLayoutSubViews];
}

-(CGRect) calcFrame {
    [self internalLayoutSubViews];
    return actualFrame;
}

- (void) setCompletion:(void (^)(int tag))completion {
    self.onClose = completion;
}

-(void) doLocalize {
    // call
    [self.btnCall setTitle:nil forState:UIControlStateNormal];
    [self.btnCall setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ContactUs/call_%@.png", CURRENT_LANG]]
                  forState:UIControlStateNormal];
    [self.btnCall setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ContactUs/call_%@.png", CURRENT_LANG]]
                  forState:UIControlStateDisabled];
    [self.btnCall setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ContactUs/call_%@_roll.png", CURRENT_LANG]]
                  forState:UIControlStateHighlighted];
    
    if (IS_IPAD)
        self.btnCall.enabled = NO;

    // mail
    [self.btnMail setTitle:nil forState:UIControlStateNormal];
    [self.btnMail setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ContactUs/mail_%@.png", CURRENT_LANG]]
                  forState:UIControlStateNormal];
    [self.btnMail setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ContactUs/mail_%@_roll.png", CURRENT_LANG]]
                  forState:UIControlStateHighlighted];
    
    // cancel
    [self.btnCancel setTitle:nil forState:UIControlStateNormal];
    [self.btnCancel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ContactUs/cancel_%@.png", CURRENT_LANG]]
                  forState:UIControlStateNormal];
    [self.btnCancel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ContactUs/cancel_%@_roll.png", CURRENT_LANG]]
                  forState:UIControlStateHighlighted];
}

// ipad
#define BTN_WIDTH_IPAD ((CGFloat)272.0f) //((CGFloat)339.0f)
#define BTN_HEIGHT_IPAD ((CGFloat)63.0f) //((CGFloat)78.0f)

#define HORZ_MARGIN_IPAD ((CGFloat)30.0f)
#define HORZ_SPACE_IPAD ((CGFloat)10.0f)

#define VERT_MARGIN_IPAD ((CGFloat)30.0f)
#define VERT_SPACE_IPAD ((CGFloat)20.0f)

#define BORDER_WIDTH ((CGFloat)2.0f)

#define WIDTH_IPAD ((CGFloat)(2.0 * (HORZ_MARGIN_IPAD + BORDER_WIDTH + BTN_WIDTH_IPAD) + HORZ_SPACE_IPAD))
#define HEIGHT_IPAD ((CGFloat)(2.0 * (VERT_MARGIN_IPAD + BORDER_WIDTH + BTN_HEIGHT_IPAD) + VERT_SPACE_IPAD))


// iphone
#define BTN_WIDTH_IPHONE ((CGFloat)145.0f)
#define BTN_HEIGHT_IPHONE ((CGFloat)33.0f)

#define HORZ_MARGIN_IPHONE ((CGFloat)5.0f)
#define HORZ_SPACE_IPHONE ((CGFloat)6.0f)

#define VERT_MARGIN_IPHONE ((CGFloat)5.0f)
#define VERT_SPACE_IPHONE ((CGFloat)10.0f)

#define WIDTH_IPHONE ((CGFloat)(2.0 * (HORZ_MARGIN_IPHONE + BTN_WIDTH_IPHONE) + HORZ_SPACE_IPHONE))
#define HEIGHT_IPHONE ((CGFloat)(2.0 * (VERT_MARGIN_IPHONE + BTN_HEIGHT_IPHONE) + VERT_SPACE_IPHONE))

// actual
#define BTN_WIDTH ((CGFloat)(IS_IPAD ? BTN_WIDTH_IPAD : BTN_WIDTH_IPHONE))
#define BTN_HEIGHT ((CGFloat)(IS_IPAD ? BTN_HEIGHT_IPAD : BTN_HEIGHT_IPHONE))

#define HORZ_MARGIN ((CGFloat)(IS_IPAD ? HORZ_MARGIN_IPAD : HORZ_MARGIN_IPHONE))
#define HORZ_SPACE ((CGFloat)(IS_IPAD ? HORZ_SPACE_IPAD : HORZ_SPACE_IPHONE))

#define VERT_MARGIN ((CGFloat)(IS_IPAD ? VERT_MARGIN_IPAD : VERT_MARGIN_IPHONE))
#define VERT_SPACE ((CGFloat)(IS_IPAD ? VERT_SPACE_IPAD : VERT_SPACE_IPHONE))

#define WIDTH ((CGFloat)(IS_IPAD ? WIDTH_IPAD : WIDTH_IPHONE))
#define HEIGHT ((CGFloat)(IS_IPAD ? HEIGHT_IPAD : HEIGHT_IPHONE))


-(void) internalLayoutSubViews {
    CGSize nextViewSize = [UIApplication sizeInOrientation:INTERFACE_ORIENTATION];

//	if (IS_IPAD && Is_iOS_Version_LessThan(@"8.0"))
//        self.backView.hidden = YES;
//    else
//        self.backView.frame = CGRectMake(0, 20, nextViewSize.width, nextViewSize.height);
	self.backView.hidden = YES;

    CGPoint cntr = CGPointMake(nextViewSize.width / 2.0f,
                               nextViewSize.height / 2.0f); //)self.backView.center;
    CGRect frm = CGRectMake(0, 0, WIDTH, HEIGHT);
    self.contentView.frame = frm;
    self.contentView.center = cntr;
	frm = self.contentView.frame;
    if (IS_IPAD) {
		self.contentView.backgroundColor = [UIColor blackColor];
        self.contentView.layer.borderWidth = BORDER_WIDTH;
        self.contentView.layer.cornerRadius = 8.0f;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
	CGRect btnframe = CGRectMake(0, 0, BTN_WIDTH, BTN_HEIGHT);
    btnframe = CGRectOffset(btnframe, HORZ_MARGIN, VERT_MARGIN);
    self.btnCall.frame = btnframe;
    
    btnframe = CGRectOffset(btnframe, BTN_WIDTH + HORZ_SPACE, 0);
    self.btnMail.frame = btnframe;
    
    btnframe = CGRectOffset(btnframe, -(BTN_WIDTH + HORZ_SPACE) / 2.0f, BTN_HEIGHT + VERT_SPACE);
    self.btnCancel.frame = btnframe;
    
    frm = self.contentView.frame;
	if (IS_IPAD)
	{
		if (IS_LANDSCAPE && Is_iOS_Version_LessThan(@"8.0")){
			frm = CGRectMake((CGRectGetWidth(self.view.frame) - CGRectGetWidth(frm)) / 2.0f,
							 100.0f,
							 frm.size.width,
							 frm.size.height);

			self.contentView.frame = frm;
		} else
		{
			frm = self.contentView.frame;
			frm.origin.y = IS_PORTRAIT ? 194.0f : 100.0f;
			self.contentView.frame = frm;
		}
    }

	if (!IS_IPAD || Is_iOS_Version_GreaterEqualThan(@"8.0"))
		self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.35f];
	else
		self.view.backgroundColor = [UIColor clearColor];
}

- (IBAction)btnTouchupInside:(UIButton *)sender {
    if (IS_IPAD) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.onClose != nil)
                self.onClose((int)sender.tag);
        }];
    } else {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (self.onClose != nil)
            self.onClose((int)sender.tag);
    }
}
@end
