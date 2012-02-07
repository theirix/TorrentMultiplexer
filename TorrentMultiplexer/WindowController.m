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
@synthesize labelFileType = _labelFileType;
@synthesize labelTorrentName = _labelTorrentName;
@synthesize imageViewIcon = _imageViewIcon;
@synthesize comboLocalTorrentApp = _comboLocalTorrentApp;
@synthesize comboLocalMagnetApp = _comboLocalMagnetApp;

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
        
        torrentHandlers = [NSMutableArray arrayWithArray:
                           (NSArray*)LSCopyAllRoleHandlersForContentType((CFStringRef)@"org.bittorrent.torrent",
                                                                         kLSRolesAll)];
        magnetHandlers = [NSMutableArray arrayWithArray:
                          (NSArray*)LSCopyAllHandlersForURLScheme((CFStringRef)@"magnet")];
        
        NSString *bundleSelfId = [[[NSBundle mainBundle] bundleIdentifier] lowercaseString];
        [torrentHandlers removeObject:bundleSelfId];
        [magnetHandlers removeObject:bundleSelfId];                
    }
    return self;
}

- (void) checkError:(OSStatus)status
{
    if (status != 0)
    {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:NULL];
        [self presentError:error];
    }
}

- (void) fillCombo:(NSComboBox*)comboBox withApps:(NSArray*)bundleIds
{
    NSAssert(bundleIds, @"No ids specified");
    for (NSString *bundleId in bundleIds)
    {
        NSString *name = nil;
        CFURLRef cfUrl;
        OSStatus status = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)bundleId, NULL, NULL, &cfUrl);
        [self checkError:status];
        NSURL *url = (NSURL*)cfUrl;
        NSBundle *bundle = [NSBundle bundleWithURL:url];
        if (bundle)
        {
            name = [[bundle infoDictionary] valueForKey:@"CFBundleName"];
        }
        [url release];
        if (!name)
            name = [bundleId copy];        
        [comboBox addItemWithObjectValue:name];
    }
}

- (void)awakeFromNib
{
    NSLog(@"Awaked"); 
    
    [self fillCombo:[self comboLocalTorrentApp] withApps:torrentHandlers];
    [self fillCombo:[self comboLocalMagnetApp] withApps:magnetHandlers];
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
        NSString *torrentTitle = [(Document*)[self document] nameForTorrent];
        NSString *type = [[self document] torrentType];
        [[self labelTorrentName] setStringValue:torrentTitle];
        [[self labelFileType] setStringValue:[dictTorrentType objectForKey:type]];
        [[self imageViewIcon] setImage:[self loadImage:[dictImageName objectForKey:type]]];
        
        BOOL flag = [type isEqualToString:kTorrentTypeFile];
        [[[self matrixTarget] cellAtRow:ttQuark column:0] setEnabled:flag];
        [[[self matrixTarget] cellAtRow:ttAtom column:0] setEnabled:flag];
        [[[self matrixTarget] cellAtRow:ttLocalFile column:0] setEnabled:flag];        
        [[[self matrixTarget] cellAtRow:ttLocalMagnet column:0] setEnabled:!flag]; 
        [[[self matrixTarget] cellAtRow:ttSaveToFile column:0] setEnabled:!flag];
        
        [[self comboSeedKind] selectItemAtIndex:0];
        TorrentTarget seedKindSelection = ttQuark;
        for (NSInteger i = 0; i < ([[self matrixTarget] cellSize]).height; ++i)
        {
            if ([[[self matrixTarget] cellAtRow:i column:0] isEnabled])
            {
                [[self matrixTarget] selectCellAtRow:i column:0];
                break;
            }
        }
       
        [[self comboSeedKind] setEnabled:(seedKindSelection == ttQuark)];
    }
}

- (void)dealloc
{
    [super dealloc];
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
    
    NSError *error = nil;
    switch (seedKindSelection)
    {
        case ttQuark:
        case ttAtom:
        {
            [self copyTorrentToServer:seedKindSelection withSeedKind:selection error:&error];
            break;
        }
        case ttSaveToFile:
        {
            NSAssert([type isEqualToString:kTorrentTypeMagnet], @"Wrong torrent type");
            break;
        }
        case ttLocalFile:
        {
            NSInteger selection = [[self comboLocalTorrentApp] indexOfSelectedItem];
            if (selection != -1)
            {
                [self openDocumentWithApplicaton:[torrentHandlers objectAtIndex:selection]];
            }
            else
                [Util createError:@"No application selected"];
            break;
        }
        case ttLocalMagnet:
        {
            NSInteger selection = [[self comboLocalMagnetApp] indexOfSelectedItem];
            if (selection != -1)
            {
                [self openDocumentWithApplicaton:[magnetHandlers objectAtIndex:selection]];
            }
            else
                [Util createError:@"No application selected"];
            break;
        }
            
        default:
            error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EPERM userInfo:NULL];
    }
    if (error)
        [self presentError:error];  

}

- (void)openDocumentWithApplicaton:(NSString*)bundleId
{
    NSLog(@"Opening document in application: %@", bundleId);
    
    LSLaunchURLSpec launchSpec;
    memset(&launchSpec, 0, sizeof(LSLaunchURLSpec));
    launchSpec.itemURLs = (CFArrayRef)[NSArray arrayWithObject:[[self document] fileURL]];
    OSStatus status = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)bundleId, 
                                      NULL, NULL, &launchSpec.appURL);
    [self checkError:status];
    
    status = LSOpenFromURLSpec(&launchSpec, NULL);
    [self checkError:status];
}

- (void)copyTorrentToServer:(TorrentTarget)seedKindSelection 
                            withSeedKind:(NSString*)seedKind error:(NSError**)outError
{
    NSAssert(outError, @"No error");
    
    NSString *serverName = nil;
    if (seedKindSelection == ttQuark)
        serverName = @"quark";
    else if (seedKindSelection == ttAtom)
        serverName = @"atom";
    else
        *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:NULL];

//    NSString *serverPathFormat = @"%@.omniverse.ru:rtorrent/watch-%@";
    NSString *serverPathFormat = @"%@.omniverse.ru:";    
    NSString *serverPath = [NSString stringWithFormat:serverPathFormat, serverName, seedKind];
    
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

- (IBAction)performDefaultTorrentHandler:(id)sender
{
    NSLog(@"Setting default torrent");
    OSStatus result = LSSetDefaultRoleHandlerForContentType((CFStringRef)@"org.bittorrent.torrent",
                                                             kLSRolesViewer,
                                                            (CFStringRef)[[NSBundle mainBundle] bundleIdentifier]);
    [self checkError:result];
}

- (IBAction)performDefaultMagnetHandler:(id)sender 
{
    NSLog(@"Setting default magnet");
    OSStatus result = LSSetDefaultHandlerForURLScheme((CFStringRef)@"magnet",
                                                      (CFStringRef)[[NSBundle mainBundle] bundleIdentifier]);
    [self checkError:result];
}

@end
