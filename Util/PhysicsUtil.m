//
//  PhysicsUtil.m
//  TapMania
//
//  Created by Alex Kremer on 9.1.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "PhysicsUtil.h"

#define PI 3.14159265358979323846
#define DOUBLE_PI 6.28318530717958647692	// Precomputed 2*PI

@implementation Vector

@synthesize x,y;	
- (id) init {
	self = [super init];
	if(!self)
		return nil;

	x = 0.0f;
	y = 0.0f;

	return self;
}

- (id) initWithX:(float)lx andY:(float)ly {
	self = [super init];
	if(!self)
		return nil;

	x = lx;
	y = ly;

	return self;
}

- (float) norm {
	return sqrt(x*x + y*y);
}

- (float) normSquared {
	return (x*x + y*y);
}

+ (float) norm:(Vector*)v0 {
	return sqrt(v0.x*v0.x + v0.y*v0.y);
}

+ (float) normSquared:(Vector*)v0 {
	return (v0.x*v0.x + v0.y*v0.y);
}

+ (Vector*) normalize:(Vector*)v0 withTolerance:(float)tolerance {
	Vector* result = [[Vector alloc] init];

	float len = [Vector norm:v0];

	if(len >= tolerance){
		result.x = v0.x/len;
		result.y = v0.y/len;
	}

	return result;
}


+ (Vector*) sum:(Vector*)v0 and:(Vector*)v1 {
	return [[Vector alloc] initWithX:v0.x+v1.x andY:v0.y+v1.y];
}

+ (Vector*) sub:(Vector*)v0 and:(Vector*)v1 {
	return [[Vector alloc] initWithX:v0.x-v1.x andY:v0.y-v1.y];
}

+ (float) dot:(Vector*)v0 and:(Vector*)v1 {
	return (v0.x*v1.x + v0.y*v1.y);
}
@end

@implementation Triangle

@synthesize v0,v1,v2;	

- (id) initWithV0:(Vector*)lv0 V1:(Vector*)lv1 andV2:(Vector*)lv2 {
	self = [super init];
	if(!self)
		return nil;

	v0 = lv0;
	v1 = lv1;
	v2 = lv2;

	return self;

}

- (void) dealloc {
	[v0 release];
	[v1 release];
	[v2 release];

	[super dealloc];
}

-(BOOL) containsPoint:(CGPoint)point {
	double dAngle;
	double epsilon = 0.01f;
	
	Vector* vPoint = [[Vector alloc] initWithX:point.x andY:point.y];
	Vector* vec0 = [Vector normalize:[Vector sub:vPoint and:v0] withTolerance:0.01];
	Vector* vec1 = [Vector normalize:[Vector sub:vPoint and:v1] withTolerance:0.01];
	Vector* vec2 = [Vector normalize:[Vector sub:vPoint and:v2] withTolerance:0.01];
	
	dAngle = acos( [Vector dot:vec0 and:vec1] ) + 
			 acos( [Vector dot:vec1 and:vec2] ) + 
			 acos( [Vector dot:vec2 and:vec0] );
												
	if( fabs( dAngle - DOUBLE_PI ) < epsilon )
		return true;
	else
		return false;
}

@end

@implementation PhysicsUtil
@end
