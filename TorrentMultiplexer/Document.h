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
    NSString *magnetURL;
    NSString *torrentType;
}

- (NSString*) nameForTorrent;
@property(readonly) NSString *torrentType;

@end
