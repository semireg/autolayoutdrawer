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

#define DRAWER_NAME @"Drawer"
#define MOVEMENT_CONSTRAINT_NAME @"Drawer Movement"
#define DRAWER_HEIGHT 100

@implementation SemiAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSView *drawerView = [self viewForDrawer];
    [self.window.contentView addSubview:drawerView];
    StretchHorizontallyToSuperview(drawerView, 0, 1000);
    CONSTRAIN_HEIGHT(drawerView, DRAWER_HEIGHT);
    [[self movementConstraintForDrawerView:drawerView] install];
}

- (IBAction)toggleDrawer:(id)sender {
    NSView *contentView = self.window.contentView;
    NSView *drawerView = [contentView viewNamed:DRAWER_NAME];
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
}

-(NSLayoutConstraint*)movementConstraintForDrawerView:(NSView*)aDrawerView
{
    NSLayoutConstraint *movementConstraint = [aDrawerView constraintNamed:MOVEMENT_CONSTRAINT_NAME];
    
    if(!movementConstraint)
    {
        NSLog(@"%s - building constraint", __PRETTY_FUNCTION__);
        movementConstraint = CONSTRAINT_ALIGNING_BOTTOM(aDrawerView, -1 * DRAWER_HEIGHT);
        movementConstraint.nametag = MOVEMENT_CONSTRAINT_NAME;
    }
    
    return movementConstraint;
}

-(NSView*)viewForDrawer
{
    NSView *drawerView = self.drawerContentView; //[[NSView alloc] initWithFrame:NSMakeRect(0, 0, -1, -1)];
    drawerView.nametag = @"Drawer";
    drawerView.backgroundColor = [NSColor greenColor];
    [drawerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return drawerView;
}

@end
