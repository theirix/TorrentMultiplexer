//
//  PreferencesController.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 07.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "PreferencesController.h"
#import "Util.h"

@interface PreferencesController (PRIVATE)

- (NSString*) appNameForBundleId:(NSString*)bundleId;
- (void) helperReadEdit:(NSTextField*)control fromPreference:(NSString*)prefKey;
- (void) helperReadTypeCombo:(NSComboBox*)control fromPreference:(NSString*)prefKey withHandlers:(NSArray*)handlers;
- (void) helperWriteEdit:(NSTextField*)control toPreference:(NSString*)prefKey;
- (void) helperWriteTypeCombo:(NSComboBox*)control toPreference:(NSString*)prefKey withHandlers:(NSArray*)handlers;
- (void) loadPreferences;
- (void) savePreferences;

@end

@implementation PreferencesController
@synthesize editQuarkFormat;
@synthesize editAtomFormat;
@synthesize labelDefaultTorrentApp;
@synthesize labelDefaultMagnetApp;
@synthesize comboTorrentsApp;
@synthesize comboMagnetApp;


- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        torrentHandlers = nil;
        magnetHandlers = nil;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self loadPreferences];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self savePreferences];
}

- (IBAction)performSetDefaultTorrent:(id)sender
{
    NSLog(@"Setting default torrent");
    OSStatus result = LSSetDefaultRoleHandlerForContentType((CFStringRef)@"org.bittorrent.torrent",
                                                            kLSRolesViewer,
                                                            (CFStringRef)[[NSBundle mainBundle] bundleIdentifier]);
    [Util checkError:result withResponder:self];
}

- (IBAction)performSetDefaultMagnet:(id)sender
{
    NSLog(@"Setting default magnet");
    OSStatus result = LSSetDefaultHandlerForURLScheme((CFStringRef)@"magnet",
                                                      (CFStringRef)[[NSBundle mainBundle] bundleIdentifier]);
    [Util checkError:result withResponder:self];
}

- (NSString*) appNameForBundleId:(NSString*)bundleId
{
    CFURLRef cfUrl;
    OSStatus status = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)bundleId, NULL, NULL, &cfUrl);
    [Util checkError:status withResponder:self];
    NSURL *url = (NSURL*)cfUrl;
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSAssert(bundle, @"Can't find bundle");
    NSString *name = [[bundle infoDictionary] valueForKey:@"CFBundleName"];
    [url release];
    return name;
}

- (void) helperReadEdit:(NSTextField*)control fromPreference:(NSString*)prefKey
{
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:prefKey];
    if (value == nil || [value length] == 0)
        value = @"";
    [control setStringValue:value];
}

- (void) helperReadTypeCombo:(NSComboBox*)control fromPreference:(NSString*)prefKey withHandlers:(NSArray*)handlers
{    
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:prefKey];
    if (value == nil || [value length] == 0)
        value = @"";

    for (NSString *bundleId in handlers)
    {
        [control addItemWithObjectValue:[self appNameForBundleId:bundleId]];
    }
    
    NSInteger selection = -1;
    if ([value length] > 0)
    {
        selection = [handlers indexOfObject:value];        
    }
    else
    {
        if ([handlers count] == 1)
            selection = 0;
    }
    [control selectItemAtIndex:selection];
}

- (void) helperWriteEdit:(NSTextField*)control toPreference:(NSString*)prefKey
{
    NSString *value = [control stringValue];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:prefKey];
}

- (void) helperWriteTypeCombo:(NSComboBox*)control toPreference:(NSString*)prefKey withHandlers:(NSArray*)handlers
{
    NSString *value;
    NSInteger selection = [control indexOfSelectedItem];
    if (selection != -1)
        value = [handlers objectAtIndex:selection];
    else
        value = @"";
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:prefKey];    
}

- (void) loadPreferences
{
    NSLog(@"Loading preferences");
    
    torrentHandlers = [NSMutableArray arrayWithArray:(NSArray*)LSCopyAllRoleHandlersForContentType(
        (CFStringRef)@"org.bittorrent.torrent", kLSRolesAll)];
    [torrentHandlers retain];
    magnetHandlers = [NSMutableArray arrayWithArray:
                      (NSArray*)LSCopyAllHandlersForURLScheme((CFStringRef)@"magnet")];
    [magnetHandlers retain];
    
    NSString *bundleSelfId = [[[NSBundle mainBundle] bundleIdentifier] lowercaseString];
    [torrentHandlers removeObject:bundleSelfId];
    [magnetHandlers removeObject:bundleSelfId];  
    
    [self helperReadTypeCombo:comboTorrentsApp  fromPreference:PREFAppTorrent   withHandlers:torrentHandlers];
    [self helperReadTypeCombo:comboMagnetApp    fromPreference:PREFAppMagnet    withHandlers:magnetHandlers]; 
    
    [self helperReadEdit:editQuarkFormat fromPreference:PREFMaskQuark];
    [self helperReadEdit:editAtomFormat  fromPreference:PREFMaskAtom];
    
    NSString *defaultTorrentBundleId = (NSString*)LSCopyDefaultRoleHandlerForContentType (
        (CFStringRef)@"org.bittorrent.torrent", kLSRolesAll);
    NSString *defaultMagnetBundleId = (NSString*)LSCopyDefaultHandlerForURLScheme((CFStringRef)@"magnet");
    
    [[self labelDefaultTorrentApp] setStringValue:[self appNameForBundleId:defaultTorrentBundleId]];
    [[self labelDefaultMagnetApp] setStringValue:[self appNameForBundleId:defaultMagnetBundleId]];
}



- (void) savePreferences
{
    NSLog(@"Saving preferences");
    
    [self helperWriteTypeCombo:comboTorrentsApp  toPreference:PREFAppTorrent   withHandlers:torrentHandlers];
    [self helperWriteTypeCombo:comboMagnetApp    toPreference:PREFAppMagnet    withHandlers:magnetHandlers]; 
    
    [self helperWriteEdit:editQuarkFormat toPreference:PREFMaskQuark];
    [self helperWriteEdit:editAtomFormat  toPreference:PREFMaskAtom];
}


@end
