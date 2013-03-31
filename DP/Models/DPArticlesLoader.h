//
//  DPArticlesLoader.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataLoader.h"

@interface DPArticlesLoader : DPDataLoader

- (id) initWithController:(UIViewController *)controller category:(int)ctgID lang:(NSString *)aLang;

@end
