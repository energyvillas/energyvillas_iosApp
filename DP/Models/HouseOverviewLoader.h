//
//  HouseOverviewLoader.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataLoader.h"

@interface HouseOverviewLoader : DPDataLoader

- (id) initWithView:(UIView *)indicatorcontainer
               lang:(NSString *)aLang
           category:(int)ctgid;

@end
