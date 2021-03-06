//
//  DPBannersLoader.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataLoader.h"

@interface DPBannersLoader : DPDataLoader

- (id) initWithView:(UIView *)indicatorcontainer
              group:(int)grpID
               lang:(NSString *)aLang
          localData:(NSArray *)localData;

@end
