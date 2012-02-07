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


- (id)init
{
    self = [super init];
    if (self) {
        torrentDict = nil;
        magnetURL = nil;
        torrentType = nil;
    }
    return self;
}

- (void)dealloc
{
    if (torrentDict)
        [torrentDict release];
    if (magnetURL)
        [magnetURL release];
    if (torrentType)
        [torrentType release];
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
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
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
        NSLog(@"%@ <other> %@", prefix, data);
    }
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    /*
    Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    */
    BOOL readSuccess = NO;

    if (data)
    {   
        torrentType = [typeName copy];
        NSLog(@"Readind document type %@", torrentType);        
        if ([torrentType isEqual:kTorrentTypeFile])
        {
            torrentDict = [GEBEncoding objectFromEncodedData:data withTypeAdvisor:^(NSArray *keyStack) {
                return [keyStack count] > 0 && [(NSString*)[keyStack lastObject] isEqualToString:@"pieces"]
                    ? GEBEncodedDataType
                    : GEBEncodedStringType;            
            }];
            magnetURL = nil;
            readSuccess = torrentDict != NULL;
        }
        else if ([torrentType isEqual:kTorrentTypeMagnet])
        {
            torrentDict = nil;
            magnetURL = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        }
        else
        {
            @throw [NSException exceptionWithName:@"NSInternalInconsistencyException"
                                           reason:@"Wrong document type" userInfo:nil];
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
        NSAssert(magnetURL && [magnetURL length] > 0, @"Magnet URL");
        return magnetURL;
    }
    return @"<none>";
}

@end
