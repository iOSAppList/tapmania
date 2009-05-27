//
//  TMUserConfig.m
//  TapMania
//
//  Created by Alex Kremer on 13.05.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMUserConfig.h"

@implementation TMUserConfig

- (id) init {
	self = [super init];
	if(!self)
		return nil;
		
	m_pConfigDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"default", @"theme", @"default", @"noteskin", 
						[NSNumber numberWithFloat:0.8f], @"sound", nil];
	
	return self;
}

- (id) initWithContentsOfFile:(NSString*)configPath {
	self = [super init];
	if(!self)
		return nil;
	
	m_pConfigDict = [[NSMutableDictionary alloc] initWithContentsOfFile:configPath];
	
	return self;	
}

- (int) check {
	int errCount = 0;
	
	if(! [m_pConfigDict valueForKey:@"theme"]) {
		[m_pConfigDict setObject:@"default" forKey:@"theme"];
		++errCount;
	}
	
	if(! [m_pConfigDict valueForKey:@"noteskin"]) {
		[m_pConfigDict setObject:@"default" forKey:@"noteskin"];
		++errCount;
	}
	
	if(! [m_pConfigDict valueForKey:@"sound"]) {
		[m_pConfigDict setObject:[NSNumber numberWithFloat:0.8f] forKey:@"sound"];
		++errCount;
	}
	
	return errCount;
}

- (void) forwardInvocation:(NSInvocation *)invocation {
    SEL aSelector = [invocation selector];
	
    if ([m_pConfigDict respondsToSelector:aSelector]) {		
        [invocation invokeWithTarget:m_pConfigDict];
	} else {
        [self doesNotRecognizeSelector:aSelector];
	}
}

- (BOOL) respondsToSelector:(SEL) aSelector {
	if([super respondsToSelector:aSelector]) {
		return YES;
	}
	
	if([m_pConfigDict respondsToSelector:aSelector]) {
		return YES;
	}
	
	return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	NSMethodSignature* sig = [super methodSignatureForSelector:aSelector];
	
	if(!sig) {
		sig = [m_pConfigDict methodSignatureForSelector:aSelector];
	}
	
	return sig;
}

- (void)setObject:(id)obj forKey:(id)key {
	[m_pConfigDict setObject:obj forKey:key];
}

- (NSObject*)valueForKey:(NSString*)key {
	return [m_pConfigDict valueForKey:key];
}

@end