//
//  Util.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 07.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "Util.h"

NSString * const PREFAppTorrent = @"AppTorrent";
NSString * const PREFAppMagnet = @"AppMagnet";
NSString * const PREFMaskQuark = @"MaskQuark";
NSString * const PREFMaskAtom = @"MaskAtom";

@implementation Util

+ (NSError*)makeError:(NSString*)description
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    NSString *appID = [[NSBundle mainBundle] bundleIdentifier];
    return [NSError errorWithDomain:appID code:0 userInfo:dict];
}

+ (NSError*)makeErrorFromStatus:(OSStatus)status
{
    if (status != 0)
        return [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:NULL];
    else
        return nil;
}

+ (void)checkError:(OSStatus)status withResponder:(NSResponder*)responder
{
    NSError *error = [Util makeErrorFromStatus:status];
    if (error)
        [responder presentError:error];
}



@end

