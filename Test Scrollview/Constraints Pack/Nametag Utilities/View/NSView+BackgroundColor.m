/*
 
 Erica Sadun, http://ericasadun.com
 NSView BG Color Utilities
 
 */

#import "NSView+BackgroundColor.h"

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
@implementation NSView (OSXBGColorExtension)
- (NSColor *)SE_backgroundColor
{
    CGColorRef colorRef = self.layer.backgroundColor;
    NSColor *theColor = [NSColor colorWithCGColor:colorRef];
    return theColor;
}

-(void) setSE_backgroundColor:(NSColor *)backgroundColor
{
    [self setWantsLayer:YES];
    self.layer.backgroundColor = backgroundColor.CGColor;
}
@end
#endif
