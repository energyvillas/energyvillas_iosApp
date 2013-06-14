//
//  DPCTGViewController.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 6/6/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPDataLoader.h"

@interface DPCTGViewController : UINavContentViewController <DPDataLoaderDelegate>

- (id) initWithCategory:(int)ctgID fromParent:(int)pid useDeviceType:(BOOL)usedevicetype;
- (id) initWithCategory:(int)ctgID useDeviceType:(BOOL)usedevicetype;

@end
