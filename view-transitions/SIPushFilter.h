//
//  CIFilterPush.h
//  view-transitions
//
//  Created by Joe Rickerby on 25/05/2012.
//  Copyright (c) 2012 Square [ i ] International Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

extern CIVector *SIPushFilterDirectionFromLeft;
extern CIVector *SIPushFilterDirectionFromRight;
extern CIVector *SIPushFilterDirectionFromTop;
extern CIVector *SIPushFilterDirectionFromBottom;

@interface SIPushFilter : CIFilter

@property (retain) CIImage *inputImage;
@property (retain) CIImage *inputTargetImage;
@property (retain) NSNumber *inputTime;
@property (retain) CIVector *direction;

@end
