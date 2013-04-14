//
//  DPCtgScrollViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCtgScrollViewController.h"
#import "DPConstants.h"

@interface DPCtgScrollViewController ()

@end

@implementation DPCtgScrollViewController {
    bool isPortrait;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithContent:(NSArray *)content
                  rows:(int)rows
               columns:(int)columns
            autoScroll:(BOOL)autoscroll {
    self = [super initWithContent:content autoScroll:autoscroll];
    if (self) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
