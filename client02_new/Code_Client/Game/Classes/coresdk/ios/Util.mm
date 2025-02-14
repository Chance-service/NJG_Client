
extern "C" {
    void coresdk_util_openbrowser(const char *pszUrl)
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:pszUrl]];
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:NULL];
        }else{
            UIApplication *application = [UIApplication sharedApplication];
            [application openURL:url options:@{} completionHandler:nil];
        }
     }
    
    const char* coresdk_util_get_bundle_identifier()
    {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        return [bundleIdentifier UTF8String];
    }
}

