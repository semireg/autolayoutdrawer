/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#if TARGET_OS_IPHONE
@import Foundation;
#elif TARGET_OS_MAC
#import <Foundation/Foundation.h>
#endif

// If you use in production code, please make sure to add
// namespace indicators to class category methods

@interface NSObject (DebuggingExtensions)
@property (nonatomic, readonly) NSString *SE_objectIdentifier;
@property (nonatomic, readonly) NSString *SE_objectName;
@property (nonatomic, readonly) NSString *SE_consoleDescription;
@end

