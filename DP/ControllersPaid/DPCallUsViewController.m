//
//  DPCallUsViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    actualFrame = CGRectZero;
    
    [self.view bringSubviewToFront:self.contentView];
    [self doLocalize];
//    [self internalLayoutSubViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackView:nil];
    [self setContentView:nil];
    [self setImgView:nil];
    [self setBtnCall:nil];
    [self setBtnCancel:nil];
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
    [self.btnCall setTitle:DPLocalizedString(@"CALLUS_BTN_Call") forState:UIControlStateNormal];
    [self.btnCancel setTitle:DPLocalizedString(@"CALLUS_BTN_Cancel") forState:UIControlStateNormal];
    self.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"call_us_%@.jpg", CURRENT_LANG]];
}

-(void) internalLayoutSubViews {
    CGSize nextViewSize = [UIApplication sizeInOrientation:INTERFACE_ORIENTATION];
    
    if (IS_IPAD)
        self.backView.hidden = YES;
    else
        self.backView.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);
    
    CGPoint cntr = CGPointMake(nextViewSize.width / 2.0f,
                               nextViewSize.height / 2.0f); //)self.backView.center;
    CGRect frm = IS_IPAD ? CGRectMake(0, 0, 436, 210) : CGRectMake(0, 0, 270, 130);
    self.contentView.frame = frm; //CGRectMake(0, 0, 270, 130);
    self.contentView.center = cntr;
    
    CGRect childframe = self.contentView.bounds;
    self.imgView.frame = childframe;
    
    if (IS_IPAD) {
        CGRect btnframe = CGRectMake(0, 0,
                                     (childframe.size.width / 2.0f) - 20.0f,
                                     32.0f);
        btnframe = CGRectOffset(btnframe,
                                (childframe.size.width - btnframe.size.width) / 2.0f,
                                childframe.size.height - btnframe.size.height - 30.0f);
        self.btnCancel.frame = btnframe;
        self.btnCall.hidden = YES;
    } else {
        CGRect btnframe = CGRectMake(0, 0,
                                     (childframe.size.width / 2.0f) - 20.0f,
                                     32.0f);
        btnframe = CGRectOffset(btnframe,
                                15.0f,
                                childframe.size.height - btnframe.size.height - 10.0f);
        self.btnCall.frame = btnframe;
        btnframe = CGRectOffset(btnframe, btnframe.size.width + 10.0f, 0);
        self.btnCancel.frame = btnframe;
    }
    
    frm = self.contentView.frame;
    if (IS_IPAD) {
        self.contentView.frame = CGRectMake(0, 0,
                                            frm.size.width,
                                            frm.size.height);
        
        actualFrame = CGRectMake((nextViewSize.width - frm.size.width) / 2.0,
                                 (nextViewSize.height - frm.size.height) / 2.0,
                                 frm.size.width,
                                 frm.size.height);
//        actualFrame = self.contentView.frame;
    }
}

- (IBAction)btnTouchupInside:(UIButton *)sender {
    if (IS_IPAD) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.onClose != nil)
                self.onClose(sender.tag);
        }];
    } else {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (self.onClose != nil)
            self.onClose(sender.tag);
    }
}
@end
