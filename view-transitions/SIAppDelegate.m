//
//  SIAppDelegate.m
//  view-transitions
//
//  Created by Michael Leach on 23/05/2012.
//  Copyright (c) 2012 Square [ i ] International Ltd. All rights reserved.
//

#import "SIAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SIPushFilter.h"

@interface SIAppDelegate ()
{
    int selectedIndex;
    NSMutableArray *subViews;
    NSView *currentView;
}

@end

static const int numItems = 10;

#define RAND_COLOR ((double)(rand()%100) / 100.0)

@implementation SIAppDelegate

@synthesize window = _window;
@synthesize view = _view;

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        subViews = [[NSMutableArray alloc] init];
        selectedIndex = 0;
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (numItems <= 0)
    {
        return;
    }
    
    self.window.backgroundColor = [NSColor blackColor];
    
    for (int i = 0; i < numItems; i++)
    {
        NSView *newView = [[NSView alloc] init];
        [newView setWantsLayer: YES];
        
        newView.frame = self.view.bounds;
        
        CALayer *newLayer = [CALayer layer];
        newView.layer = newLayer;
        
        newLayer.backgroundColor = CGColorCreateGenericRGB(0.2, RAND_COLOR, RAND_COLOR, 1.0);
        
        CIFilter *filter = [CIFilter filterWithName: @"CICheckerboardGenerator"];
        
        [filter setDefaults];
        
        [filter setValue: [CIColor colorWithRed:0 green:RAND_COLOR blue:RAND_COLOR alpha:1]
                  forKey: @"inputColor0"];
        [filter setValue: [CIColor colorWithRed:0 green:RAND_COLOR blue:RAND_COLOR alpha:1]
                  forKey: @"inputColor1"];
        
        newLayer.filters = [NSArray arrayWithObject: filter];
        
        newLayer.frame = newView.bounds;
        
        [subViews addObject: newView];
    }
    
    currentView = [subViews objectAtIndex: 0];
    
    [self.view addSubview: currentView];
    
    currentView.frame = self.view.bounds;
    
    [NSTimer scheduledTimerWithTimeInterval: 0.05
                                     target: self
                                   selector: @selector(keyObserveTimer)
                                   userInfo: nil
                                    repeats: YES];
    
}

- (void)selectIndex:(int)index  direction:(int)direction
{
    NSView *newView = ((NSView *)[subViews objectAtIndex: index]);
    NSView *oldView = [self.view.subviews lastObject];
    
    CATransition *transition = [[[CATransition alloc] init] autorelease];

    CIFilter *filter = [CIFilter filterWithName: @"SIPushFilter" keysAndValues: 
                        @"direction", (direction == 1 ? SIPushFilterDirectionFromLeft : SIPushFilterDirectionFromRight),
                        nil];
    transition.filter = filter;
    transition.duration = 0.7;
    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.view.animator setAnimations:
     [NSDictionary dictionaryWithObject: transition
                                 forKey: @"subviews"]];
    
    [self.view.animator replaceSubview: oldView with: newView];
}

- (void)keyObserveTimer 
{
    static NSEvent *lastEvent = nil;
    
    if (lastEvent != [NSApp currentEvent])
    {
        lastEvent = [NSApp currentEvent];
        
        if ([lastEvent type] == NSKeyDown)
        {
            NSString *keyPress = [lastEvent charactersIgnoringModifiers];
            
            if ([keyPress isEqualToString: @"a"])
            {
                if(selectedIndex > 0)
                {
                    selectedIndex--;
                    [self selectIndex: selectedIndex direction: 1];
                }
            }
            else if ([keyPress isEqualToString: @"d"])
            {
                if (selectedIndex < numItems - 1)
                {
                    selectedIndex++;
                    [self selectIndex: selectedIndex direction: -1];
                }
            }
        }
    }
}

@end
