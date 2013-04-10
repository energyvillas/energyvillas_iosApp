//
//  DPMainMenu.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/26/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DPScrollableViewDelegate <NSObject>

- (void) elementTapped:(id)sender element:(id)element;

@end

@protocol DPScrollableDataSourceDelegate <NSObject>

- (void) loadPage:(int)contentIndex
           inView:(UIView *)container
            frame:(CGRect)frame;

@end
