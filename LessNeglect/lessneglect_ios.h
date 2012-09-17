/*
 * Copyright 2012 Billy Coover / coovtech.com
 *
 * Author(s):
 *  Billy Coover / CoovTech, LLC (billy@coovtech.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#define kAPIBase @"https://lessneglect.com/api/v2"
#define kEventsURL @"events"
#define kPeopleURL @"people"

@interface Person : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *external_identifier;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *twitter;
@property (strong, nonatomic) NSString *is_paying;
@property (strong, nonatomic) NSString *account_level;
@property (strong, nonatomic) NSString *account_level_name;
@property (strong, nonatomic) NSString *url;

@end

@interface Event : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *magnitude;
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSMutableArray *links;
@property (strong, nonatomic) Person *person;

@end

@interface ActionLink : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *href;

@end

@interface Message : NSObject

@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) Person *person;

@end

@interface LessNeglectConnection : NSObject

+ (LessNeglectConnection *)connectionWithCode:(NSString *)code key:(NSString *)key;
- (id)initWithCode:(NSString *)_code key:(NSString *)_key;

- (void)createMessage:(Message *)message success:(void (^)(NSDictionary *response))success error:(void (^)(NSError *error))error;
- (void)createActionEvent:(Event *)event success:(void (^)(NSDictionary *response))success error:(void (^)(NSError *error))error;
- (void)updatePerson:(Person *)person success:(void (^)(NSDictionary *response))success error:(void (^)(NSError *error))error;

@end
