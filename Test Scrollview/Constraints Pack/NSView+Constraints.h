//
//  NSView+Constraints.h
//  Test Scrollview
//
//  Created by Caylan Larson on 2/12/14.
//  Copyright (c) 2014 Semireg Industries. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Constraints)

// Single Constraints
-(NSLayoutConstraint*)SE_constraintHeight:(NSNumber*)height;
-(NSLayoutConstraint*)SE_constraintAligningBottom:(NSNumber*)constant;

// Multiple Constraints
-(void)SE_stretchHorizontallyToSuperviewWithIndent:(NSNumber*)indent priority:(NSNumber*)priority;

// Helper
-(void)SE_prepareForConstraints;
-(void)SE_prepareForConstraintsWithNametag:(NSString*)nametag;


@end
