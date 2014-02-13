/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#if TARGET_OS_IPHONE
@import Foundation;
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

#import "ConstraintUtilities+Install.h"
#import "NametagUtilities.h"

#pragma mark - Testing Constraint Elements

#define IS_SIZE_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight)] containsObject:@(ATTRIBUTE)]
#define IS_CENTER_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY)] containsObject:@(ATTRIBUTE)]
#define IS_EDGE_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]
#define IS_LOCATION_ATTRIBUTE(ATTRIBUTE) (IS_EDGE_ATTRIBUTE(ATTRIBUTE) || IS_CENTER_ATTRIBUTE(ATTRIBUTE))

#define IS_HORIZONTAL_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeCenterX), @(NSLayoutAttributeWidth)] containsObject:@(ATTRIBUTE)]
#define IS_VERTICAL_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeHeight), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]

#define IS_HORIZONTAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllLeft), @(NSLayoutFormatAlignAllRight), @(NSLayoutFormatAlignAllLeading), @(NSLayoutFormatAlignAllTrailing), @(NSLayoutFormatAlignAllCenterX), ] containsObject:@(ALIGNMENT)]
#define IS_VERTICAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllTop), @(NSLayoutFormatAlignAllBottom), @(NSLayoutFormatAlignAllCenterY), @(NSLayoutFormatAlignAllBaseline), ] containsObject:@(ALIGNMENT)]

// If you use in production code, please make sure to add
// namespace indicators to class category methods

/*
 NAMED CONSTRAINTS
 Naming makes constraints more self-documenting, enabling you to retrieve 
 them by tag. These methods also add an option to find constraints that
 specifically match a certain view.
 */

#pragma mark - Named Constraint Support
@interface VIEW_CLASS (NamedConstraintSupport)

// Single
- (NSLayoutConstraint *) SE_constraintNamed: (NSString *) aName;
- (NSLayoutConstraint *) SE_constraintNamed: (NSString *) aName matchingView: (VIEW_CLASS *) view;

// Multiple
- (NSArray *) SE_constraintsNamed: (NSString *) aName;
- (NSArray *) SE_constraintsNamed: (NSString *) aName matchingView: (VIEW_CLASS *) view;
@end

/*
 MATCHING CONSTRAINTS
 Test if one constraint is essentially the same as another.
 This is particularly important when you generate new constraints 
 and want to remove their equivalents from another view.
 */

#pragma mark - Constraint Matching
@interface NSLayoutConstraint (ConstraintMatching)
- (BOOL) SE_isEqualToLayoutConstraint: (NSLayoutConstraint *) constraint;
- (BOOL) SE_isEqualToLayoutConstraintConsideringPriority: (NSLayoutConstraint *) constraint;
- (BOOL) SE_refersToView: (VIEW_CLASS *) aView;
@property (nonatomic, readonly) BOOL SE_isHorizontal;
@end

#pragma mark - Managing Matching Constraints
@interface VIEW_CLASS (ConstraintMatching)
@property (nonatomic, readonly) NSArray *SE_allConstraints;
@property (nonatomic, readonly) NSArray *SE_referencingConstraintsInSuperviews;
@property (nonatomic, readonly) NSArray *SE_referencingConstraints;

// Retrieving constraints
- (NSLayoutConstraint *) SE_constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (NSArray *) SE_constraintsMatchingConstraints: (NSArray *) constraints;

// Constraints referencing a given view
- (NSArray *) SE_constraintsReferencingView: (VIEW_CLASS *) view;
- (NSArray *) SE_constraintsReferencingView: (VIEW_CLASS *) firstView andView: (VIEW_CLASS *) secondView;
- (NSArray *) SE_IBSourcedConstraintsReferencingView: (VIEW_CLASS *) theView;

// Removing matching constraints
- (void) SE_removeMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (void) SE_removeMatchingConstraints: (NSArray *) anArray;

// Removing named constraints
- (void) SE_removeConstraintsNamed: (NSString *) name;
- (void) SE_removeConstraintsNamed: (NSString *) name matchingView: (VIEW_CLASS *) view;

// Kicking the ball around a bit here
@property (nonatomic, readonly) NSArray *SE_widthConstraints;
@property (nonatomic, readonly) NSArray *SE_heightConstraints;

@end