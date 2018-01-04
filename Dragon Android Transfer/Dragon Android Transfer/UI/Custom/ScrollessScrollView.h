//
//  ScrollessScrollView.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScrollessScrollView : NSScrollView
- (id)initWithFrame:(NSRect)frameRect; // in case you generate the scroll view manually
- (void)awakeFromNib; // in case you generate the scroll view via IB
- (void)hideScrollers; // programmatically hide the scrollers, so it works all the time
- (void)scrollWheel:(NSEvent *)theEvent; // disable scrolling
@end
