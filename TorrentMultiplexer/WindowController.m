//
//  WindowController.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 06.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "WindowController.h"
#import "Document.h"
#import "Util.h"

@interface WindowController (PRIVATE)

- (NSImage*) loadImage:(NSString*)name;
- (BOOL)copyTorrentToServer:(NSString*)maskKey error:(NSError**)outError;
- (BOOL)copyTorrentFromURL:(NSURL*)url toServer:(NSString*)serverMask 
              withSeedKind:(NSString*)seedKind error:(NSError**)outError;
- (BOOL)openDocumentWithApplicaton:(NSString*)bundleId error:(NSError**)outError;

@end

@implementation WindowController

@synthesize buttonStartTorrent = _buttonStartTorrent;
@synthesize comboSeedKind = _comboSeedKind;
@synthesize matrixTarget = _matrixTarget;
@synthesize labelTorrentType = _labelFileType;
@synthesize labelTorrentName = _labelTorrentName;
@synthesize imageViewIcon = _imageViewIcon;
@synthesize labelTorrentAnnounce = _labelTorrentAnnounce;

- (id)initWithWindowNibName:(NSString*)windowNibName
{
    if (self = [super initWithWindowNibName:windowNibName])
    {
        dictTorrentType = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"Torrent file", kTorrentTypeFile,     
                           @"Magnet link", kTorrentTypeMagnet,   
                           nil];                           
        dictImageName = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"bittorrent", kTorrentTypeFile,     
                         @"magnet", kTorrentTypeMagnet, 
                         nil];                    
    }
    return self;
}

- (NSImage*) loadImage:(NSString*)name
{
    NSString* imageName = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
    if (imageObj == nil)
        @throw [NSException exceptionWithName:@"FileNotFoundException" reason:@"Image not found" userInfo:nil];
    [imageObj autorelease];
    return imageObj;
}

- (void)windowDidLoad
{
    NSLog(@"Loading UI");  
    if ([self document])
    {
        NSString *type = [[self document] torrentType];
        NSString *torrentTitle = [[self document] nameForTorrent];
        NSString *torrentAnnounce;
        if ([[self document] announceURL])
            torrentAnnounce = [NSString stringWithFormat:@"Announce: %@", [[self document] announceURL]];
        else
            torrentAnnounce = @"";        
        
        TorrentTarget seedKindSelection = ttQuark;
        for (NSInteger i = 0; i < ([[self matrixTarget] cellSize]).height; ++i)
        {
            if ([[[self matrixTarget] cellAtRow:i column:0] isEnabled])
            {
                seedKindSelection = (TorrentTarget)i;
                break;
            }
        }
        
        [[self labelTorrentName] setStringValue:torrentTitle];
        [[self labelTorrentType] setStringValue:[dictTorrentType objectForKey:type]];
        [[self labelTorrentAnnounce] setStringValue:torrentAnnounce];        
        [[self imageViewIcon] setImage:[self loadImage:[dictImageName objectForKey:type]]];
        
        BOOL flag = [type isEqualToString:kTorrentTypeFile];
        [[[self matrixTarget] cellAtRow:ttQuark column:0] setEnabled:YES];
        [[[self matrixTarget] cellAtRow:ttAtom column:0] setEnabled:YES];
        [[[self matrixTarget] cellAtRow:ttLocalFile column:0] setEnabled:flag];
        [[[self matrixTarget] cellAtRow:ttLocalMagnet column:0] setEnabled:!flag]; 
        [[[self matrixTarget] cellAtRow:ttSaveToFile column:0] setEnabled:!flag];
        
        [[self comboSeedKind] selectItemAtIndex:0];
        [[self comboSeedKind] setEnabled:(seedKindSelection == ttQuark)];
        [[self matrixTarget] selectCellAtRow:seedKindSelection column:0];
        
    }
}

- (void)dealloc
{
    [super dealloc];
}

//- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
//{
//    if ([[[self document] torrentType] isEqual:kTorrentTypeMagnet])
//        return [[self document] magnetHash];
//    else
//        return [super windowTitleForDocumentDisplayName:displayName];
//}

- (IBAction)selectTargetKind:(id)sender {
    NSInteger seedKindSelection = [[self matrixTarget] selectedRow];
    NSAssert(seedKindSelection != -1, @"No radio selection");
    [[self comboSeedKind] setEnabled:(seedKindSelection == ttQuark)];
}

- (IBAction)performStartTorrent:(id)sender {
    TorrentTarget seedKindSelection = (TorrentTarget)[[self matrixTarget] selectedRow];
    
    __block NSError *error = nil;
    switch (seedKindSelection)
    {
        case ttQuark:
        {
            [self copyTorrentToServer:PREFMaskQuark error:&error];
            break;
        }
        case ttAtom:
        {
            [self copyTorrentToServer:PREFMaskAtom error:&error];
            break;
        }
        case ttSaveToFile:
        {
            NSAssert([[[self document] torrentType] isEqualToString:kTorrentTypeMagnet], @"Wrong torrent type");
            NSLog(@"Saving magnet to file");
            NSSavePanel *savePanel = [NSSavePanel savePanel];
            [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"torrent"]];
            [savePanel setNameFieldStringValue:@"magnet.torrent"];
            [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
                if (result == NSFileHandlingPanelOKButton)
                {
                    [savePanel orderOut:[self window]];
                    NSURL *targetURL = [savePanel URL];
                    NSData* content = [[self document] magnetToLibtorrentBencoded];
                    [content writeToURL:targetURL options:NSDataWritingAtomic error:&error];
                }
            }];
            
            break;
        }
        case ttLocalFile:
        {
            NSString *localBundleId = [[NSUserDefaults standardUserDefaults] stringForKey:PREFAppTorrent];
            [self openDocumentWithApplicaton:localBundleId error:&error];
            break;
        }
        case ttLocalMagnet:
        {
            NSString *localBundleId = [[NSUserDefaults standardUserDefaults] stringForKey:PREFAppMagnet];
            [self openDocumentWithApplicaton:localBundleId error:&error];
            break;
        }
            
        default:
            error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EPERM userInfo:NULL];
    }
    if (error)
        [self presentError:error];  
}

- (BOOL)openDocumentWithApplicaton:(NSString*)bundleId error:(NSError**)outError
{
    NSLog(@"Opening document in application: %@", bundleId);
    
    if (bundleId == nil || [bundleId length] == 0)
    {
        if (outError)
            *outError = [Util makeError:@"No local application specified.\nPlease check preferences"];
        return NO;
    }
    
    LSLaunchURLSpec launchSpec;
    memset(&launchSpec, 0, sizeof(LSLaunchURLSpec));
    launchSpec.itemURLs = (CFArrayRef)[NSArray arrayWithObject:[[self document] fileURL]];
    OSStatus status = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)bundleId, 
                                      NULL, NULL, &launchSpec.appURL);
    if (status) {
        if (outError)
            *outError = [Util makeErrorFromStatus:status];
        return NO;
    }
    
    status = LSOpenFromURLSpec(&launchSpec, NULL);
    if (status) {
        if (outError)
            *outError = [Util makeErrorFromStatus:status];
        return NO;
    }
    return YES;
}

- (BOOL)copyTorrentFromURL:(NSURL*)url toServer:(NSString*)serverMask 
              withSeedKind:(NSString*)seedKind error:(NSError**)outError
{
    if (serverMask == nil || [serverMask length] == 0)
    {
        if (outError)
            *outError = [Util makeError:@"No server mask specified.\nPlease check preferences"];
        return NO;
    }
    
    NSString *serverPath = [NSString stringWithFormat:serverMask, seedKind];
    
    NSLog(@"Copying torrent to server: %@ from url: %@", serverPath, url);
    
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:[url path]];
    [args addObject:serverPath];
    
    NSTask *taskCopy = [[NSTask alloc] init];
    [taskCopy setArguments:args];
    [taskCopy setLaunchPath:@"/usr/bin/scp"];
    
    [taskCopy launch];
    [taskCopy waitUntilExit];
    
    int status = [taskCopy terminationStatus];
    [taskCopy release];
    
    if (status != 0)
    {
        if (outError)
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNetworkConnectionLost userInfo:NULL];   
        return NO;
    }
    NSLog(@"Task succeeded.");
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Torrent successfully copied to the server"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
    return YES;
}

- (BOOL)copyTorrentToServer:(NSString*)maskKey error:(NSError**)outError
{
    NSString* selection = [[self comboSeedKind] objectValueOfSelectedItem];    
    NSString *serverMask = [[NSUserDefaults standardUserDefaults] stringForKey:maskKey];
    NSURL *fileURL = [[self document] makeFileURL:outError];
    if (outError && *outError)
        return NO;
    [self copyTorrentFromURL:fileURL toServer:serverMask withSeedKind:selection error:outError];
    if (outError && *outError)
        return NO;
    return YES;

}


@end
