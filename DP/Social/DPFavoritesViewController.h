//
//  DPFavoritesViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"

@interface DPFavoritesViewController : UINavContentViewController <UITableViewDataSource, UITableViewDelegate, DPNavigatorDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
