//
//  UINavContentViewController.m
//  testSV
//
//  Created by george on 16/3/13.
//  Copyright (c) 2013 george. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"

@interface UINavContentViewController ()
@end

@implementation UINavContentViewController {
    UISegmentedControl *_langSelControl;
}


- (void) hookToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotified:)
                                                 name:DPN_currentLangChanged
                                               object:nil];
}

- (void) onNotified:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:DPN_currentLangChanged]) {
        NSLog (@"Successfully received the test notification!");
        
        [self doLocalize];
    }
}

- (void) doLocalize {
    
}


- (void) viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self hookToNotifications];
    [self setupNavBar];
}

- (void) viewWillAppear:(BOOL)animated {
    [self layoutForOrientation:INTERFACE_ORIENTATION fixtop:NO];
}

- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation fixtop:(BOOL)fixtop {
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}
/*
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutForOrientation:toInterfaceOrientation fixtop:YES];
}
*/
/*
- (UIButton *) createButtonWithImageUrl:(NSURL *)imgUrl
                                 tag:(int)index
                              action:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (sel)
        [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIImage *img = [UIImage imageNamed: imgName];
    button.frame = CGRectMake(0, 0, img.size.width, 30);
    [button setImage: img forState:UIControlStateNormal];
    [button setTag: index];
    
    return button;
}
*/

- (UISegmentedControl*) langSelControl {
    if (!_langSelControl) {
//        _langSelControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"en",@"el", nil]];
        _langSelControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"flag-us.png"], [UIImage imageNamed:@"flag-gr.png"], nil]];
        
        [_langSelControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [_langSelControl addTarget:self action:@selector(langSelControlPressed:) forControlEvents:UIControlEventValueChanged];
        
        if ([[DPAppHelper sharedInstance].currentLang isEqualToString:@"en"])
            _langSelControl.selectedSegmentIndex = 0;
        else if ([[DPAppHelper sharedInstance].currentLang isEqualToString:@"el"])
            _langSelControl.selectedSegmentIndex = 1;

        _langSelControl.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
        CGRect newFrame = CGRectMake(0, 0, 70, 30);
//        newFrame.size.height = self.navigationController.navigationBar.frame.size.height * .8;
        _langSelControl.frame = newFrame;
         
    }    
    return _langSelControl;
}

- (void) langSelControlPressed:(id)sender {
    if (sender == _langSelControl) {
        int indx = _langSelControl.selectedSegmentIndex;
        if (indx >= 0) {
            for (int i=0; i<[_langSelControl.subviews count]; i++)
            {
                if ([_langSelControl.subviews[i] respondsToSelector:@selector(isSelected)]) {
                    if ([_langSelControl.subviews[i] isSelected])
                        [_langSelControl.subviews[i] setTintColor:[UIColor lightGrayColor]];
                    else
                        [_langSelControl.subviews[i] setTintColor:[UIColor blackColor]];
                }
            }
            if (indx == 0)
                [DPAppHelper sharedInstance].currentLang = @"en";
            else if (indx == 1)
                [DPAppHelper sharedInstance].currentLang = @"el";
        }
    }
}

- (void) setupNavBar {
    if (!self.navigationController) return;
    
    self.navigationItem.title = nil;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.hidesBackButton = YES;

    bool ischild = self.navigationController.viewControllers[0] != self &&
                    self.navigationController.topViewController == self;
    
    NSString *lang = [DPAppHelper sharedInstance].currentLang;
    NSString *imgName = [NSString stringWithFormat: @"3D_logo_horizontal_%@.png", lang];
    
    UIBarButtonItem *titleitem = [[UIBarButtonItem alloc]
                                  initWithCustomView: [self
                                                       createButtonWithImage: imgName
                                                       highlightedImage: imgName
                                                       tag:103
                                                       action:nil]];

    if (ischild) {
        self.navigationItem.leftBarButtonItems = @[
                                                   [[UIBarButtonItem alloc]
                                                    initWithCustomView: [self
                                                                         createButtonWithImage:@"go-previous-view.png"
                                                                         tag:103
                                                                         action:@selector(closeView:)]],
                                                   
                                                   titleitem
                                                   ];
    }
    else
        self.navigationItem.leftBarButtonItems = @[titleitem];
    
    
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc]
                                                 initWithCustomView: [self
                                                                      createButtonWithImage:@"bookmark-new-2.png"
                                                                      tag:103
                                                                      action:@selector(showView:)]],

                                                [[UIBarButtonItem alloc]
                                                 initWithCustomView: [self
                                                                      createButtonWithImage:@"bookmark-new-2.png"
                                                                      tag:104
                                                                      action:@selector(showView:)]],

                                                [[UIBarButtonItem alloc]
                                                 initWithCustomView: [self langSelControl]]
 
//                                                [[UIBarButtonItem alloc]
//                                                 initWithCustomView: [self
//                                                                      createButtonWithImage:@"flag-gr.png"
//                                                                      tag:102
//                                                                      action:@selector(showView:)]],
//                                                
//
//                                                [[UIBarButtonItem alloc]
//                                                 initWithCustomView: [self
//                                                                      createButtonWithImage:@"flag-us.png"
//                                                                      tag:101
//                                                                      action:@selector(showView:)]]
                                                ];
    
    [self langSelControlPressed:_langSelControl];
}

- (UIButton *) createButtonWithImage:(NSString *)imgName
                                 tag:(int)index
                              action:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (sel)
        [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIImage *img = [UIImage imageNamed: imgName];
    button.frame = CGRectMake(0, 0, img.size.width, 30);
    [button setImage: img forState:UIControlStateNormal];
    [button setTag: index];
    
    return button;
}

- (UIButton *) createButtonWithImage:(NSString *)imgName
                    highlightedImage:(NSString *)imgNameHigh
                                 tag:(int)index
                              action:(SEL)sel {
    UIButton *button = [self createButtonWithImage:imgName tag:index action:sel];
    [button setImage:[UIImage imageNamed: imgNameHigh] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed: imgNameHigh] forState:UIControlStateSelected];
    
    return button;
}

- (void) closeView: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// PENDING use a delegate protocol form handling clicks
- (void) showView: (id) sender {
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    if (bbi == nil) return;
    
    switch (bbi.tag) {
        case 101:
            // do 101 stuff
            break;
        case 102:
            // do 102 stuff
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
