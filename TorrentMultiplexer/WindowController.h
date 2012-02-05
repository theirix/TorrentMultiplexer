//
//  WindowController.h
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 06.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WindowController : NSWindowController

enum TorrentTarget {
    ttQuark = 0,
    ttAtom,
    ttLocalFile,
    ttLocalMagnet,
    ttSaveToFile   
};

@property (assign) IBOutlet NSButton *buttonStartTorrent;
@property (assign) IBOutlet NSComboBox *comboSeedKind;
@property (assign) IBOutlet NSMatrix *matrixTarget;

- (IBAction)selectTargetKind:(id)sender;
- (IBAction)performStartTorrent:(id)sender;

@end
