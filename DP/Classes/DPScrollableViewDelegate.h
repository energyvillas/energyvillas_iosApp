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

@optional
- (void) scrolledToPage:(int)newPage fromPage:(int)oldPage;

@end

@protocol DPScrollableDataSourceDelegate <NSObject>

@optional

- (void) loadPage:(int)contentIndex
           inView:(UIView *)container
            frame:(CGRect)frame;

- (UIView *) createViewFor:(int)contentIndex
                     frame:(CGRect)frame;

- (void) postProcessView:(UIView *)aView
            contentIndex:(int)contentIndex
                   frame:(CGRect)frame;

- (UILabel *) createLabelFor:(int)contentIndex
                       frame:(CGRect)frame
                       title:(NSString *)title;

- (void) postProcessLabel:(UILabel *)aLabel
             contentIndex:(int)contentIndex
                    frame:(CGRect)frame;
@end
