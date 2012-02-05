//
//  WindowController.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 06.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "WindowController.h"

@implementation WindowController

@synthesize buttonStartTorrent = _buttonStartTorrent;
@synthesize comboSeedKind = _comboSeedKind;
@synthesize matrixTarget = _matrixTarget;

- (void)awakeFromNib
{
    NSLog(@"Awaked"); 
    [[self comboSeedKind] selectItemAtIndex:0];
    enum TorrentTarget selection = ttQuark;
    [[self matrixTarget] selectCellAtRow:selection column:0];
    [[self comboSeedKind] setEnabled:(selection == ttQuark)];
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)selectTargetKind:(id)sender {
    NSInteger targetSelection = [[self matrixTarget] selectedRow];
    NSAssert(targetSelection != -1, @"No radio selection");
    [[self comboSeedKind] setEnabled:((enum TorrentTarget)targetSelection == ttQuark)];
}

- (IBAction)performStartTorrent:(id)sender {
    NSLog(@"TODO");
    NSString* selection = [[self comboSeedKind] objectValueOfSelectedItem];
    NSLog(@"Selected: %@", selection); 
}

@end
