//
//  AppDelegate.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 04.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "AppDelegate.h"
#import "DocumentController.h"
#import "Document.h"

@implementation AppDelegate

- (id)init
{
    NSLog(@"AppDelegate:init");
    if (self = [super init])
    {
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
            andSelector: @selector(handleGetURLEvent:withReplyEvent:)
            forEventClass:kInternetEventClass andEventID:kAEGetURL];

    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [[[DocumentController alloc] init] release];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    if ([event eventID] == kAEGetURL)
    {
        NSAppleEventDescriptor *directObject = [event paramDescriptorForKeyword: keyDirectObject];
        NSString *urlString = nil;
        if ([directObject descriptorType] == typeAEList)
        {
            for (NSInteger i = 1; i <= [directObject numberOfItems]; i++)
                if ((urlString = [[directObject descriptorAtIndex: i] stringValue]))
                    break;
        }
        else
            urlString = [directObject stringValue];
        if (urlString)
        {
           [[NSDocumentController sharedDocumentController]
                openDocumentWithContentsOfURL:[NSURL URLWithString:urlString] display:YES completionHandler:nil];
        }
    }
}

@end
