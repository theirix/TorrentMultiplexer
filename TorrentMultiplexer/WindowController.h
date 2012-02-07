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
@property (assign) IBOutlet NSTextField *labelTorrentType;
@property (assign) IBOutlet NSTextField *labelTorrentName;
@property (assign) IBOutlet NSTextField *labelTorrentAnnounce;
@property (assign) IBOutlet NSImageView *imageViewIcon;


- (IBAction)selectTargetKind:(id)sender;
- (IBAction)performStartTorrent:(id)sender;

- (void)copyTorrentToServer:(NSString*)serverMask withSeedKind:(NSString*)seedKind error:(NSError**)outError;
- (void)openDocumentWithApplicaton:(NSString*)bundleId error:(NSError**)outError;

@end
