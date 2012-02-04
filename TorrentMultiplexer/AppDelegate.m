//
//  AppDelegate.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 04.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize buttonStartTorrent = _buttonStartTorrent;
@synthesize comboSeedKind = _comboSeedKind;
@synthesize matrixTargetKind = _matrixTargetKind;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[self comboSeedKind] addItemWithObjectValue:@"private"];
    [[self comboSeedKind] addItemWithObjectValue:@"moderate"];    
    [[self comboSeedKind] addItemWithObjectValue:@"greedy"];
    [[self comboSeedKind] selectItemAtIndex:0];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (IBAction)performStartTorrent:(id)sender {
    NSLog(@"TODO");
    NSString* selection = [[self comboSeedKind] objectValueOfSelectedItem];
    NSLog(@"Selected: %@", selection); 
}
@end
