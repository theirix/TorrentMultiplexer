//
//  DocumentController.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 07.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "DocumentController.h"
#import "Document.h"

@implementation DocumentController

- (NSString *)typeForContentsOfURL:(NSURL *)inAbsoluteURL error:(NSError **)outError
{
    if ([[inAbsoluteURL scheme] isEqualToString:@"file"])
        return kTorrentTypeFile;
    else if ([[inAbsoluteURL scheme] isEqualToString:@"magnet"])
        return kTorrentTypeMagnet;
    else
    {
        if (outError)
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:openErr userInfo:NULL];
        return @"";
    }
}

- (Class)documentClassForType:(NSString *)documentTypeName
{
    return [Document class];
}

@end
