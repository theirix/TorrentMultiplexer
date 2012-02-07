//
//  Util.m
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 07.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import "Util.h"

@implementation Util


+ (NSError*)createError:(NSString*)description
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"ru.omniverse.TorrentMultiplexer" code:0 userInfo:dict];
}

@end

