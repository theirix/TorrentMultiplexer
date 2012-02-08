//
//  Document.h
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 05.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const kTorrentTypeFile;
extern NSString * const kTorrentTypeMagnet;

@interface Document : NSDocument {

@private
    NSObject *torrentDict;
    NSURL *magnetURL;
    NSString *torrentType;
}

- (NSString*) nameForTorrent;
- (NSURL*) announceURL;
- (NSData*) magnetToLibtorrentBencoded;
- (NSString*) magnetHash;

// Actually it saves a magnet link to a file
- (NSURL*)makeFileURL:(NSError**)outError;

- (NSString *)displayName;

@property(readonly) NSString *torrentType;
@property(readonly) NSURL *magnetURL;

@end
