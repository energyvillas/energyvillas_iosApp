//
//  DPCategoryLoader.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataLoader.h"

@interface DPCategoryLoader : DPDataLoader

- (id) initWithView:(UIView *)indicatorcontainer
        useInternet:(BOOL)useInternet
         useCaching:(BOOL)useCaching
           category:(int)ctgID
               lang:(NSString *)aLang
      localResource:(NSString *)plistFile;

- (id) initWithView:(UIView *)indicatorcontainer
        useInternet:(BOOL)useInternet
         useCaching:(BOOL)useCaching
           category:(int)ctgID
               lang:(NSString *)aLang
          localData:(NSArray *)localData;


@end
