//
//  WindowController.h
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 06.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WindowController : NSWindowController
{
    NSDictionary *dictTorrentType;
    NSDictionary *dictImageName;    
    
    NSMutableArray *torrentHandlers;
    NSMutableArray *magnetHandlers;   
}

typedef enum {
    ttQuark = 0,
    ttAtom,
    ttLocalFile,
    ttLocalMagnet,
    ttSaveToFile   
} TorrentTarget;

@property (assign) IBOutlet NSButton *buttonStartTorrent;
@property (assign) IBOutlet NSComboBox *comboSeedKind;
@property (assign) IBOutlet NSMatrix *matrixTarget;
@property (assign) IBOutlet NSTextField *labelFileType;
@property (assign) IBOutlet NSTextField *labelTorrentName;
@property (assign) IBOutlet NSImageView *imageViewIcon;
@property (assign) IBOutlet NSComboBox *comboLocalTorrentApp;
@property (assign) IBOutlet NSComboBox *comboLocalMagnetApp;

- (IBAction)selectTargetKind:(id)sender;
- (IBAction)performStartTorrent:(id)sender;

- (IBAction)performDefaultTorrentHandler:(id)sender;
- (IBAction)performDefaultMagnetHandler:(id)sender;

- (void)copyTorrentToServer:(TorrentTarget)seedKindSelection 
               withSeedKind:(NSString*)seedKind error:(NSError**)outError;
- (void)openDocumentWithApplicaton:(NSString*)bundleId;

@end
