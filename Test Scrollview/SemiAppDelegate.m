//
//  SemiAppDelegate.m
//  Test Scrollview
//
//  Created by Caylan Larson on 2/11/14.
//  Copyright (c) 2014 Semireg Industries. All rights reserved.
//

#import "SemiAppDelegate.h"

#import "ConstraintPack.h"
#import "NSView+BackgroundColor.h"
#import "NSView+Constraints.h"


#define DRAWER_NAME @"Drawer"
#define MOVEMENT_CONSTRAINT_NAME @"Drawer Movement"
#define DRAWER_HEIGHT 100

@implementation SemiAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSView *contentView = self.window.contentView;
    contentView.SE_nametag = @"Content View";
    
    NSView *drawerView = self.drawerContentView;
    [self.window.contentView addSubview:drawerView];

    [drawerView SE_prepareForConstraintsWithNametag:DRAWER_NAME];
    [drawerView SE_stretchHorizontallyToSuperviewWithIndent:@0 priority:@1000];
    [[drawerView SE_constraintHeight:@DRAWER_HEIGHT] SE_install];
    [[self movementConstraintForDrawerView:drawerView] SE_install];
    
    drawerView.SE_backgroundColor = [NSColor greenColor];
}

- (IBAction)toggleDrawer:(id)sender {
    NSView *contentView = self.window.contentView;
    NSView *drawerView = [contentView SE_viewNamed:DRAWER_NAME];
    NSLayoutConstraint *movementConstraint = [self movementConstraintForDrawerView:drawerView];
    
    // Animation
    [NSAnimationContext beginGrouping];
    NSAnimationContext.currentContext.duration = 0.2f;
    
    if(movementConstraint.animator.constant != 0)
    {
        // Close Drawer
        movementConstraint.animator.constant = 0;
    }
    else
    {
        // Open Drawer
        movementConstraint.animator.constant = DRAWER_HEIGHT;
    }
    
    [NSAnimationContext endGrouping];
    [drawerView setNeedsLayout:YES];
    
    [contentView listAllConstraints];
}

-(NSLayoutConstraint*)movementConstraintForDrawerView:(NSView*)aDrawerView
{
    NSLayoutConstraint *movementConstraint = [aDrawerView SE_constraintNamed:MOVEMENT_CONSTRAINT_NAME];
    
    if(!movementConstraint)
    {
        movementConstraint = [aDrawerView SE_constraintAligningBottom:@(-DRAWER_HEIGHT)];
        movementConstraint.SE_nametag = MOVEMENT_CONSTRAINT_NAME;
        [movementConstraint SE_install];
    }
    
    return movementConstraint;
}

@end
