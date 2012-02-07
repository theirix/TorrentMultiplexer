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

- (void)awakeFromNib
{
    NSLog(@"Awaked"); 
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
    NSLog(@"window loaded");  
    if ([self document])
    {
        NSString *type = [[self document] torrentType];
        NSString *torrentTitle = [[self document] nameForTorrent];
        NSString *torrentAnnounce;
        if ([[self document] announceURL])
            torrentAnnounce = [NSString stringWithFormat:@"Announce: %@", [[self document] announceURL]];
        else
            torrentAnnounce = @"";        
        
        TorrentTarget seedKindSelection = [type isEqual:kTorrentTypeFile] ? ttQuark: ttSaveToFile;

        [[self labelTorrentName] setStringValue:torrentTitle];
        [[self labelTorrentType] setStringValue:[dictTorrentType objectForKey:type]];
        [[self labelTorrentAnnounce] setStringValue:torrentAnnounce];        
        [[self imageViewIcon] setImage:[self loadImage:[dictImageName objectForKey:type]]];
        
        BOOL flag = [type isEqualToString:kTorrentTypeFile];
        [[[self matrixTarget] cellAtRow:ttQuark column:0] setEnabled:flag];
        [[[self matrixTarget] cellAtRow:ttAtom column:0] setEnabled:flag];
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

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    if ([[[self document] torrentType] isEqual:kTorrentTypeMagnet])
        return [[[self document] magnetURL] absoluteString];
    else
        return [super windowTitleForDocumentDisplayName:displayName];
}

- (IBAction)selectTargetKind:(id)sender {
    NSInteger seedKindSelection = [[self matrixTarget] selectedRow];
    NSAssert(seedKindSelection != -1, @"No radio selection");
    [[self comboSeedKind] setEnabled:(seedKindSelection == ttQuark)];
}

- (IBAction)performStartTorrent:(id)sender {
    NSString* selection = [[self comboSeedKind] objectValueOfSelectedItem];
    NSLog(@"Selected: %@", selection); 
    
    TorrentTarget seedKindSelection = (TorrentTarget)[[self matrixTarget] selectedRow];
    NSString *type = [[self document] torrentType];
    
    __block NSError *error = nil;
    switch (seedKindSelection)
    {
        case ttQuark:
        {
            NSString *serverMask = [[NSUserDefaults standardUserDefaults] stringForKey:PREFMaskQuark];
            [self copyTorrentToServer:serverMask withSeedKind:selection error:&error];
            break;
        }
        case ttAtom:
        {
            NSString *serverMask = [[NSUserDefaults standardUserDefaults] stringForKey:PREFMaskAtom];
            [self copyTorrentToServer:serverMask withSeedKind:selection error:&error];
            break;
        }
        case ttSaveToFile:
        {
            NSAssert([type isEqualToString:kTorrentTypeMagnet], @"Wrong torrent type");
            NSLog(@"Saving magnet to file");
            NSSavePanel *savePanel = [NSSavePanel savePanel];
            [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"torrent"]];
            [savePanel setNameFieldStringValue:@"magnet.torrent"];
            [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
                if (result == NSFileHandlingPanelOKButton)
                {
                    [savePanel orderOut:[self window]];
                    NSURL *targetURL = [savePanel URL];
                    NSString *content = [[[self document] fileURL] absoluteString];
                    [content writeToURL:targetURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
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

- (void)openDocumentWithApplicaton:(NSString*)bundleId error:(NSError**)outError
{
    NSLog(@"Opening document in application: %@", bundleId);
    
    if (bundleId == nil || [bundleId length] == 0)
    {
        [Util makeError:@"No local application specified.\nPlease check preferences" error:outError];
        return;
    }
    
    LSLaunchURLSpec launchSpec;
    memset(&launchSpec, 0, sizeof(LSLaunchURLSpec));
    launchSpec.itemURLs = (CFArrayRef)[NSArray arrayWithObject:[[self document] fileURL]];
    OSStatus status = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)bundleId, 
                                      NULL, NULL, &launchSpec.appURL);
    if (status) {
        [Util makeErrorFromStatus:status error:outError];
        return;
    }
    
    status = LSOpenFromURLSpec(&launchSpec, NULL);
    if (status) {
        [Util makeErrorFromStatus:status error:outError];
        return;
    }
}

- (void)copyTorrentToServer:(NSString*)serverMask withSeedKind:(NSString*)seedKind error:(NSError**)outError
{
    NSAssert(outError, @"No error");
    
//    NSString *serverPathFormat = @"%@.omniverse.ru:rtorrent/watch-%@";
    if (serverMask == nil || [serverMask length] == 0)
    {
        [Util makeError:@"No server mask specified.\nPlease check preferences" error:outError];
        return;
    }
        
    NSString *serverPath = [NSString stringWithFormat:serverMask, seedKind];
    
    NSLog(@"Copying torrent to server: %@", serverPath);
    
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:[[[self document] fileURL] path]];
    [args addObject:serverPath];

    NSTask *taskCopy = [[NSTask alloc] init];
    [taskCopy setArguments:args];
    [taskCopy setLaunchPath:@"/usr/bin/scp"];

    [taskCopy launch];
    [taskCopy waitUntilExit];
    
    int status = [taskCopy terminationStatus];
    
    if (status == 0)
        NSLog(@"Task succeeded.");
    else
        *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNetworkConnectionLost userInfo:NULL];
}

@end
