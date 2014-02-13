/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import "NSObject-Nametag.h"

#if TARGET_OS_IPHONE
@import ObjectiveC;
#elif TARGET_OS_MAC
#import <objc/objc-runtime.h>
#endif

@implementation NSObject (Nametags)
- (id) SE_nametag
{
    return objc_getAssociatedObject(self, @selector(SE_nametag));
}

- (void) setSE_nametag:(NSString *)nametag
{
    objc_setAssociatedObject(self, @selector(SE_nametag), nametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end