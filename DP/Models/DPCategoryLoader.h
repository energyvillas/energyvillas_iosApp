//
//  DPCategoryLoader.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataLoader.h"

@interface DPCategoryLoader : DPDataLoader

- (id) initWithController:(UIViewController *)controller
                 category:(int)ctgID
                     lang:(NSString *)aLang
            localResource:(NSString *)plistFile;

@end
