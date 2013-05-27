//
//  DPNextHouseViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPDataLoader.h"

@interface DPNextHouseViewController : UINavContentViewController <UIPickerViewDelegate, UIPickerViewDataSource, DPDataLoaderDelegate>

@property (strong, nonatomic) IBOutlet UIView *htmlView;
@property (strong, nonatomic) IBOutlet UIPickerView *countDownPicker;
@property (strong, nonatomic) IBOutlet UILabel *countDownLabel;


- (id) initWithCategory:(int)ctgid;

@end
