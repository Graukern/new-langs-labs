#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 2) {
            fprintf(stderr, "Использование: client URL\n");
            return 1;
        }

        NSString *urlString = [NSString stringWithUTF8String:argv[1]];
        NSURL *url = [NSURL URLWithString:urlString];
        if (url == nil) {
            fprintf(stderr, "Некорректный URL\n");
            return 1;
        }

        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        if (data == nil) {
            fprintf(stderr, "Ошибка запроса: %s\n",
                    [[error localizedDescription] UTF8String]);
            return 1;
        }

        NSString *text = [[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding];
        if (text == nil) {
            fprintf(stderr, "Ответ не является текстом UTF-8\n");
            return 1;
        }

        printf("%s", [text UTF8String]);
    }

    return 0;
}
