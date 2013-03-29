//
//  UINavContentViewController.m
//  testSV
//
//  Created by george on 16/3/13.
//  Copyright (c) 2013 george. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPConstants.h"

@interface UINavContentViewController ()
@end

@implementation UINavContentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (void) setupNavBar {
    if (!self.navigationController) return;
    
    self.navigationItem.title = nil;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.hidesBackButton = YES;

    bool ischild = self.navigationController.viewControllers[0] != self &&
                    self.navigationController.topViewController == self;
    
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
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
                                                 initWithCustomView: [self
                                                                      createButtonWithImage:@"flag-gr.png"
                                                                      tag:102
                                                                      action:@selector(showView:)]],
                                                

                                                [[UIBarButtonItem alloc]
                                                 initWithCustomView: [self
                                                                      createButtonWithImage:@"flag-us.png"
                                                                      tag:101
                                                                      action:@selector(showView:)]]
                                                ];
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
