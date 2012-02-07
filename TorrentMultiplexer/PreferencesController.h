//
//  PreferencesController.h
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 07.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController
{    
    NSMutableArray *torrentHandlers;
    NSMutableArray *magnetHandlers;   
};

@property (assign) IBOutlet NSComboBox *comboTorrentsApp;
@property (assign) IBOutlet NSComboBox *comboMagnetApp;
@property (assign) IBOutlet NSTextField *editQuarkFormat;
@property (assign) IBOutlet NSTextField *editAtomFormat;
@property (assign) IBOutlet NSTextField *labelDefaultTorrentApp;
@property (assign) IBOutlet NSTextField *labelDefaultMagnetApp;

- (IBAction)performSetDefaultTorrent:(id)sender;
- (IBAction)performSetDefaultMagnet:(id)sender;

@end
