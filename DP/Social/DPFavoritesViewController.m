//
//  DPFavoritesViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPFavoritesViewController.h"
#import "DPAppHelper.h"
#import "DPConstants.h"
#import "DPImageContentViewController.h"
#import "DPHtmlContentViewController.h"
#import "DPVimeoPlayerViewController.h"


@interface DPFavoritesViewController ()

@property (strong, nonatomic, readonly, getter = getFavorites) NSArray *favorites;

@end

@implementation DPFavoritesViewController {
    int currIndex;
}

@synthesize favorites = _favorites;

- (id) init {
    self = [super init];
    if (self) {
        currIndex = -1;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView reloadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *) getFavorites {
    if (!_favorites) {
        NSArray *list = [[[DPAppHelper sharedInstance] favoriteArticles] allValues];
        _favorites = [list sortedArrayWithOptions:NSSortStable
                                  usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                      Article *a1 = obj1;
                                      Article *a2 = obj2;
                                      return [a1.title localizedCaseInsensitiveCompare:a2.title];
//                                      if(a1.orderNo < a2.orderNo)
//                                          return NSOrderedAscending;
//                                      else if(a1.orderNo > a2.orderNo)
//                                          return NSOrderedDescending;
//                                      else
//                                          return NSOrderedSame;
                                  }];
    }
    
    return _favorites;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self doLayoutSubViews:YES];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self doLayoutSubViews:YES];    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    self.tableView.frame = CGRectMake(0, top, w, h);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"%@", [tableView class]);
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
//                                                            forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    Article *article = self.favorites[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = article.title;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;//DisclosureIndicator;
   
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)                            tableView:(UITableView *)tableView
     accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    currIndex = indexPath.row;
    [self showArticleAtIndex:currIndex];
}

- (void) showArticleAtIndex:(int)indx {
    Article *article = self.favorites[indx];
    
    UINavContentViewController *vc = nil;
    if (article.body != nil) {
        vc = [[DPHtmlContentViewController alloc] initWithHTML:article.body];
    } else if (article.videoUrl != nil && article.videoUrl.length > 0) {
        NSString *videourl = article.videoUrl;
        vc = [[DPVimeoPlayerViewController alloc] initWithUrl:videourl];
    } else if (article.imageUrl != nil) {
        if (isLocalUrl(article.imageUrl))
            vc = nil;// [[DPImageContentViewController alloc] initWithImageName:[self calcImageName:article.imageUrl]];
        else 
            vc = [[DPImageContentViewController alloc] initWithArticle:article
                                                           showNavItem:YES];
    }
    
    if (vc) {
        vc.navigatorDelegate = self;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // Navigation logic may go here. Create and push another view controller.
//    Article *article = self.favorites[indexPath.row];
//    
//    UIViewController *vc = nil;
//    if (article.body != nil) {
//        vc = [[DPHtmlContentViewController alloc] initWithHTML:article.body];
//    } else if (article.videoUrl != nil && article.videoUrl.length > 0) {
//        NSString *videourl = article.videoUrl;
//        vc = [[DPVimeoPlayerViewController alloc] initWithUrl:videourl];
//    } else if (article.imageUrl != nil) {
//        if (isLocalUrl(article.imageUrl))
//            vc = nil;// [[DPImageContentViewController alloc] initWithImageName:[self calcImageName:article.imageUrl]];
//        else
//            vc = [[DPImageContentViewController alloc] initWithArticle:article];
//    }
//
//    if (vc)
//        [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

//==============================================================================
#pragma mark - nav bar button selection
//- (BOOL) showNavBar {
//    return self.navigationController != nil;
//}
- (BOOL) showNavBarLanguages {
    return NO;
}
- (BOOL) showNavBarAddToFav {
    return NO;
}
- (BOOL) showNavBarSocial {
    return NO;
}
//- (BOOL) showNavBarInfo {
//    return NO;
//}
//==============================================================================

#pragma mark - DPNavigatorDelegate methods
-(void) next {
    int nxt = currIndex + 1;
    if (nxt < [self itemsCount]) {
        [self.navigationController popViewControllerAnimated:NO];
        currIndex = nxt;
        [self showArticleAtIndex:nxt];
    }
}
-(void) prev {
    int prv = currIndex - 1;
    if (prv >= 0) {
        [self.navigationController popViewControllerAnimated:NO];
        currIndex = prv;
        [self showArticleAtIndex:prv];
    }
}

- (int) currentItemIndex {
    if (self.favorites && [self itemsCount] > 0)
        return currIndex;
    
    return -1;
}

- (int) itemsCount {
    if (self.favorites)
        return self.favorites.count;
    
    return 0;
}

@end
