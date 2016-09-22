//
//  TrollModelHandler.h
//  JavaScriptDemo
//
//  Created by mac on 15-6-2.
//  Copyright (c) 2015年 com.nd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ModelExpand)

/**
    设置NSArray属性对应的子Model和自定义对象属性对应的Model
 */
- (NSDictionary *)ModelPropertyWithModelType;


@end

@interface TrollModelHandler : NSObject
/**  
    将NSDictionary转换成Model
 */
+ (void)encodeModel:(id)model withDictionary:(NSDictionary *)dic;

/**
    将Model转换成NSDictionary
 */
+ (NSDictionary *)decodeModel:(id)model;

/**
    将Model转换成JSONString
 */
+ (NSString *)decodeModelToJSONString:(id)model;

/**
    将NSDictionary转换成JSONString
 */
+ (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary;

/**
    将JSONString转换成NSDictionary
 */
+ (NSDictionary *)JSONStringToDictionary:(NSString *)jsonString;
@end
