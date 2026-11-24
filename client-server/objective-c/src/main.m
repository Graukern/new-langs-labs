#import <Foundation/Foundation.h>

static int report_error(NSString *message) {
    fprintf(stderr, "%s\n", [message UTF8String]);
    return 1;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 3) {
            return report_error(@"Использование: client URL КОРЗИНА.json");
        }

        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:argv[1]]];
        if (url == nil || [url host] == nil ||
            (![[url scheme] isEqualToString:@"http"] && ![[url scheme] isEqualToString:@"https"])) {
            return report_error(@"Некорректный HTTP URL.");
        }

        NSString *path = [NSString stringWithUTF8String:argv[2]];
        NSData *basket = [NSData dataWithContentsOfFile:path];
        if (basket == nil) {
            return report_error([NSString stringWithFormat:@"Не удалось прочитать %@", path]);
        }

        NSMutableURLRequest *request =
            [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                               timeoutInterval:10];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:basket];

        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *body = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        if (body == nil) {
            return report_error([NSString stringWithFormat:@"Ошибка запроса: %@",
                                 error ? [error localizedDescription] : @"ответ не получен"]);
        }

        if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
            return report_error(@"Сервер не прислал HTTP-ответ.");
        }
        NSInteger status = [(NSHTTPURLResponse *)response statusCode];
        if (status < 200 || status >= 300) {
            return report_error([NSString stringWithFormat:@"Сервер вернул HTTP %ld.", (long)status]);
        }

        id json = [NSJSONSerialization JSONObjectWithData:body options:0 error:&error];
        id total = [json isKindOfClass:[NSDictionary class]] ? [json objectForKey:@"total_kopecks"] : nil;
        if (![total isKindOfClass:[NSNumber class]]) {
            return report_error(@"В JSON-ответе отсутствует числовое поле total_kopecks.");
        }
        NSString *amount = [total stringValue];
        NSCharacterSet *non_digits =
            [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([amount length] == 0 || [amount rangeOfCharacterFromSet:non_digits].location != NSNotFound) {
            return report_error(@"Некорректная стоимость в JSON-ответе.");
        }

        printf("Итого: %s коп.\n", [amount UTF8String]);
    }
    return 0;
}
