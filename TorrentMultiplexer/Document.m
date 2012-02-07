//
//  Document.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 05.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "Document.h"
#import "WindowController.h"
#import "GEBEncoding.h"

@implementation Document

NSString * const kTorrentTypeFile = @"BitTorrent Document";
NSString * const kTorrentTypeMagnet = @"BitTorrent Magnet URL";

@synthesize torrentType;
@synthesize magnetURL;


- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"Doc init");
        torrentDict = nil;
        magnetURL = nil;
        torrentType = nil;
        [self setHasUndoManager:NO];
    }
    return self;
}

- (void)dealloc
{
//    if (torrentDict)
//        [torrentDict release];
//    if (magnetURL)
//        [magnetURL release];
//    if (torrentType)
//        [torrentType release];
    [super dealloc];
}

- (void)makeWindowControllers
{
    WindowController *windowController = [[WindowController alloc] initWithWindowNibName:@"Document"];
    [self addWindowController:windowController];
    [windowController release];   
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (NSString*) prefixWithLevel:(NSInteger)level
{
    NSMutableString *prefix = [NSMutableString string];
    for (int i = 0; i < level; ++i)
        [prefix appendString:@"  "];
    return prefix;
}

- (void) inspectTorrentData:(NSObject*)data withLevel:(NSInteger)level
{
    NSString *prefix = [self prefixWithLevel:level];
    if ([data isKindOfClass:[NSDictionary class]])
    {
        for (NSString *key in [(NSDictionary*)data keyEnumerator])
        {
            NSLog(@"%@ <hash key> %@", prefix, key);       
            [self inspectTorrentData:[(NSDictionary*)data objectForKey:key] withLevel:(level+1)];
        }
    }
    else if ([data isKindOfClass:[NSArray class]])
    {
        NSLog(@"%@ <array>", prefix);
        for (NSObject *obj in (NSArray*)data)
        {
//            NSLog(@"%@ <array element>", prefix);
            [self inspectTorrentData:obj withLevel:(level+1)];
        }
    }
    else if ([data isKindOfClass:[NSString class]]) 
    {
        NSLog(@"%@ <string> %@", prefix, (NSString*)data);
    }
    else if ([data isKindOfClass:[NSNumber class]]) 
    {
        NSLog(@"%@ <int> %@", prefix, (NSNumber*)data);
    }
    else 
    {
        //NSLog(@"%@ <other> %@", prefix, data);
        NSLog(@"%@ <other>", prefix);
    }
}


- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL readSuccess = NO;

    if (absoluteURL)
    {   
        torrentType = [typeName copy];
        NSLog(@"Readind document type %@, url %@", torrentType, absoluteURL);        
        if ([torrentType isEqual:kTorrentTypeFile])
        {
            NSData *fileData = [NSData dataWithContentsOfURL:absoluteURL];
            torrentDict = [GEBEncoding objectFromEncodedData:fileData withTypeAdvisor:^(NSArray *keyStack) {
                return [keyStack count] > 0 && [(NSString*)[keyStack lastObject] isEqualToString:@"pieces"]
                ? GEBEncodedDataType
                : GEBEncodedStringType;            
            }];
            magnetURL = nil;
            readSuccess = torrentDict != NULL;
            [self inspectTorrentData:torrentDict withLevel:0];
        }
        else if ([torrentType isEqual:kTorrentTypeMagnet])
        {
            torrentDict = nil;
            magnetURL = [absoluteURL copy];
            readSuccess = absoluteURL != NULL;
        }
        else
        {
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:NULL];
        }
    }
    
    if (readSuccess)
    {
        NSLog(@"Torrent name: %@", [self nameForTorrent]);
    }
    
    if (!readSuccess && outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return readSuccess;    
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSString*) nameForTorrent
{
    if ([torrentType isEqual:kTorrentTypeFile])
    {
        NSAssert(torrentDict, @"Torrent data");
        NSDictionary *node = (NSDictionary*)[(NSDictionary*)torrentDict objectForKey:@"info"];
        if (node)
        {
            NSString *name = (NSString*)[node objectForKey:@"name"];
            if (name && [name length] > 0)
            {
                return name;
            }
        }
    }
    else if ([torrentType isEqual:kTorrentTypeMagnet])
    {
        NSAssert(magnetURL, @"Magnet URL");
        return [magnetURL absoluteString];
    }
    return @"<none>";
}

- (NSURL*) announceURL
{
    if ([torrentType isEqual:kTorrentTypeFile])
    {
        NSAssert(torrentDict, @"Torrent data");
        NSString *node = (NSString*)[(NSDictionary*)torrentDict objectForKey:@"announce"];
        if (node && [node length] > 0)
        {
            return [NSURL URLWithString:node];
        }
    }
    return nil;
}

@end
