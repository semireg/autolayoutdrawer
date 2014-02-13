/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "NametagUtilities.h"

#pragma mark - Named Views
@implementation VIEW_CLASS (Nametags)
// All tags in use
- (NSArray *) SE_nametags
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.SE_nametag && ![array containsObject:constraint.SE_nametag])
            [array addObject:constraint.SE_nametag];
    }
    
    return array;
}

// First matching view
- (VIEW_CLASS *) SE_viewWithNametag: (NSString *) aName
{
    if (!aName) return nil;
    
    // Is this the right view?
    if ([self.SE_nametag isEqualToString:aName])
        return self;
    
    // Recurse depth first on subviews
    for (VIEW_CLASS *subview in self.subviews)
    {
        VIEW_CLASS *resultView = [subview SE_viewNamed:aName];
        if (resultView) return resultView;
    }
    
    // Not found
    return nil;
}

// All matching views
- (NSArray *) SE_viewsWithNametag: (NSString *) aName
{
    if (!aName) return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    if ([self.SE_nametag isEqualToString:aName])
        [array addObject:self];
    
    // Recurse depth first on subviews
    for (VIEW_CLASS *subview in self.subviews)
    {
        NSArray *results = [subview SE_viewsNamed:aName];
        if (results && results.count)
            [array addObjectsFromArray:results];
    }
    
    return array;
}

// First matching view
- (VIEW_CLASS *) SE_viewNamed: (NSString *) aName
{
    if (!aName) return nil;
    return [self SE_viewWithNametag:aName];
}

// All matching views
- (NSArray *) SE_viewsNamed: (NSString *) aName
{
    if (!aName) return nil;
    return [self SE_viewsWithNametag:aName];
}
@end

#pragma mark - Description

@implementation VIEW_CLASS (DescriptionUtility)

// Simple Apple-style frame
- (NSString *) SE_readableFrame
{
    return [NSString stringWithFormat:@"(%d %d; %d %d)" , (int) self.frame.origin.x, (int) self.frame.origin.y, (int) self.frame.size.width, (int) self.frame.size.height];
}

// Recursively travel down the view tree, increasing the indentation level for children
- (void) SE_dumpView: (VIEW_CLASS *) aView atIndent: (int) indent into:(NSMutableString *) outstring
{
    for (int i = 0; i < indent; i++)
        [outstring appendString:@"--"];
    [outstring appendFormat:@"[%2d] <%@>", indent, aView.SE_objectIdentifier];
    if (aView.SE_nametag)
        [outstring appendFormat:@" [%@]", aView.SE_nametag];
    [outstring appendFormat:@" %@" , aView.SE_readableFrame];
    [outstring appendString:@"\n"];
    for (VIEW_CLASS *view in aView.subviews)
        [self SE_dumpView:view atIndent:indent + 1 into:outstring];
}

// Start the tree recursion at level 0 with the root view
- (NSString *) SE_viewTree
{
    NSMutableString *outstring = [NSMutableString string];
    [outstring appendString:@"\n"];
    [self SE_dumpView:self atIndent:0 into:outstring];
    return outstring;
}

/*
 NOTE ON OS X:  NSView method _subtreeDescription
 */

@end
