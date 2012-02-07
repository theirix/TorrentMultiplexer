//
//  Util.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 07.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "Util.h"

NSString * const APPId = @"ru.omniverse.TorrentMultiplexer";

NSString * const PREFAppTorrent = @"AppTorrent";
NSString * const PREFAppMagnet = @"AppMagnet";
NSString * const PREFMaskQuark = @"MaskQuark";
NSString * const PREFMaskAtom = @"MaskAtom";

@implementation Util

+ (void)makeError:(NSString*)description  error:(NSError**)outError
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    if (outError)
        *outError = [NSError errorWithDomain:APPId code:0 userInfo:dict];   
}

+ (void)makeErrorFromStatus:(OSStatus)status error:(NSError**)outError
{
    if (outError)
    {
        if (status != 0)
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:NULL];
        else
            *outError = nil;
    }
}

+ (void)checkError:(OSStatus)status withResponder:(NSResponder*)responder
{
    NSError *error;
    [Util makeErrorFromStatus:status error:&error];
    if (error)
        [responder presentError:error];
}



@end

