//
//  NSString+WordCount.m
//  Notes
//
//  Created by Евгений Сафронов on 17.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "NSString+WordCount.h"

@implementation NSString (WordCount)

- (NSUInteger)wordCount
{
    NSUInteger wordCount = 0;
    NSScanner *scanner   = [NSScanner scannerWithString:self];
    
    if (0 < [[scanner string] length])
    {
        [scanner setCharactersToBeSkipped:[NSCharacterSet illegalCharacterSet]];
        
        // Assume that words are separated only by whitespaces and new line characters
        NSCharacterSet *wordSeparators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        while(![scanner isAtEnd])
        {
            //  Change the scan location to the first character after the word separator
            [scanner scanCharactersFromSet:wordSeparators intoString:NULL];
            
            // Scan up to the first occurrence of any word separator
            if ([scanner scanUpToCharactersFromSet:wordSeparators intoString:NULL])
            {
                ++wordCount;
            }
        }
    }
    
    return wordCount;
}

@end
