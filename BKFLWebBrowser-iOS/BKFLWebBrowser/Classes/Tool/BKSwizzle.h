//
//  FoSwizzling.h
//
//  Created by Fover0 on 15/8/14.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

void LJ_SwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector);
