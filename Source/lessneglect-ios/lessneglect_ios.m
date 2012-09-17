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

#import "lessneglect_ios.h"
#import "NSData+Additions.h"

@interface LessNeglectConnection ()

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *key;

@end

@implementation LessNeglectConnection
@synthesize code, key;

+ (LessNeglectConnection *)connectionWithCode:(NSString *)code key:(NSString *)key {
    return [[self alloc] initWithCode:code key:key];
}

- (id)initWithCode:(NSString *)_code key:(NSString *)_key {
    if ((self = [super init])) {
        self.code = _code;
        self.key = _key;
    }
    return self;
}

- (NSString *)authHeader {
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.code, self.key];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
}

- (void)createMessage:(Message *)message success:(void (^)(NSDictionary *response))success error:(void (^)(NSError *error))error {
    NSURL *url = [[NSURL URLWithString:kAPIBase] URLByAppendingPathComponent:kEventsURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [self HTTPBodyWithMessage:message];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *body, NSError *requestError) {
                               if (!response && requestError) {
                                   if ([requestError.domain isEqualToString:@"NSURLErrorDomain"] &&
                                       requestError.code == NSURLErrorUserCancelledAuthentication) {
                                       error([NSError errorWithDomain:@"LessNeglect" code:0 userInfo:
                                              [NSDictionary dictionaryWithObject:@"Authentication failed" forKey:@"message"]]);
                                   } else
                                       error(requestError);
                                   return;
                               }
                               NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:body options:0 error:NULL];
                               if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                                   success(responseData);
                               } else {
                                   error([NSError errorWithDomain:@"LessNeglect" code:0 userInfo:[responseData objectForKey:@"error"]]);
                               }
                           }];
}

- (void)createActionEvent:(Event *)event success:(void (^)(NSDictionary *response))success error:(void (^)(NSError *error))error {
    NSURL *url = [[NSURL URLWithString:kAPIBase] URLByAppendingPathComponent:kEventsURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [self HTTPBodyWithEvent:event];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *body, NSError *requestError) {
                               if (!response && requestError) {
                                   if ([requestError.domain isEqualToString:@"NSURLErrorDomain"] &&
                                       requestError.code == NSURLErrorUserCancelledAuthentication) {
                                       error([NSError errorWithDomain:@"LessNeglect" code:0 userInfo:
                                              [NSDictionary dictionaryWithObject:@"Authentication failed" forKey:@"message"]]);
                                   } else
                                       error(requestError);
                                   return;
                               }
                               NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:body options:0 error:NULL];
                               if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                                   success(responseData);
                               } else {
                                   error([NSError errorWithDomain:@"LessNeglect" code:0 userInfo:[responseData objectForKey:@"error"]]);
                               }
                           }];
}

- (void)updatePerson:(Person *)person success:(void (^)(NSDictionary *response))success error:(void (^)(NSError *error))error {
    NSURL *url = [[NSURL URLWithString:kAPIBase] URLByAppendingPathComponent:kPeopleURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [self HTTPBodyWithPerson:person];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *body, NSError *requestError) {
                               if (!response && requestError) {
                                   if ([requestError.domain isEqualToString:@"NSURLErrorDomain"] &&
                                       requestError.code == NSURLErrorUserCancelledAuthentication) {
                                       error([NSError errorWithDomain:@"LessNeglect" code:0 userInfo:
                                              [NSDictionary dictionaryWithObject:@"Authentication failed" forKey:@"message"]]);
                                   } else
                                       error(requestError);
                                   return;
                               }
                               NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:body options:0 error:NULL];
                               if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                                   success(responseData);
                               } else {
                                   error([NSError errorWithDomain:@"LessNeglect" code:0 userInfo:[responseData objectForKey:@"error"]]);
                                   NSString *resp = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                               }
                           }];
}

- (NSData *)HTTPBodyWithEvent:(Event *)event {
    NSMutableString *body = [NSMutableString string];
    body = [self personToQueryString:event.person];
    if (body.length != 0)
        [body appendString:@"&"];
    [body appendFormat:@"event[klass]=actionevent"];
    if (event.name) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"event[name]=%@", event.name];
    }
    if (event.note) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"event[note]=%@", event.note];
    }
    if (event.magnitude) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"event[magnitude]=%@", event.magnitude];
    }
    if(event.links != nil && event.links.count > 0) {
        int count = 0;
        for (ActionLink *link in event.links) {
            if (body.length != 0)
                [body appendString:@"&"];
            [body appendFormat:@"event[%d][name]=%@", count, event.magnitude];
            [body appendString:@"&"];
            [body appendFormat:@"event[%d][href]=%@", count, event.magnitude];
            count++;
        }
    }
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)HTTPBodyWithMessage:(Message *)message {
    NSMutableString *body = [NSMutableString string];
    body = [self personToQueryString:message.person];
    if (body.length != 0)
        [body appendString:@"&"];
    [body appendFormat:@"event[klass]=message"];
    if (message.subject) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"event[subject]=%@", message.subject];
    }
    if (message.body) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"event[body]=%@", message.body];
    }
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)HTTPBodyWithPerson:(Person *)person {
    NSMutableString *body = [NSMutableString string];
    body = [self personToQueryString:person];
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableString *)personToQueryString:(Person *)person {
    NSMutableString *body = [NSMutableString string];
    if (person.name) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[name]=%@", person.name];
    }
    if (person.email) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[email]=%@", person.email];
    }
    if (person.external_identifier) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[external_identifier]=%@", person.external_identifier];
    }
    if (person.created_at) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[properties][created_at]=%@", person.created_at];
    }
    if (person.avatar_url) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[properties][avatar_url]=%@", person.avatar_url];
    }
    if (person.twitter) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[properties][twitter]=%@", person.twitter];
    }    if (person.is_paying) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[properties][is_paying]=%@", person.is_paying];
    }
    if (person.account_level) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[properties][account_level]=%@", person.account_level];
    }
    if (person.account_level_name) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[properties][account_level_name]=%@", person.account_level_name];
    }
    if (person.url) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"person[properties][url]=%@", person.url];
    }
    return body;
}

@end

@implementation Person
@synthesize email,name,external_identifier,created_at,avatar_url,twitter,is_paying,account_level,account_level_name,url;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

@end

@implementation Event
@synthesize name, magnitude, note, links, person;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

@end

@implementation ActionLink
@synthesize name, href;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

@end

@implementation Message
@synthesize body, subject, person;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

@end
