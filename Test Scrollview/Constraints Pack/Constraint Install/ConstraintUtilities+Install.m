/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "ConstraintUtilities+Install.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
void SE_InstallConstraints(NSArray *constraints, NSUInteger priority, NSString *nametag)
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (![constraint isKindOfClass:[NSLayoutConstraint class]])
            continue;
        if (priority)
            [constraint SE_install:priority];
        else
            [constraint SE_install];
        
        if ([constraint respondsToSelector:@selector(setNametag:)])
        {
            [constraint performSelector:@selector(setNametag:) withObject:nametag];
        }
    }
}

void SE_InstallConstraint(NSLayoutConstraint *constraint, NSUInteger priority, NSString *nametag)
{
    SE_InstallConstraints(@[constraint], priority, nametag);
}
#pragma GCC diagnostic pop

void SE_RemoveConstraints(NSArray *constraints)
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (![constraint isKindOfClass:[NSLayoutConstraint class]])
            continue;
        [constraint SE_remove];
    }
}

NSArray *SE_ConstraintsSourcedFromIB(NSArray *constraints)
{
    NSMutableArray *results = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (constraint.shouldBeArchived)
            [results addObject:constraint];
    }
    return results;
}

#pragma mark - Views

#pragma mark - Hierarchy
@implementation VIEW_CLASS (HierarchySupport)

// Return an array of all superviews
- (NSArray *) SE_superviews
{
    NSMutableArray *array = [NSMutableArray array];
    VIEW_CLASS *view = self.superview;
    while (view)
    {
        [array addObject:view];
        view = view.superview;
    }
    
    return array;
}

// Return an array of all subviews
- (NSArray *) SE_allSubviews
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (VIEW_CLASS *view in self.subviews)
    {
        [array addObject:view];
        [array addObjectsFromArray:[view SE_allSubviews]];
    }
    
    return array;
}

// Test if the current view has a superview relationship to a view
- (BOOL) SE_isAncestorOfView: (VIEW_CLASS *) aView
{
    return [aView.SE_superviews containsObject:self];
}

// Return the nearest common ancestor between self and another view
- (VIEW_CLASS *) SE_nearestCommonAncestorToView: (VIEW_CLASS *) aView
{
    // Check for same view
    if (self == aView)
        return self;
    
    // Check for direct superview relationship
    if ([self SE_isAncestorOfView:aView])
        return self;
    if ([aView SE_isAncestorOfView:self])
        return aView;
    
    // Search for indirect common ancestor
    NSArray *ancestors = self.SE_superviews;
    for (VIEW_CLASS *view in aView.SE_superviews)
        if ([ancestors containsObject:view])
            return view;
    
    // No common ancestor
    return nil;
}
@end

#pragma mark - Constraint-Ready Views
@implementation VIEW_CLASS (ConstraintReadyViews)
+ (instancetype) SE_view
{
    VIEW_CLASS *newView = [[VIEW_CLASS alloc] initWithFrame:CGRectZero];
    newView.translatesAutoresizingMaskIntoConstraints = NO;
    return newView;
}
@end

#pragma mark - NSLayoutConstraint

#pragma mark - View Hierarchy
@implementation NSLayoutConstraint (ViewHierarchy)
// Cast the first item to a view
- (VIEW_CLASS *) SE_firstView
{
    return self.firstItem;
}

// Cast the second item to a view
- (VIEW_CLASS *) SE_secondView
{
    return self.secondItem;
}

// Are two items involved or not
- (BOOL) SE_isUnary
{
    return self.secondItem == nil;
}

// Return NCA
- (VIEW_CLASS *) SE_likelyOwner
{
    if (self.SE_isUnary)
        return self.SE_firstView;
    
    return [self.SE_firstView SE_nearestCommonAncestorToView:self.SE_secondView];
}


/*
 From NSLayoutConstraint.h:
 
 When a view is archived, it archives some but not all constraints in its -constraints array.  The value of shouldBeArchived informs UIView if a particular constraint should be archived by UIView / NSView. If a constraint is created at runtime in response to the state of the object, it isn't appropriate to archive the constraint - rather you archive the state that gives rise to the constraint.  Since the majority of constraints that should be archived are created in Interface Builder (which is smart enough to set this prop to YES), the default value for this property is NO.
 */

- (ConstraintSourceType) SE_sourceType
{
    ConstraintSourceType result = ConstraintSourceTypeCustom;
    if (self.shouldBeArchived)
    {
        result = ConstraintSourceTypeSatisfaction;
        NSString *description = self.debugDescription;
        if ([description rangeOfString:@"ambiguity"].location != NSNotFound)
            result = ConstraintSourceTypeDisambiguation;
        else if ([description rangeOfString:@"fixed frame"].location != NSNotFound)
            result = ConstraintSourceTypeInferred;
    }
    return result;
}
@end

#pragma mark - Self Install
@implementation NSLayoutConstraint (SelfInstall)
- (BOOL) SE_install
{
    // Handle Unary constraint
    if (self.SE_isUnary)
    {
        // Add weak owner reference
        [self.SE_firstView addConstraint:self];
        return YES;
    }
    
    // Install onto nearest common ancestor
    VIEW_CLASS *view = [self.SE_firstView SE_nearestCommonAncestorToView:self.SE_secondView];
    if (!view)
    {
        NSLog(@"Error: Constraint cannot be installed. No common ancestor between items.");
        return NO;
    }
    
    [view addConstraint:self];    
    return YES;
}

// Set priority and install
- (BOOL) SE_install: (float) priority
{
    self.priority = priority;
    return [self SE_install];
}

- (void) SE_remove
{
    if (![self.class isEqual:[NSLayoutConstraint class]])
    {
        NSLog(@"Error: Can only uninstall NSLayoutConstraint. %@ is an invalid class.", self.class.description);
        return;
    }
    
    if (self.SE_isUnary)
    {
        VIEW_CLASS *view = self.SE_firstView;
        [view removeConstraint:self];
        return;
    }
    
    // Remove from preferred recipient
    VIEW_CLASS *view = [self.SE_firstView SE_nearestCommonAncestorToView:self.SE_secondView];
    if (!view) return;
    
    // If the constraint not on view, this is a no-op
    [view removeConstraint:self];
}
@end