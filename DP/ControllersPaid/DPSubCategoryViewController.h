//
//  DPSubCategoryViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/7/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPDataLoader.h"
#import "Category.h"

@interface DPSubCategoryViewController : UINavContentViewController <DPDataLoaderDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *titleView;
@property (strong, nonatomic) IBOutlet UIView *photoView;
@property (strong, nonatomic) IBOutlet UIView *htmlView;
@property (strong, nonatomic) IBOutlet UIView *subCtgView;


- (id) initWithCategory:(Category *)ctg;

@end
