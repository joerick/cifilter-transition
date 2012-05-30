//
//  CIFilterPush.m
//  view-transitions
//
//  Created by Joe Rickerby on 25/05/2012.
//  Copyright (c) 2012 Square [ i ] International Ltd. All rights reserved.
//

#import "SIPushFilter.h"

CIVector *SIPushFilterDirectionFromLeft = nil;
CIVector *SIPushFilterDirectionFromRight = nil;
CIVector *SIPushFilterDirectionFromTop = nil;
CIVector *SIPushFilterDirectionFromBottom = nil;

@implementation SIPushFilter

static CIKernel *filterKernel = nil;

@synthesize inputImage;
@synthesize inputTargetImage;
@synthesize inputTime;
@synthesize direction;

+ (void)load
{
    
    SIPushFilterDirectionFromLeft = [[CIVector alloc] initWithX: -1.0 Y: 0.0];
    SIPushFilterDirectionFromRight = [[CIVector alloc] initWithX: 1.0 Y: 0.0];
    SIPushFilterDirectionFromTop = [[CIVector alloc] initWithX: 0.0 Y: 1.0];
    SIPushFilterDirectionFromBottom = [[CIVector alloc] initWithX: 0.0 Y: -1.0];
}

+ (void)initialize
{
	[CIFilter registerFilterName: @"SIPushFilter"
                     constructor: (id<CIFilterConstructor>)self
                 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Push", kCIAttributeFilterDisplayName,
                                   [NSArray arrayWithObjects: kCICategoryTransition, nil], kCIAttributeFilterCategories,
                                   nil]];
}

+ (CIFilter *)filterWithName:(NSString *)name
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if(!filterKernel)
	{
		NSBundle *bundle = [NSBundle bundleForClass: [self class]];
		NSString *code = [NSString stringWithContentsOfFile: [bundle pathForResource: @"push"
                                                                              ofType: @"cikernel"] 
                                                   encoding: NSUTF8StringEncoding
                                                      error: nil];
        NSArray *kernels = [CIKernel kernelsWithString: code];
		filterKernel = [[kernels objectAtIndex: 0] retain];
	}
    
	self = [super init];
    
	if (self)
    {
		inputTime = [[NSNumber numberWithDouble: 0.5] retain];
        direction = [SIPushFilterDirectionFromLeft retain];
    }
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SIPushFilter *result = [super copyWithZone: zone];
    
    result.direction = self.direction;
    
    return result;
}

- (void)dealloc
{
	[inputImage release];
    [inputTargetImage release];
	[inputTime release];
    
	[super dealloc];
}

- (NSDictionary *)customAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithDouble: 0.0], kCIAttributeMin,
             [NSNumber numberWithDouble: 1.0], kCIAttributeMax,
             [NSNumber numberWithDouble: 0.0], kCIAttributeSliderMin,
             [NSNumber numberWithDouble: 1.0], kCIAttributeSliderMax,
             [NSNumber numberWithDouble: 0.5], kCIAttributeDefault,
             [NSNumber numberWithDouble: 0.0], kCIAttributeIdentity,
             kCIAttributeTypeScalar, kCIAttributeType,
             nil], kCIInputTimeKey,
            
            [NSDictionary dictionaryWithObjectsAndKeys:
             kCIAttributeTypeOffset, kCIAttributeType,
             nil], @"direction",
            nil];
}

- (CIImage *)outputImage
{
	CISampler *inputSource = [CISampler samplerWithImage: inputImage];
	CISampler *inputTarget = [CISampler samplerWithImage: inputTargetImage];
    
	return [self apply: 
            filterKernel, 
            inputSource, 
            inputTarget, 
            inputTime, 
            self.direction,
            kCIApplyOptionDefinition, [inputSource definition], 
            nil];
}
@end
