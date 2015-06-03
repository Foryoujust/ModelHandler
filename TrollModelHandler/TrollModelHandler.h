//
//  TrollModelHandler.h
//  JavaScriptDemo
//
//  Created by mac on 15-6-2.
//  Copyright (c) 2015年 com.nd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ModelExpand)

- (NSDictionary *)SetArrayPropertyWithModelType;

@end

@interface TrollModelHandler : NSObject

+ (void)encodeModel:(id)model withDictionary:(NSDictionary *)dic;

@end
