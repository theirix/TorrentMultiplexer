//
//  AppDelegate.h
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 04.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *buttonStartTorrent;
@property (assign) IBOutlet NSComboBox *comboSeedKind;
@property (assign) IBOutlet NSMatrix *matrixTargetKind;

- (IBAction)performStartTorrent:(id)sender;

@end
