//
//  WindowController.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 06.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "WindowController.h"
#import "Document.h"

@implementation WindowController

@synthesize buttonStartTorrent = _buttonStartTorrent;
@synthesize comboSeedKind = _comboSeedKind;
@synthesize matrixTarget = _matrixTarget;
@synthesize labelFileType = _labelFileType;
@synthesize labelTorrentName = _labelTorrentName;
@synthesize imageViewIcon = _imageViewIcon;

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
    [[self comboSeedKind] selectItemAtIndex:0];
    TorrentTarget selection = ttQuark;
    [[self matrixTarget] selectCellAtRow:selection column:0];
    [[self comboSeedKind] setEnabled:(selection == ttQuark)];
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
    }
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)selectTargetKind:(id)sender {
    NSInteger targetSelection = [[self matrixTarget] selectedRow];
    NSAssert(targetSelection != -1, @"No radio selection");
    [[self comboSeedKind] setEnabled:((TorrentTarget)targetSelection == ttQuark)];
}

- (IBAction)performStartTorrent:(id)sender {
    NSLog(@"TODO");
    NSString* selection = [[self comboSeedKind] objectValueOfSelectedItem];
    NSLog(@"Selected: %@", selection); 
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:kLSCannotSetInfoErr userInfo:NULL];
    [self presentError:error];
}

- (IBAction)performDefaultMagnetHandler:(id)sender {
    NSLog(@"Setting defaults");
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    OSStatus result = LSSetDefaultHandlerForURLScheme((CFStringRef)@"magnet", (CFStringRef)bundleID);
    if (result != 0)
    {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:NULL];
        [self presentError:error];
    }
}

@end
