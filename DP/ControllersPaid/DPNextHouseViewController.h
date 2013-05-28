//
//  DPNextHouseViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPDataLoader.h"

@interface DPNextHouseViewController : UINavContentViewController <DPDataLoaderDelegate>

@property (strong, nonatomic) IBOutlet UIView *htmlView;
@property (strong, nonatomic) IBOutlet UIView *countDownContainerView;

@property (strong, nonatomic) IBOutlet UILabel *topLabel;

@property (strong, nonatomic) IBOutlet UIView *countersView;
@property (strong, nonatomic) IBOutlet UILabel *daysCounter;
@property (strong, nonatomic) IBOutlet UILabel *hoursCounter;
@property (strong, nonatomic) IBOutlet UILabel *minutesCounter;
@property (strong, nonatomic) IBOutlet UILabel *secondsCounter;

@property (strong, nonatomic) IBOutlet UIView *labelsView;
@property (strong, nonatomic) IBOutlet UILabel *daysLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *minutesLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondsLabel;

- (id) initWithCategory:(int)ctgid;

@end
