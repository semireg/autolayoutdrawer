/*
 
 Erica Sadun, http://ericasadun.com
 
 Thanks for formatting suggestions to Lyle Andrews
 */

#import "ConstraintUtilities+Description.h"
#import "ConstraintUtilities+Layout.h"
#import "ConstraintUtilities+Matching.h"
#import "NSObject-Description.h"

#ifndef UIViewNoIntrinsicMetric
#define UIViewNoIntrinsicMetric -1
#endif

#pragma mark - Constraint Description
@implementation NSLayoutConstraint (StringDescription)

// Transform the attribute to a string
+ (NSString *) nameForLayoutAttribute: (NSLayoutAttribute) anAttribute
{
    switch (anAttribute)
    {
        case NSLayoutAttributeLeft: return @"left";
        case NSLayoutAttributeRight: return @"right";
        case NSLayoutAttributeTop: return @"top";
        case NSLayoutAttributeBottom: return @"bottom";
        case NSLayoutAttributeLeading: return @"leading";
        case NSLayoutAttributeTrailing: return @"trailing";
        case NSLayoutAttributeWidth: return @"width";
        case NSLayoutAttributeHeight: return @"height";
        case NSLayoutAttributeCenterX: return @"centerX";
        case NSLayoutAttributeCenterY: return @"centerY";
        case NSLayoutAttributeBaseline: return @"baseline";
        case NSLayoutAttributeNotAnAttribute:
        default: return @"not-an-attribute";
    }
}

// Transform the attribute to a string
+ (NSString *) nameForFormatOption:(NSLayoutFormatOptions)anOption
{
    NSLayoutFormatOptions option = anOption & NSLayoutFormatAlignmentMask;    
    switch (option)
    {
        case NSLayoutFormatAlignAllLeft: return @"Left Alignment";
        case NSLayoutFormatAlignAllRight: return @"Right Alignment";
        case NSLayoutFormatAlignAllTop: return @"Top Alignment";
        case NSLayoutFormatAlignAllBottom: return @"Bottom Alignment";
        case NSLayoutFormatAlignAllLeading: return @"Leading Alignment";
        case NSLayoutFormatAlignAllTrailing: return @"Trailing Alignment";
        case NSLayoutFormatAlignAllCenterX: return @"CenterX Alignment";
        case NSLayoutFormatAlignAllCenterY: return @"CenterY Alignment";
        case NSLayoutFormatAlignAllBaseline: return @"Baseline Alignment";
        default:
            break;
    }
    
    option = anOption & NSLayoutFormatDirectionMask;
    switch (option)
    {
        case NSLayoutFormatDirectionLeadingToTrailing:
            return @"Leading to Trailing";
        case NSLayoutFormatDirectionLeftToRight:
            return @"Left to Right";
        case NSLayoutFormatDirectionRightToLeft:
            return @"Right to Left";
        default:
            return @"Unknown Format Option";
    }
}


// Transform the relation to a string
+ (NSString *) nameForLayoutRelation: (NSLayoutRelation) aRelation
{
    switch (aRelation)
    {
        case NSLayoutRelationLessThanOrEqual: return @"<=";
        case NSLayoutRelationEqual: return @"==";
        case NSLayoutRelationGreaterThanOrEqual: return @">=";
        default: return @"not-a-relation";
    }
}

// Represent the constraint as a string
- (NSString *) stringValue
{
    if (!self.firstItem)
        return nil;
    
    // Establish firstView.firstAttribute
    NSString *firstView = self.SE_firstView.SE_objectName;
    NSString *firstAttribute = [NSLayoutConstraint nameForLayoutAttribute:self.firstAttribute];
    NSString *firstString = [NSString stringWithFormat:@"<%@>.%@", firstView, firstAttribute];
    
    // Relation
    NSString *relationString =  [NSLayoutConstraint nameForLayoutRelation:self.relation];
    
    // Handle Unary Constraints
    if (self.SE_isUnary)
        return [NSString stringWithFormat:@"%@ %@ %0.01f", firstString, relationString, self.constant];
    
    // Establish secondView.secondAttribute
    NSString *secondView = self.SE_secondView.SE_objectName;
    NSString *secondAttribute = [NSLayoutConstraint nameForLayoutAttribute:self.secondAttribute];
    NSString *secondString = [NSString stringWithFormat:@"<%@>.%@", secondView, secondAttribute];
    
    // Initialize right hand side string
    NSString *rhsRepresentation = secondString;
    
    // Add multiplier
    if (self.multiplier != 1.0f)
        rhsRepresentation = [NSString stringWithFormat:@"%@ * %0.1f", rhsRepresentation, self.multiplier];

    // Initialize constant
    NSString *constantString = @"";
    
    // Positive constant
    if (self.constant > 0.0f)
        constantString = [NSString stringWithFormat:@"+ %0.1f", self.constant];
    
    // Negative constant
    if (self.constant < 0.0f)
        constantString = [NSString stringWithFormat:@"- %0.1f", fabs(self.constant)];
    
    // Add constant
    if (self.constant != 0.0f)
        rhsRepresentation = [NSString stringWithFormat:@"%@ %@", rhsRepresentation, constantString];
    
    // Note source
    NSString *interfaceBuilderString = @"";
    switch (self.SE_sourceType)
    {
        case ConstraintSourceTypeInferred:
            interfaceBuilderString = @"\n         ** Added by IB (inferred position)";
            break;
        case ConstraintSourceTypeDisambiguation:
            interfaceBuilderString = @"\n         ** Added by IB (ambiguity resolution)";
            break;
        case ConstraintSourceTypeSatisfaction:
            interfaceBuilderString = @"\n         ** Added in IB";
            break;
        case ConstraintSourceTypeCustom:
        case ConstraintSourceTypeUnknown:
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@%@", firstString, relationString, rhsRepresentation, interfaceBuilderString];
}
@end

#pragma mark - Format Description

#define IS_LEADING_ATTRIBUTE(_ATTRIBUTE_) [@[@(NSLayoutAttributeTop), @(NSLayoutAttributeLeading), @(NSLayoutAttributeLeft)] containsObject:@(_ATTRIBUTE_)]
#define IS_TRAILING_ATTRIBUTE(_ATTRIBUTE_) [@[@(NSLayoutAttributeBottom), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeRight)] containsObject:@(_ATTRIBUTE_)]
#define IS_UNSUPPORTED_ATTRIBUTE(_ATTRIBUTE_) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeBaseline)] containsObject:@(_ATTRIBUTE_)]

@implementation NSLayoutConstraint (FormatDescription)

// Where possible, transform constraint to visual format
- (NSString *) visualFormat
{
    // I've skipped priorities for these, although that's easily added
    NSString *item1 = self.SE_firstView.SE_objectName;
    NSString *item2 = self.SE_secondView.SE_objectName;
    NSString *relation = [NSLayoutConstraint nameForLayoutRelation:self.relation];
    
    // Don't show == relations
    if ([relation isEqualToString:@"=="])
        relation = @"";
    
    // Key for layout direction
    NSString *hOrV = IS_HORIZONTAL_ATTRIBUTE(self.firstAttribute) ? @"H:" : @"V:";

    // Superview relationships
    BOOL secondViewIsSuperview = (self.SE_firstView.superview == self.SE_secondView);
    BOOL firstViewIsSuperview = (self.SE_secondView.superview == self.SE_firstView);
    
    // Center is not supported, but I've added a little tweak here
    if (self.firstItem && self.secondItem &&
        IS_CENTER_ATTRIBUTE(self.firstAttribute) &&
        IS_CENTER_ATTRIBUTE(self.secondAttribute))
    {
        // Check for unsupported conditions
        if (self.multiplier != 1.0f) return nil;
        if (self.constant != 0.0f) return nil;
        if (self.relation != NSLayoutRelationEqual) return nil;

        // a little fun extension
        if (firstViewIsSuperview)
            return [NSString stringWithFormat:@"%@|~<%@>~|", hOrV, item2];        
        else if (secondViewIsSuperview)
            return [NSString stringWithFormat:@"%@|~<%@>~|", hOrV, item1]; 
        
        return [NSString stringWithFormat:@"%@~[<%@>,<%@>]~", hOrV, item1, item2];
        // return nil;
    }
    
    // Center is not supported
    if (IS_CENTER_ATTRIBUTE(self.firstAttribute))
        return nil;
    if (IS_CENTER_ATTRIBUTE(self.secondAttribute))
        return nil;    
    
    // Valid constraints are either size constraints or edge constraints
    // and never the twain shall meet.
    
    // Size constraint
    if (IS_SIZE_ATTRIBUTE(self.firstAttribute))
    {
        // Handle unary size case
        if (self.SE_isUnary)
        {
            return [NSString stringWithFormat:@"%@[%@(%@%d)]", hOrV, item1, relation, (int) self.constant];
        }
        
        // Attributes have to match for 2-items w/ visual format
        // even if they make sense for aspect. Easy to add to standard
        if (self.firstAttribute != self.secondAttribute)
            return nil;
        
        // Match item to item. I've gone ahead and extended this
        // to multiplier and constant. This is non-standard
        NSMutableString *result = [NSMutableString string];
        [result appendFormat:@"%@[%@(%@<%@>", hOrV, item2, relation, item1];
        
        if (self.multiplier != 1.0f)
            [result appendFormat:@" * %0.1f", self.multiplier];
        
        if (self.constant != 0.0f)
            [result appendFormat:@" %@ %0.1f", (self.constant < 0) ? @"-" : @"+", self.constant];
        
        [result appendString:@")]"];
        return result;
    }
    
    // Must not be unary, that case is already handled -- size only
    if (self.SE_isUnary)
        return nil;
    
    // Edge constraint -- supported is top/bottom, leading/trailing
    // Other edges are not visual format standard.
    // Could extend this to LTR: vs H:
    
    // Toss away baseline refs
    if (self.firstAttribute == NSLayoutAttributeBaseline)
        return nil;
    if (self.secondAttribute == NSLayoutAttributeBaseline)
        return nil;

    // For now, expand to LTR
    // if (IS_UNSUPPORTED_ATTRIBUTE(self.firstAttribute))
    //    return nil;
    // if (IS_UNSUPPORTED_ATTRIBUTE(self.secondAttribute))
    //    return nil;

    // Add support for left and right attributes
    if (IS_UNSUPPORTED_ATTRIBUTE(self.firstAttribute) || IS_UNSUPPORTED_ATTRIBUTE(self.secondAttribute))
        hOrV = @"LTR:";
    
    // Directions must match -- Illegal otherwise except for a few
    // oddball cases, which I'm skipping such as aspect. They aren't
    // supported by visual constraints
    if (IS_VERTICAL_ATTRIBUTE(self.firstAttribute) != IS_VERTICAL_ATTRIBUTE(self.secondAttribute))
        return nil;
    
    // Must have common ancestor. Illegal otherwise
    if (!([self.SE_firstView SE_nearestCommonAncestorToView:self.SE_secondView]))
        return nil;
    
    // Odd multipliers not supported -- although easily added for odd cases
    // but not by current visual constraints.
    if (self.multiplier != 1.0f)
        return nil;
    
    // Handle superview - subview relations
    if (secondViewIsSuperview || firstViewIsSuperview)
    {
        // Mixed edges not supported
        if (self.firstAttribute != self.secondAttribute)
            return nil;
        
        // Which is the view that's explicitly described?
        NSString *describedView = item2;
        if (secondViewIsSuperview)
            describedView = item1;
        
        // Build the output format
        NSMutableString *result = [NSMutableString string];
        [result appendFormat:@"%@", hOrV];
        
        if (IS_LEADING_ATTRIBUTE(self.firstAttribute))
        {
            // Superview at start
            [result appendFormat:@"|-(%@%d)-[%@]", relation, (int) self.constant, describedView];
        }
        else
        {
            // Superview at end
            [result appendFormat:@"[%@]-(%@%d)-|", describedView, relation, (int) self.constant];
        }
        return result;
    }
    
    // Handle leading/trailing and top/bottom pairs,
    // for positive and negative constants
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"%@", hOrV];
    
    // [item2]-?-[item1]
    if (IS_LEADING_ATTRIBUTE(self.firstAttribute) && IS_TRAILING_ATTRIBUTE(self.secondAttribute))
    {
        [result appendFormat:@"[%@]-(%@%d)-[%@]", item2, relation, (int) self.constant, item1];
        return result;
    }
    
    // H:[item1]-?-[item2]
    else if (IS_TRAILING_ATTRIBUTE(self.firstAttribute) && IS_LEADING_ATTRIBUTE(self.secondAttribute))
    {
        [result appendFormat:@"[%@]-(%@%d)-[%@]", item1, relation, (int) self.constant, item2];
        return result;
    }
    
    // Anything else is not supported at this time
    return nil;
}
@end

#pragma mark - Code Description

@implementation NSLayoutConstraint (CodeDescription)
// Transform to code string
+ (NSString *) codeNameForLayoutAttribute: (NSLayoutAttribute) anAttribute
{
    switch (anAttribute)
    {
        case NSLayoutAttributeLeft: return @"NSLayoutAttributeLeft";
        case NSLayoutAttributeRight: return @"NSLayoutAttributeRight";
        case NSLayoutAttributeTop: return @"NSLayoutAttributeTop";
        case NSLayoutAttributeBottom: return @"NSLayoutAttributeBottom";
        case NSLayoutAttributeLeading: return @"NSLayoutAttributeLeading";
        case NSLayoutAttributeTrailing: return @"NSLayoutAttributeTrailing";
        case NSLayoutAttributeWidth: return @"NSLayoutAttributeWidth";
        case NSLayoutAttributeHeight: return @"NSLayoutAttributeHeight";
        case NSLayoutAttributeCenterX: return @"NSLayoutAttributeCenterX";
        case NSLayoutAttributeCenterY: return @"NSLayoutAttributeCenterY";
        case NSLayoutAttributeBaseline: return @"NSLayoutAttributeBaseline";
        case NSLayoutAttributeNotAnAttribute:
        default: return @"NSLayoutAttributeNotAnAttribute";
    }
}

// Transform the relation to a code string
+ (NSString *) codeNameForLayoutRelation: (NSLayoutRelation) aRelation
{
    switch (aRelation)
    {
        case NSLayoutRelationLessThanOrEqual: return @"NSLayoutRelationLessThanOrEqual";
        case NSLayoutRelationEqual: return @"NSLayoutRelationEqual";
        case NSLayoutRelationGreaterThanOrEqual: return @"NSLayoutRelationGreaterThanOrEqual";
        default: return @"<Unknown_Relation>";
    }
}

- (NSString *) codeDescriptionWithBindings: (NSDictionary *) dict
{
    NSString *firstObject = [[dict allKeysForObject:self.firstItem] lastObject];
    if (!firstObject)
        firstObject = [NSString stringWithFormat:@"<%@>", self.SE_firstView.SE_objectIdentifier];
    
    // Handle possible unary constraint
    NSString *secondObject = @"";
    if (self.secondItem)
        secondObject = [[dict allKeysForObject:self.secondItem] lastObject];
    if (!secondObject)
        secondObject = [NSString stringWithFormat:@"<%@>", self.SE_secondView.SE_objectIdentifier];
    
    // Build the description string
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"[NSLayoutConstraint constraintWithItem:%@ attribute:%@ relatedBy:%@ toItem:%@ attribute:%@ multiplier:%f constant:%f];",
     // With book indentation
     // [description appendFormat:@"[NSLayoutConstraint \n    constraintWithItem:%@ attribute:%@ \n    relatedBy:%@ \n    toItem:%@ \n    attribute:%@ \n    multiplier:%f \n    constant:%f];",     
     firstObject,
     [NSLayoutConstraint codeNameForLayoutAttribute:self.firstAttribute],
     [NSLayoutConstraint codeNameForLayoutRelation:self.relation],
     secondObject,
     [NSLayoutConstraint codeNameForLayoutAttribute:self.secondAttribute],
     self.multiplier,
     self.constant
     ];
    return description;
}

- (NSString *) codeDescription
{
    return [self codeDescriptionWithBindings:nil];
}
@end

#pragma mark - Constraint View Utility
@implementation VIEW_CLASS (ConstraintUtility)
// Apple-style frame description
- (NSString *) readableFrame
{
    return READABLERECT(self.frame);
}

// Ditto alignment rect
- (NSString *) readableAlignmentRect
{
    return READABLERECT([self alignmentRectForFrame:self.frame]);
}

- (NSString *) readableAlignmentInsets
{
    return READABLEINSETS(self.alignmentRectInsets);
}
@end

#pragma mark - Self Explanation

@implementation NSLayoutConstraint (SelfDescription)
#define LIKELY_ILLEGAL  @"Likely Illegal"

// Relate view to itself
- (NSString *) describeSelfConstraint
{
    
    if (!self.firstItem)
        return LIKELY_ILLEGAL;
    
    NSString *comparator = @"";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Minimum ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Maximum ";
    
    // Size Constraints
    if (IS_SIZE_ATTRIBUTE(self.firstAttribute) && IS_SIZE_ATTRIBUTE(self.secondAttribute))
    {
        if (self.firstAttribute != self.secondAttribute)
            return [NSString stringWithFormat:@"%@View Aspect", comparator];
        return LIKELY_ILLEGAL;
    }
    
    // Center Constraints
    if (IS_CENTER_ATTRIBUTE(self.firstAttribute) || IS_CENTER_ATTRIBUTE(self.secondAttribute))
        return LIKELY_ILLEGAL;
    
    // Must be along same plane
    if (IS_HORIZONTAL_ATTRIBUTE(self.firstAttribute) != IS_HORIZONTAL_ATTRIBUTE(self.secondAttribute))
        return LIKELY_ILLEGAL;
    
    // Edge Constraints
    return [NSString stringWithFormat:@"%@View Size", comparator];
}

// Describe unary
- (NSString *) describeUnaryConstraint
{
    NSString *comparator = @"Exact ";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Minimum ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Maximum ";
    
    if ((self.firstAttribute == NSLayoutAttributeWidth) || (self.firstAttribute == NSLayoutAttributeHeight))
        return [NSString stringWithFormat:@"%@Sizing", comparator];
    
    return @"Unary Constraint (Misc)";
}

// Relate two views to each other
- (NSString *) describeSiblingConstraint
{
    NSString *comparator = @"Match ";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Relate ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Relate ";
    
    // Must be along same plane
    if (IS_HORIZONTAL_ATTRIBUTE(self.firstAttribute) != IS_HORIZONTAL_ATTRIBUTE(self.secondAttribute))
        return LIKELY_ILLEGAL;
    
    NSString *first = @"Edge";
    NSString *second = @"Edge";
    if (IS_CENTER_ATTRIBUTE(self.firstAttribute))
        first = @"Center";
    if (IS_SIZE_ATTRIBUTE(self.firstAttribute))
        first = @"Size";
    if (IS_CENTER_ATTRIBUTE(self.secondAttribute))
        second = @"Center";
    if (IS_SIZE_ATTRIBUTE(self.secondAttribute))
        second = @"Size";
    
    if ([comparator isEqualToString:@"Match "] && [first isEqualToString:second] && [first isEqualToString:@"Edge"])
        return @"View Sequence";
    
    if ([first isEqualToString:second])
        return [NSString stringWithFormat:@"%@%@s", comparator, first];
    
    return [NSString stringWithFormat:@"%@%@ to %@", comparator, first, second];
}

// Relate view to superview
- (NSString *) describeSuperviewBasedConstraint
{
    NSString *comparator = @"Match ";
    if (self.relation == NSLayoutRelationGreaterThanOrEqual)
        comparator = @"Relate ";
    else if (self.relation == NSLayoutRelationLessThanOrEqual)
        comparator = @"Relate ";
    
    NSString *first = @"Edge";
    NSString *second = @"Edge";
    if (IS_CENTER_ATTRIBUTE(self.firstAttribute))
        first = @"Center";
    if (IS_SIZE_ATTRIBUTE(self.firstAttribute))
        first = @"Size";
    if (IS_CENTER_ATTRIBUTE(self.secondAttribute))
        second = @"Center";
    if (IS_SIZE_ATTRIBUTE(self.secondAttribute))
        second = @"Size";
    
    if ([first isEqualToString:second])
        return [NSString stringWithFormat:@"%@%@ to Superview's %@", comparator, first, first];
    
    if ([self.SE_firstView SE_isAncestorOfView:self.SE_secondView])
        return [NSString stringWithFormat:@"%@%@ to Superview's %@", comparator, second, first];
    
    return [NSString stringWithFormat:@"%@%@ to Superview's %@", comparator, first, second];
}

// Describe the constraint
- (NSString *) constraintDescription
{
    if (self.SE_isUnary)
        return [self describeUnaryConstraint];
    
    if (self.firstItem == self.secondItem)
        return [self describeSelfConstraint];
    
    BOOL superviewRelationship = ([self.SE_firstView SE_isAncestorOfView:self.SE_secondView] || [self.SE_secondView SE_isAncestorOfView:self.SE_firstView]);
    if (superviewRelationship)
        return [self describeSuperviewBasedConstraint];
    
    return [self describeSiblingConstraint];
}

+ (void) autoAddConstraintNames: (NSArray *) constraints
{
    for (NSLayoutConstraint *constraint in constraints)
    {
        // Check for existing SE_nametag
        if (constraint.SE_nametag)
            continue;

        // Is it a standard constraint?
        BOOL isLayoutConstraint = [constraint.class isEqual:[NSLayoutConstraint class]];
        
        // If not, derive from class name
        if (!isLayoutConstraint)
        {
            NSString *name = constraint.class.description;
            if ([name hasPrefix:@"NS"])
                name = [name substringFromIndex:2];
            if ([name hasPrefix:@"UI"])
                name = [name substringFromIndex:2];
            constraint.SE_nametag = name;
            continue;
        }

        // Assign the description
        constraint.SE_nametag = constraint.constraintDescription;
    }
}
@end

#pragma mark - AutoNaming
@implementation VIEW_CLASS (AutoNaming)
// Recursively autogenerate constraint names for each view in tree
- (void) addConstraintNames
{
    [NSLayoutConstraint autoAddConstraintNames:self.constraints];
    for (VIEW_CLASS *view in self.subviews)
        [view addConstraintNames];
}

- (void) registerView: (NSMutableDictionary *) dict
{
    NSString *classDesc = self.class.description;
    if ([classDesc hasPrefix:@"NS"])
        classDesc = [classDesc substringFromIndex:2];
    if ([classDesc hasPrefix:@"UI"])
        classDesc = [classDesc substringFromIndex:2];
    
    // Skip if this instance uses a custom name
    if (self.SE_nametag && ![self.SE_nametag hasPrefix:classDesc])
            return;
    
    NSNumber *number = dict[classDesc];
    if (!number) number = @(0);
    number = @(number.integerValue + 1);
    dict[classDesc] = number;
}

// Autogenerate SE_nametags for each view
- (void) addViewNames: (NSMutableDictionary *) dict
{
    if (self.SE_nametag)
    {
        for (VIEW_CLASS *view in self.subviews)
            [view addViewNames:dict];
        return;
    }
    
    NSString *classDesc = self.class.description;
    if ([classDesc hasPrefix:@"NS"])
        classDesc = [classDesc substringFromIndex:2];
    if ([classDesc hasPrefix:@"UI"])
        classDesc = [classDesc substringFromIndex:2];
    
    [self registerView:dict];
    NSNumber *number = dict[classDesc];
    NSString *viewName = [NSString stringWithFormat:@"%@%@", classDesc, number];
    self.SE_nametag = viewName;
    
    for (VIEW_CLASS *view in self.subviews)
        [view addViewNames:dict];
}

// Entry point for generating SE_nametags
- (void) addViewNames
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Exhaustively add any items
    if (self.SE_nametag)
        [self registerView:dict];

    // Add all subviews (recursively gathered)
    for (VIEW_CLASS *view in self.SE_allSubviews)
    {
        if (view.SE_nametag)
            [view registerView:dict];
    }
    
    [self addViewNames:dict];
}
@end

#pragma mark - View  Description
@implementation VIEW_CLASS (Description)

#if TARGET_OS_IPHONE
+ (NSString *) nameForContentMode: (UIViewContentMode) mode
{
    switch (mode)
    {
        case UIViewContentModeScaleToFill:
            return @"Scale to Fill";
        case UIViewContentModeScaleAspectFit:
            return @"Scale Aspect Fit";
        case UIViewContentModeScaleAspectFill:
            return @"Scale Aspect Fill";
        case UIViewContentModeRedraw:
            return @"Redraw";
        case UIViewContentModeCenter:
            return @"Center";
        case UIViewContentModeTop:
            return @"Top";
        case UIViewContentModeBottom:
            return @"Bottom:";
        case UIViewContentModeLeft:
            return @"Left";
        case UIViewContentModeRight:
            return @"Right";
        case UIViewContentModeTopLeft:
            return @"Top Left";
        case UIViewContentModeTopRight:
            return @"Top Right";
        case UIViewContentModeBottomLeft:
            return @"Bottom Left";
        case UIViewContentModeBottomRight:
            return @"Bottom Right";
        default:
            return @"Unknown Content Mode";
    }
}
#endif

- (NSString *) superviewsDescription
{
    NSArray *superviews = self.SE_superviews;
    if (superviews.count > 2)
        superviews = [superviews subarrayWithRange:NSMakeRange(0, 2)];
    
    NSMutableString *ancestry = [NSMutableString string];
    [ancestry appendString:self.class.description];
    for (VIEW_CLASS *view in superviews)
        [ancestry appendFormat:@" : <%@>", view.SE_objectName];
    if (self.SE_superviews.count > 2)
        [ancestry appendString:@" ..."];
    
    return ancestry;
}

- (NSDictionary *) participatingViews
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[self.SE_objectName] = self;
    
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        dict[constraint.SE_firstView.SE_objectName] = constraint.SE_firstView;
        if (!constraint.secondItem)
            continue;
        dict[constraint.SE_secondView.SE_objectName] = constraint.SE_secondView;
    }
    
    return dict;
}

- (NSString *) maskDescription
{
    NSMutableString *string = [NSMutableString string];
    
#if TARGET_OS_IPHONE
    NSDictionary *dict = @{
                           @(UIViewAutoresizingFlexibleLeftMargin): @"LM",
                           @(UIViewAutoresizingFlexibleWidth): @"W",
                           @(UIViewAutoresizingFlexibleRightMargin): @"RM",
                           @(UIViewAutoresizingFlexibleTopMargin): @"TM",
                           @(UIViewAutoresizingFlexibleHeight): @"H",
                           @(UIViewAutoresizingFlexibleBottomMargin): @"BM"
                           };
#elif TARGET_OS_MAC
    NSDictionary *dict = @{
                           @(NSViewMinXMargin): @"LM",
                           @(NSViewWidthSizable): @"W",
                           @(NSViewMaxXMargin): @"RM",
                           @(NSViewMinYMargin): @"TM",
                           @(NSViewHeightSizable): @"H",
                           @(NSViewMaxYMargin): @"BM"
                           };
#endif
    
    for (NSNumber *sizing in dict.allKeys)
    {
        if ((self.autoresizingMask & (sizing.unsignedIntegerValue)) != 0)
            [string appendFormat:@"%@+", dict[sizing]];
    }
    
    if ([string hasSuffix:@"+"])
        [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
    
    return string;
}

- (void) listConstraints
{
    printf("<%s> (%d constraints)\n", self.SE_objectName.UTF8String, (int) self.constraints.count);
    int i = 1;
    for (NSLayoutConstraint *constraint in self.constraints)
        printf("%2d. @%4d: %s\n", i++, (int) constraint.priority, constraint.stringValue.UTF8String);
    printf("\n");
}

// List constraints for this view and all subviews
- (void) listAllConstraints
{
    [self listConstraints];
    for (VIEW_CLASS *subview in self.subviews)
        [subview listAllConstraints];
}

// Book examples are less exhaustive
#define BOOK_EXAMPLE    0

// Create view layout description
- (NSString *) viewLayoutDescription
{
    // Create view layout summary
    NSMutableString *description = [NSMutableString string];
    
    // Specify view address, class and superclass
    [description appendFormat:@"<%@>\n  %@ : %@", self.SE_objectName, self.class.description, self.superclass.description];
    
    // Test for Autosizing and Ambiguous Layout
    if (self.translatesAutoresizingMaskIntoConstraints)
        [description appendFormat:@" [Autoresizes]"];
    if (self.hasAmbiguousLayout)
        [description appendFormat:@" [Caution: Ambiguous Layout!]"];
    [description appendString:@"\n\n"];
    
    // Show description for autoresizing views
    if (self.translatesAutoresizingMaskIntoConstraints && (self.autoresizingMask != 0))
        [description appendFormat:  @"Mask...........%@\n", [self maskDescription]];
    
#if BOOK_EXAMPLE == 0
    // Ancestry
    [description appendFormat:@"Superviews.....%@\n", self.superviewsDescription];
#endif
    
    // Frame and content size
    [description appendFormat:@"Frame:.........%@\n", self.readableFrame];
    
#if TARGET_OS_IPHONE
    if ([self isKindOfClass:[UIScrollView class]])
    {
        [description appendFormat:@"Content size:...%@\n", SIZESTRING([(UIScrollView *)self contentSize])];
        [description appendFormat:@"Content inset:..%@\n", NSStringFromUIEdgeInsets([(UIScrollView *)self contentInset])];
    }
#endif
    
    if (!CGSizeEqualToSize(self.intrinsicContentSize, CGSizeMake(UIViewNoIntrinsicMetric , UIViewNoIntrinsicMetric)))
    {
        [description appendFormat:@"Content size...%@", SIZESTRING(self.intrinsicContentSize)];
        
#if TARGET_OS_IPHONE
        // Add content mode, but only for iOS
        if ((self.intrinsicContentSize.width > 0) ||
            (self.intrinsicContentSize.height > 0))
            [description appendFormat:@" [Content Mode: %@]", [UIView nameForContentMode:self.contentMode]];
#endif
        [description appendFormat:@"\n"];
    }

#if BOOK_EXAMPLE == 0
    // Alignment rect
    if (!CGRectEqualToRect(self.frame, [self alignmentRectForFrame:self.frame]))
        [description appendFormat:@"Align't rect...%@\n", self.readableAlignmentRect];
    
    // Edge insets
    if ((self.alignmentRectInsets.top != 0) ||
        (self.alignmentRectInsets.left != 0) ||
        (self.alignmentRectInsets.bottom != 0) ||
        (self.alignmentRectInsets.right != 0))
        [description appendFormat:@"Align Insets...%@\n", self.readableAlignmentInsets];
    
#if TARGET_OS_IPHONE
    if ([self isKindOfClass:[UILabel class]])
        [description appendFormat:@"PrefMaxWidth:..%0.2f\n", [(UILabel *)self preferredMaxLayoutWidth]];
#elif TARGET_OS_MAC
    if ([self isKindOfClass:[NSTextField class]])
        [description appendFormat:@"PrefMaxWidth:..%0.2f\n", [(NSTextField *)self preferredMaxLayoutWidth]];
#endif
#endif
    
    // Content Hugging
    [description appendFormat:@"Hugging........[H %d] [V %d]\n", (int) HUG_VALUE_H(self), (int) HUG_VALUE_V(self)];
    
    // Compression Resistance
     [description appendFormat:@"Resistance.....[H %d] [V %d]\n", (int) RESIST_VALUE_H(self), (int) RESIST_VALUE_V(self)];

    // Constraint Count
    [description appendFormat:@"Constraints....%d\n", (int) self.constraints.count];
    
#if BOOK_EXAMPLE == 0
    // Referencing views
    NSDictionary *participating = [self participatingViews];
    [description appendFormat:@"View Refs......%d\n", (int) participating.allKeys.count];
    for (NSString *string in participating.allKeys)
        [description appendFormat:@"     <%@>\n", string];
    
    // Organize constraints
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        NSString *key = constraint.SE_nametag;
        if (!key)
            key = @"Unlabeled Constraints";
        
        NSArray *array = dict[key];
        if (array)
            array = [array arrayByAddingObject:constraint];
        else
            array = @[constraint];
        dict[key] = array;
    }
    
    NSArray *sortedKeys = [dict.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    
    // Enumerate constraints
    for (NSString *key in sortedKeys)
    {
        NSArray *constraints = dict[key];
        int i = 1;
        
        [description appendFormat:@"\n\"%@\"\n", key];
        for (NSLayoutConstraint *constraint in constraints)
        {
            BOOL isLayoutConstraint = [constraint.class isEqual:[NSLayoutConstraint class]];
            
            // List each constraint
            [description appendFormat:@"%2d. ", i++];
            
            // Display priority only for layout constraints
            if (isLayoutConstraint)
                [description appendFormat:@"@%4d ", (int) constraint.priority];
            
            // Show constraint
            [description appendFormat:@"%@", constraint.stringValue];
            
            // Add non-standard classes
            if (!isLayoutConstraint)
            {
                [description appendFormat:@" (%@", constraint.class.description];
                
                // This seems to be nonsense -- Refer to the content hugging
                // or compression resistance priority properties instead
                // [description appendFormat:@", %d", (int) constraint.priority];
                
                [description appendString:@")"];
            }
            [description appendFormat:@"\n"];
            
            // If format is available, show that
            if (constraint.visualFormat)
                [description appendFormat:@"     Format: %@\n", constraint.visualFormat];
            
            // Show description ???
            [description appendFormat:    @"     Descr: %@\n", constraint.SE_consoleDescription];
        }
    }
    
    // Referencing Constraints
    [description appendFormat:@"\n"];
    
    NSArray *references = self.SE_referencingConstraints;
    if (references.count)
        [description appendString:@"Other Constraint References to View\n"];
    
    int i = 1;
    for (NSLayoutConstraint *constraint in references)
    {
        // List each likely owner (guaranteed if install)
        VIEW_CLASS *nca = [constraint.SE_firstView SE_nearestCommonAncestorToView:constraint.SE_secondView];
        if (!nca) continue;

        // List each constraint
        [description appendFormat:@"%2d. ", i++];
        
        // Owner
        [description appendFormat:@"<%@> : ", nca.SE_objectName];

        // Priority
        [description appendFormat:@"@%4d ", (int) constraint.priority];
        
        // Show constraint
        [description appendFormat:@"%@", constraint.stringValue];
        
        // Show SE_nametag
        if (constraint.SE_nametag)
            [description appendFormat:@" (%@)", constraint.SE_nametag];
        
        [description appendString:@"\n"];
    }
    
#else
    
    int i = 1;
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        BOOL isLayoutConstraint = [constraint.class isEqual:[NSLayoutConstraint class]];
        
        // List each constraint
        [description appendFormat:@"%2d. ", i++];
        
        // Display priority only for layout constraints
        if (isLayoutConstraint)
            [description appendFormat:@"@%4d ", (int) constraint.priority];
        
        // Show constraint
        [description appendFormat:@"%@", constraint.stringValue];
        
        // Add non-standard classes
        if (!isLayoutConstraint)
            [description appendFormat:@" (%@)", constraint.class.description];

        [description appendFormat:@"\n"];
    }
#endif
    
    return description;
}

- (NSArray *) skippableClasses
{
#if TARGET_OS_IPHONE
    return @[
             [UIButton class], [UILabel class], [UISwitch class],
             [UIStepper class], [UITextField class], // [UIScrollView class],
             [UIActivityIndicatorView class],
             [UIAlertView class], [UIPickerView class],
             [UIProgressView class], [UIPageControl class],
             [UIToolbar class], [UINavigationBar class],
             [UISearchBar class], [UITabBar class],
             [UISlider class], [UIImageView class],
             ];
#elif TARGET_OS_MAC
    return @[
             ];
#endif
}

- (void) showViewReport: (BOOL) descend
{
    printf("\nVIEW REPORT %s\n", self.viewLayoutDescription.UTF8String);
    
    if (!descend)
        return;
    
    for (Class class in [self skippableClasses])
        if ([self isKindOfClass:class])
            return;
    
    for (VIEW_CLASS *view in self.subviews)
        [view showViewReport: descend];
}

- (void) generateViewReportForUser: (NSString *) userName addNames: (BOOL) addNames
{
    NSString *destination = [NSString stringWithFormat:@"/Users/%@/Desktop/AutoLayoutViewReport.txt", userName];
    
    if (addNames)
    {
        self.SE_nametag = @"Main View";
        [self addViewNames];
        [self addConstraintNames];
    }

    freopen(destination.UTF8String, "w+", stdout);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterLongStyle;

    printf("Auto Layout View Report\n  %s\n", [formatter stringFromDate:[NSDate date]].description.UTF8String);
    [self showViewReport:YES];
    fclose(stdout);
    NSLog(@"Written to %@", destination);
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#if OVERRIDE_SAFETY
// Swap ignored to error if you need warning

// DEBUG ONLY. Do not ship with this code
- (void) testAmbiguity
{
    NSLog(@"<%@:0x%0x>: %@", self.class.description, (int)self, self.hasAmbiguousLayout ? @"Ambiguous" : @"Unambiguous");
    
    for (VIEW_CLASS *view in self.subviews)
        [view testAmbiguity];
}


// DEBUG ONLY. For somewhat obvious reasons, do not ship with this code
- (NSString *) trace
{
    return [self.window performSelector:@selector(_autolayoutTrace)];
}
#endif
#pragma GCC diagnostic pop
@end


// iOS only for now
#pragma mark - Visual Layout Hints
#if TARGET_OS_IPHONE
@implementation UIView (VisualLayoutHint)

CADisplayLink *displayLink = nil;

// Return either black or white based on a view's background color
// It's not a perfect solution
-(UIColor *) contrastColor
{
    UIColor *color = self.backgroundColor;
    if (!color || [color isEqual:[UIColor clearColor]])
        return [self.superview contrastColor];

    if (CGColorSpaceGetNumberOfComponents(CGColorGetColorSpace(color.CGColor)) == 3)
    {
        CGFloat r, g, b, a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        if (a < 0.3f) return [self.superview contrastColor];
        CGFloat luminance = r * 0.2126f + g * 0.7152f + b * 0.0722f;
        return (luminance > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
    }
    
    CGFloat w, a;
    [color getWhite:&w alpha:&a];
    if (a < 0.3f) return [self.superview contrastColor];
    return (w > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
}

// Attachment points for constraints
CGPoint GetLayoutPoint(NSLayoutConstraint *constraint, UIView *view, UIView *callingView, NSLayoutAttribute attribute)
{
    BOOL isSuper = [view isEqual:callingView];
    CGRect viewFrame = view.frame;
    if (isSuper)
        viewFrame = view.bounds;
    UIView *otherView = nil;
    if (![view isEqual:constraint.firstView])
        otherView = constraint.firstView;
    if (constraint.secondView && ![view isEqual:constraint.secondView])
        otherView = constraint.secondView;
    
    switch (attribute)
    {
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading: // sorry
        case NSLayoutAttributeWidth:
        {
            if (isSuper)
                return CGPointMake(CGRectGetMinX(viewFrame), CGRectGetMidY(otherView.frame));
            return CGPointMake(CGRectGetMinX(viewFrame), CGRectGetMidY(viewFrame));
        }
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing: // also sorry
        {
            if (isSuper)
                return CGPointMake(CGRectGetMinX(viewFrame), CGRectGetMidY(otherView.frame));
            return CGPointMake(CGRectGetMaxX(viewFrame), CGRectGetMidY(viewFrame));
        }
        case NSLayoutAttributeHeight:
        case NSLayoutAttributeTop:
        {
            if (isSuper)
                return CGPointMake(CGRectGetMidX(otherView.frame), CGRectGetMinY(viewFrame));
            return CGPointMake(CGRectGetMidX(viewFrame), CGRectGetMinY(viewFrame));
        }
        case NSLayoutAttributeBaseline:
        case NSLayoutAttributeBottom:
        {
            if (isSuper)
                return CGPointMake(CGRectGetMidX(otherView.frame), CGRectGetMaxY(viewFrame));
            return CGPointMake(CGRectGetMidX(viewFrame), CGRectGetMaxY(viewFrame));
        }
        case NSLayoutAttributeCenterX:
        case NSLayoutAttributeCenterY:
        case NSLayoutAttributeNotAnAttribute:
        default:
            return CGPointMake(CGRectGetMidX(viewFrame), CGRectGetMidY(viewFrame));
    }
}

- (CGPoint) firstPoint: (NSLayoutConstraint *) constraint
{
    return GetLayoutPoint(constraint, constraint.firstView, self, constraint.firstAttribute);
}

- (CGPoint) secondPoint: (NSLayoutConstraint *) constraint
{
    UIView *v2 = constraint.secondView ? : constraint.firstView;
    return GetLayoutPoint(constraint, v2, self, constraint.secondAttribute);
}

- (void) drawConstraintLinesOnPrimaryView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat dashes[] = {2, 1};
    BOOL drawHeavy = YES; // Book figures require heavier drawing

    for (NSLayoutConstraint *c in self.allConstraints)
    {
        CGPoint p1 = [self firstPoint:c];
        CGPoint p2 = [self secondPoint:c];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:p1];
        CGPoint pmid = CGPointMake(p1.x, p2.y);
        [path addLineToPoint:pmid];
        [path addLineToPoint:p2];
                
        CGRect r1 = CGRectInset((CGRect){.origin = p1}, -4, -4);
        UIBezierPath *circle1 = [UIBezierPath bezierPathWithOvalInRect:r1];
        [path appendPath:circle1];
        
        CGRect r2 = CGRectInset((CGRect){.origin = p2}, -4, -4);
        UIBezierPath *circle2 = [UIBezierPath bezierPathWithOvalInRect:r2];
        [path appendPath:circle2];

        [path setLineDash:dashes count:2 phase:0];
        path.lineWidth = drawHeavy ? 2 : 1;
        
        CGContextSaveGState(context);
        if (!drawHeavy) [[UIColor grayColor] set];
        [path stroke];
        
        CGContextRestoreGState(context);
    }
}

NSString *_AffineTransformDegreesString(CGAffineTransform t)
{
    CGFloat r = atan2f(t.b, t.a);
    CGFloat d = r * 180.0f / M_PI;
    return [NSString stringWithFormat:@"%0.1f°", d];
}

// Overlay image for debugging
- (UIImage *) debugOverlayImage
{
    NSMutableString *description = [NSMutableString string];
    
    // SE_nametag or class
    if (self.SE_nametag)
        [description appendFormat:@"%@\n", self.SE_nametag];
    else
        [description appendFormat:@"%@\n", self.class.description];
    
    if (!CGAffineTransformIsIdentity(self.transform))
        [description appendFormat:@"%@\n", _AffineTransformDegreesString(self.transform)];
    
    // Check for autosizing
    if (self.translatesAutoresizingMaskIntoConstraints)
        [description appendFormat:@"[Autosizes%@]\n", [self maskDescription]];
    
    // Check for ambiguity
    if (self.hasAmbiguousLayout)
        [description appendFormat:@"Ambiguous\n"];
    
    // Frame
    [description appendFormat:@"%@", self.readableFrame];
    
    // Build Attributed String
    NSRange fullRange = NSMakeRange(0, description.length);
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:description];
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Futura" size:5] range:fullRange];
    [string addAttribute:NSForegroundColorAttributeName value:self.contrastColor range:fullRange];

    // Draw the information and return the image
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [string drawInRect:CGRectInset(self.bounds, 4, 4)];
    
    if ([self.SE_nametag isEqualToString:@"Main View"])
        [self drawConstraintLinesOnPrimaryView];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CALayer *) hintLayer
{
    CALayer *sublayer = [self.layer valueForKeyPath:@"VisualLayoutHint"];
    if (!sublayer)
    {
        sublayer = [CALayer layer];
        [self.layer insertSublayer:sublayer atIndex:0];
        sublayer.frame = self.bounds;
        sublayer.contents = (id) [self debugOverlayImage].CGImage;
        sublayer.borderColor = [UIColor blackColor].CGColor;
        [self.layer setValue:sublayer forKey:@"VisualLayoutHint"];
    }
    return sublayer;
}

- (void) deployVisualLayoutHints
{
    CALayer *hintLayer = self.hintLayer;
    hintLayer.borderWidth = 1;
    
    for (Class class in [self skippableClasses])
        if ([self isKindOfClass:class])
            return;
    
    for (UIView *view in self.subviews)
        [view deployVisualLayoutHints];
}

- (void) hideVisualLayoutHints
{
    CALayer *hintLayer = self.hintLayer;
    [hintLayer removeFromSuperlayer];
    [self.layer setValue:nil forKey:@"VisualLayoutHint"];

    for (UIView *view in self.subviews)
        [view hideVisualLayoutHints];
}

- (void) updateVisualLayoutHints
{
    CALayer *sublayer = [self.layer valueForKeyPath:@"VisualLayoutHint"];
    if (!sublayer)
        return;
    [self hideVisualLayoutHints];
    [self deployVisualLayoutHints];
}

- (void) toggleVisualLayoutHints
{
    if (displayLink)
    {
        [displayLink invalidate];
        displayLink = nil;
        [self hideVisualLayoutHints];
        return;
    }
    
    [self deployVisualLayoutHints];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateVisualLayoutHints)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
@end
#endif
