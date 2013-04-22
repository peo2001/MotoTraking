//
//  RemoteConnector.m
//  iVixiV
//
//  Created by Eugenio Pompei on 22/10/12.
//  Copyright (c) 2012 xTreme Software. All rights reserved.
//

#import "mtxAppDelegate.h"
#import "RemoteConnector.h"
#import "mtxSessionManager.h"

#import "RemoteConnectorParameters.h"

@implementation RemoteConnector

//@synthesize message;


- (id) init
{
    self = [super init];
    if (self != nil)
    {
        MainAppDelegate.connectionError = false;
        _parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        _dataMode = @"msg";
        mStandardBodyPrepared = false;
    }
    return self;
}

+ (NSInteger) nextCall:(NSInteger)increment{
    static NSInteger numRC;
    numRC = numRC + increment;
    return numRC;
}

- (void) prepareStandardBody{
    
    if (!mStandardBodyPrepared) {
        
        [_parameters setObject:MainAppDelegate.mainSessionManager.idRuoloInGara forKey:@"IdRuoloInGara"];
        [_parameters setObject:MainAppDelegate.mainSessionManager.codiceAttivazione forKey:@"CodiceAttivazione"];
        
    }
}

- (void) rc_:(NSString *) virtualDir{
    if ([RemoteConnector nextCall:0] == 0 && ! MainAppDelegate.connectionError)
    {
        
        [self prepareStandardBody];
        
        NSString *url = [NSString stringWithFormat:@"%@%@%@", remoteServerURL, virtualDir, webServiceExtension];
        
        [RemoteConnector nextCall:1];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        dataWebService = [NSMutableData data];
        
    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]] ;


        [request setHTTPMethod:@"POST"];

        NSMutableData *bodyData = [[NSMutableData alloc] init];
        
        // Eugenio 12 feb 2012
        // andrebbe sostituita da un dictionary fields / values
        NSArray *keys = [_parameters allKeys];
        for (NSString *aKey in keys) {
            // crea il valore e lo codifica URL
            NSString *sStr = [NSString stringWithString: [_parameters objectForKey:aKey]];
            sStr = [[sStr stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];

            // Crea il capo nella forma "Campo=ValoreCodificato&"
            sStr = [NSString stringWithFormat:@"%@=%@&",aKey, sStr];
            //Aggiunge al data del Body la stringa con campovalore
            [bodyData appendData:[sStr dataUsingEncoding:NSASCIIStringEncoding]];

        }

        // Aggiunge la "firma"
        [bodyData appendData:[@"BuildedBy=xTremeSoftware" dataUsingEncoding:NSASCIIStringEncoding]];
        
        NSLog(@"Calling \n%@?%@", url, [[NSString alloc] initWithData:bodyData encoding:NSASCIIStringEncoding]);
        

        [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:bodyData];


        NSURLConnection *myConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        [myConnection start];

        _parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
        
}
    
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential = [NSURLCredential credentialWithUser:userName
                                                   password:password
                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [dataWebService setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSLog(@"... data receiving ...");
    [dataWebService appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    _message = [[NSString alloc] initWithData:dataWebService encoding:NSUTF8StringEncoding];
    
    NSLog(@"XML Received \n\n%@\n", _message);
    
    if ([_dataMode isEqualToString:@"msg"]) {
        [self.delegate remoteConnector:self didMessageReceived:_message];
    } else
    {
        [self.delegate remoteConnector:self didDataReceived:dataWebService];
    }
    
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [RemoteConnector nextCall:-1];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Eror during connection: %@", [error description]);
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Problemi di connessione"];
    [alert setMessage:@"La connessione ai server non è al momento disponibile."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Ok"];
    [alert show];
    
    MainAppDelegate.connectionError = true;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [RemoteConnector nextCall:-1];
}
@end
