//
//  TrollModelHandler.m
//  JavaScriptDemo
//
//  Created by mac on 15-6-2.
//  Copyright (c) 2015年 com.nd. All rights reserved.
//

#import "TrollModelHandler.h"
#import <objc/runtime.h>

@implementation NSObject (ModelExpand)

- (NSDictionary *)SetArrayPropertyWithModelType{
    return nil;
}

@end

@implementation TrollModelHandler

+ (void)encodeModel:(id)model withDictionary:(NSDictionary *)dic{
    
    NSArray *keys = [dic allKeys];
    
    unsigned int propertyCount;
    objc_property_t *property = class_copyPropertyList([model class], &propertyCount);
    for(NSInteger i=0; i<propertyCount; i++){
        const char *propertyName_char = property_getName(property[i]);
        NSString *propertyName = [NSString stringWithUTF8String:propertyName_char];
        const char *attributeName_char = property_getAttributes(property[i]);
        NSString *attributeName = [NSString stringWithUTF8String:attributeName_char];
        NSString *attributeType = [TrollModelHandler GetClassOfAttributeString:attributeName];
        static NSInteger num = 0;
        for(NSString *key in keys){
            num++;
            NSLog(@"num = %ld",num);
            if([propertyName isEqualToString:key]){
                
                if([attributeType isEqualToString:@"NSArray"] || [attributeType isEqualToString:@"NSMutableArray"]){
                
                    NSDictionary *arrayPropertyWithType = [model SetArrayPropertyWithModelType];
                    if(arrayPropertyWithType){
                        NSArray *allKeys = [arrayPropertyWithType allKeys];
                        if([allKeys containsObject:key]){
                            NSString *childrenModelName = [arrayPropertyWithType valueForKey:key];
                            NSMutableArray *tmpArray = [NSMutableArray array];
                            for(NSDictionary *childrenDic in [dic valueForKey:key]){
                                id childrenModel;
                                Class childrenClass = NSClassFromString(childrenModelName);
                                childrenModel = [[childrenClass alloc] init];
                                
                                [TrollModelHandler encodeModel:childrenModel withDictionary:childrenDic];
                                [tmpArray addObject:childrenModel];
                            }
                            
                            NSString *firstChar = [key substringToIndex:1];
                            NSString *otherChars = [key substringFromIndex:1];
                            
                            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[firstChar capitalizedString], otherChars]);
                            [model performSelector:sel withObject:tmpArray];
                        }
                    }else{
                        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:",[key capitalizedString]]);
                        [model performSelector:sel withObject:[dic valueForKey:key]];
                    }
                    
                }else{
                    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:",[key capitalizedString]]);
                    [model performSelector:sel withObject:[dic valueForKey:key]];
                }
                
                break;
            }
        }
    }
}



+ (NSString *)GetClassOfAttributeString:(NSString *)attributeString{
    if(attributeString){
        if([attributeString rangeOfString:@"@"].location != NSNotFound){
            
            NSRange startRange = [attributeString rangeOfString:@"@\""];
            NSRange endRange = [attributeString rangeOfString:@"\","];
            
            NSString *reString = [attributeString substringWithRange:NSMakeRange(startRange.location+startRange.length, endRange.location-startRange.location-startRange.length)];
            return reString;
        }else{
            NSRange startRange = [attributeString rangeOfString:@"T"];
            NSRange endRange = [attributeString rangeOfString:@","];
            NSString *tmpString = [attributeString substringWithRange:NSMakeRange(startRange.location+startRange.length, endRange.location-startRange.location-startRange.length)];

            NSString *reString = nil;
            if([tmpString isEqualToString:@"B"]){
                reString = @"BOOL";
            }else if([tmpString isEqualToString:@"q"]){
                reString = @"NSInteger";
            }else if ([tmpString isEqualToString:@"d"]){
                reString = @"CGFloat";
            }else if ([tmpString isEqualToString:@"Q"]){
                reString = @"NSUInteger";
            }
            return reString;
        }
    }else{
        return nil;
    }
}

+ (BOOL)IsCustomeClass:(NSString *)classString{
    NSArray *typeArray = @[@"NSArray", @"NSMutableArray", @"NSString", @"NSMutableString", @"NSDictionary", @"NSMutableDictionary", @"NSNumber", @"BOOL", @"NSInteger", @"CGFloat", @"NSUInteger"];
    return [typeArray containsObject:classString];
}

@end
