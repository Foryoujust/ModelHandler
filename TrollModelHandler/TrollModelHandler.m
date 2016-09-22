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

- (NSDictionary *)ModelPropertyWithModelType{
    return nil;
}

@end

@implementation TrollModelHandler


#pragma mark - --------------- NSDictionary转Model ----------------

+ (void)encodeModel:(id)model withDictionary:(NSDictionary *)dic{
    
    NSArray *keys = [dic allKeys];
    
    unsigned int propertyCount;
    objc_property_t *property = class_copyPropertyList([model class], &propertyCount);
    for(NSInteger i=0; i<propertyCount; i++){
        const char *propertyName_char = property_getName(property[i]);
        NSString *propertyName = [NSString stringWithUTF8String:propertyName_char];
        const char *attributeName_char = property_getAttributes(property[i]);
        NSString *attributeName = [NSString stringWithUTF8String:attributeName_char];
        NSString *attributeType = [self GetClassOfAttributeString:attributeName];
        for(NSString *key in keys){
            if([propertyName isEqualToString:key]){
                if([attributeType isEqualToString:@"NSArray"] || [attributeType isEqualToString:@"NSMutableArray"]){
                
                    NSDictionary *arrayPropertyWithType = [model ModelPropertyWithModelType];
                    if(arrayPropertyWithType){
                        NSArray *allKeys = [arrayPropertyWithType allKeys];
                        if([allKeys containsObject:key]){
                            NSString *childrenModelName = [arrayPropertyWithType valueForKey:key];
                            NSMutableArray *tmpArray = [NSMutableArray array];
                            for(NSDictionary *childrenDic in [dic valueForKey:key]){
                                id childrenModel;
                                Class childrenClass = NSClassFromString(childrenModelName);
                                childrenModel = [[childrenClass alloc] init];
                                
                                [self encodeModel:childrenModel withDictionary:childrenDic];
                                [tmpArray addObject:childrenModel];
                            }
                            
                            SEL sel = [self selectorFromString:key];
                            [model performSelector:sel withObject:tmpArray];
                        }
                    }else{
                        SEL sel = [self selectorFromString:key];
                        [model performSelector:sel withObject:[dic valueForKey:key]];
                    }
                    
                }else if(![self IsCustomeClass:attributeType]){
                    NSDictionary *modelTmpDic = [model ModelPropertyWithModelType];
                    NSString *modelName = [modelTmpDic objectForKey:propertyName];
                    Class modelCustomer = NSClassFromString(modelName);
                    id modelTmp = [[modelCustomer alloc] init];
                    NSDictionary *modelDic = [dic objectForKey:key];
                    [self encodeModel:modelTmp withDictionary:modelDic];
                    SEL sel = [self selectorFromString:key];
                    [model performSelector:sel withObject:modelTmp];
                }else {
                    SEL sel = [self selectorFromString:key];
                    [model performSelector:sel withObject:[dic valueForKey:key]];
                }
                
                break;
            }
        }
    }
    free(property);
}

+ (SEL)selectorFromString:(NSString *)key{
    NSString *firstChar = [key substringToIndex:1];
    NSString *otherChars = [key substringFromIndex:1];
    
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[firstChar capitalizedString], otherChars]);
    return  sel;
}

#pragma mark - ------------- NSDictionary转Model结束 ---------------


#pragma mark - ------------ Model转NSDictionary --------------
+(NSDictionary *)decodeModel:(id)model{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propertyCount;
    objc_property_t *property = class_copyPropertyList([model class], &propertyCount);
    for(int i=0; i<propertyCount; i++){
        const char *propertyName_char = property_getName(property[i]);
        NSString *propertyName = [NSString stringWithCString:propertyName_char encoding:NSUTF8StringEncoding];
        const char *attributeName_char = property_getAttributes(property[i]);
        NSString *attributeName = [NSString stringWithCString:attributeName_char encoding:NSUTF8StringEncoding];
        NSString *attributeType = [self GetClassOfAttributeString:attributeName];
        if([attributeType isEqualToString:@"NSArray"] || [attributeType isEqualToString:@"NSMutableArray"]){
            SEL sel = NSSelectorFromString(propertyName);
            NSArray *childrenModels = [model performSelector:sel];
            NSMutableArray *childrens = [NSMutableArray array];
            for(id childrenModel in childrenModels){
                NSDictionary *childrenDic = [self decodeModel:childrenModel];
                [childrens addObject:childrenDic];
            }
            [dic setValue:childrens forKey:propertyName];
        }else if(![self IsCustomeClass:attributeType]){
            SEL sel = NSSelectorFromString(propertyName);
            id modelTmp = [model performSelector:sel];
            NSDictionary *modelDic = [self decodeModel:modelTmp];
            [dic setValue:modelDic forKey:propertyName];
        }else{
            SEL sel = NSSelectorFromString(propertyName);
            id value = [model performSelector:sel];
            [dic setValue:value forKey:propertyName];
        }
    }
    
    free(property);
    return [NSDictionary dictionaryWithDictionary:dic];
}

#pragma mark - ------------ Model转NSDictionary结束 ----------------


#pragma mark - --------------- Model转JSONString -------------------

+ (NSString *)decodeModelToJSONString:(id)model{
    NSDictionary *modelDic = [self decodeModel:model];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modelDic options:NSJSONWritingPrettyPrinted error:&jsonError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark - --------------- Model转JSONString结束 -------------------


#pragma mark - ---------------- NSDictionary转JSONString -----------------

+ (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark - --------------- NSDictionary转JSONString结束 ---------------


#pragma mark - ---------------- JSONString转NSDictionary ------------------

+ (NSDictionary *)JSONStringToDictionary:(NSString *)jsonString{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    return dic;
}


#pragma mark - ------------- 获取属性类型 ----------------

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


#pragma mark - --------------- 是否是自定义对象属性 --------------

+ (BOOL)IsCustomeClass:(NSString *)classString{
    NSArray *typeArray = @[@"NSArray", @"NSMutableArray", @"NSString", @"NSMutableString", @"NSDictionary", @"NSMutableDictionary", @"NSNumber", @"BOOL", @"NSInteger", @"CGFloat", @"NSUInteger"];
    return [typeArray containsObject:classString];
}




@end
