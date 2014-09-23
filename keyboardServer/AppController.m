#import "AppController.h"
#import "AsyncSocket.h"

#define WELCOME_MSG  0
#define ECHO_MSG     1

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface AppController (PrivateAPI)
- (void)logError:(NSString *)msg;
- (void)logInfo:(NSString *)msg;
- (void)logMessage:(NSString *)msg;
@end


@implementation AppController

//@synthesize DisConnectButton = DisconectButton ;

- (id)init
{
    if(self = [super init])
    {
        listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
        acceptSocket = nil;//[[AsyncSocket alloc] init] ;
        connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        // [portField intValue] = 6000;
        //it is running or not.
        isRunning = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    [logView setString:@""];
    [ConnectButton setEnabled:YES] ;
    [DisConnectButton setEnabled:NO] ;
    portField.stringValue  = @"6000";
    
    [scanButton setEnabled:NO] ;
    [swipButton setEnabled:NO] ;
    
    //    NSTableColumn *firstNameColumn = [barcodetableView tableColumnWithIdentifier:@"barcode"];
    //	[firstNameColumn bind:@"value" toObject:mybarcodeContentArray withKeyPath:@"arrangedObjects.barcode" options:nil];
    
    //for barcode setting listview.
    [self startStop:nil] ;
    
    [settingbutton setEnabled:NO] ;
    
    NSArray *barcodearray = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_BARCODE_S];
    [mybarcodeContentArray removeObjects:barcodearray] ;
    for (NSDictionary *dict in barcodearray) {
        [mybarcodeContentArray addObject: dict];
    }
    
    NSArray *msrarray = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_MSR_S] ;
    [myMSRContentArray removeObjects:msrarray] ;
    for (NSDictionary *dict in msrarray) {
        [myMSRContentArray addObject:dict] ;
    }
    
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Ready");
    
    // Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
    [listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    //close all the connect with client.
    NSString *sendstring = @"Command03:" ;
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    // Stop accepting connections
    [listenSocket disconnect];
    // Stop any client connections
    int i;
    for(i = 0; i < [connectedSockets count]; i++)
    {
        // Call disconnect on the socket,
        // which will invoke the onSocketDidDisconnect: method,
        // which will remove the socket from the list.
        
        [[connectedSockets objectAtIndex:i] disconnect];
    }
    
    [self logInfo:@"Stopped Captuvo Emulator Controller Server"];
    isRunning = false;
    
    [portField setEnabled:YES];
    [startStopButton setTitle:@"Start Server"];
    
    
    
    NSLog(@"Mac OSX application closed") ;
}
- (void)scrollToBottom
{
    NSScrollView *scrollView = [logView enclosingScrollView];
    NSPoint newScrollOrigin;
    
    if ([[scrollView documentView] isFlipped])
        newScrollOrigin = NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]));
    else
        newScrollOrigin = NSMakePoint(0.0, 0.0);
    
    [[scrollView documentView] scrollPoint:newScrollOrigin];
}

- (void)logError:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
    [as autorelease];
    
    [[logView textStorage] appendAttributedString:as];
    [self scrollToBottom];
}

- (void)logInfo:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[NSColor purpleColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
    [as autorelease];
    
    [[logView textStorage] appendAttributedString:as];
    [self scrollToBottom];
}

- (void)logMessage:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
    [as autorelease];
    
    [[logView textStorage] appendAttributedString:as];
    [self scrollToBottom];
}

- (IBAction)startStop:(id)sender
{
    if(!isRunning)
    {
        NSString *sendstring = @"Command03:" ;
        NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
        
        if (acceptSocket)
        {
            [acceptSocket writeData:data withTimeout:-1 tag:1] ;
        }
        
        int port = [portField intValue];
        
        if(port < 0 || port > 65535)
        {
            port = 0;
        }
        [listenSocket disconnect] ;
        
        for(int i = 0; i < [connectedSockets count]; i++)
        {
            // Call disconnect on the socket,
            // which will invoke the onSocketDidDisconnect: method,
            // which will remove the socket from the list.
            [[connectedSockets objectAtIndex:i] disconnect];
        }
        
        
        NSError *error = nil;
        if(![listenSocket acceptOnPort:port error:&error])
        {
            [self logError:FORMAT(@"Error starting server: %@", error)];
            return;
        }
        
        [self logInfo:FORMAT(@"Captuvo Emulator Controller server started on port %hu", [listenSocket localPort])];
        isRunning = YES;
        
        [portField setEnabled:NO];
        [startStopButton setTitle:@"Stop Server"];
        
    }
    else
    {
        NSString *sendstring = @"Command03:" ;
        NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
        
        if (acceptSocket)
        {
            [acceptSocket writeData:data withTimeout:-1 tag:1] ;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Stop accepting connections
            [listenSocket disconnect];
            // Stop any client connections
            int i;
            for(i = 0; i < [connectedSockets count]; i++)
            {
                // Call disconnect on the socket,
                // which will invoke the onSocketDidDisconnect: method,
                // which will remove the socket from the list.
                
                [[connectedSockets objectAtIndex:i] disconnect];
            }
            
            [self logInfo:@"Stopped Captuvo Emulator Controller Server"];
            isRunning = false;
            
            [portField setEnabled:YES];
            [startStopButton setTitle:@"Start Server"];
            
        });
        
    }
}

- (IBAction)scanAction:(id)sender
{
    //    NSString *sendstring = @"Command10:123456789" ;
    //    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    //
    //    if (acceptSocket)
    //    {
    //        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    //    }
    
    NSString *sendstring = @"Command00:" ;
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    
}

- (IBAction)SwipeCardAction:(id)sender
{
    //        NSString *sendstring = @"Command00:" ;
    //        NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    //
    //        if (acceptSocket)
    //        {
    //          [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    //        }
    
    NSString *sendstring = @"Command01:" ;
    
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    
}

- (IBAction)NotificationConnectAction:(id)sender
{
    [DisConnectButton  setEnabled:YES];
    [ConnectButton  setEnabled:NO];
    [settingbutton setEnabled:YES] ;
    NSString *sendstring = @"Command02:" ;
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    
}

- (IBAction)NotificationDisConnectAction:(id)sender
{
    [ConnectButton  setEnabled:YES];
    [DisConnectButton setEnabled:NO] ;
    [settingbutton setEnabled:NO] ;
    
    
    NSString *sendstring = @"Command03:" ;
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    
}

- (IBAction)setAccessoryname:(id)sender
{
    NSString *sendstring =[NSString stringWithFormat:@"Command04:%@",sender] ;
    
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}

- (IBAction)setManufacture:(id)sender
{
    NSString *sendstring =[NSString stringWithFormat:@"Command05:%@",sender] ;
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}

- (IBAction)setModelNumber:(id)sender
{
    NSString *sendstring =[NSString stringWithFormat:@"Command06:%@",sender];
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}

- (IBAction)setSerialNumber:(id)sender
{
    NSString *sendstring =[NSString stringWithFormat:@"Command07:%@",sender];
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}

- (IBAction)setFirmwareRev:(id)sender
{
    
    NSString *sendstring =[NSString stringWithFormat:@"Command08:%@",sender];
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}

-(IBAction)setHardwareRev:(id)sender
{
    NSString *sendstring =[NSString stringWithFormat:@"Command09:%@",sender];
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}

-(IBAction)setSDKRev:(id)sender
{
    NSString *sendstring =[NSString stringWithFormat:@"Command10:%@",sender];
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}


- (IBAction)setBarcodeData:(id)sender
{
    NSString *sendstring = @"Command11:123456789" ;
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}

- (IBAction)setMsrData:(id)sender
{
    NSString *sendstring = @"Command12:0000123456789" ;
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
}


- (IBAction)settingAction:(id)sender
{
    NSMutableArray*existbarArray = (NSMutableArray*)[mybarcodeContentArray arrangedObjects] ;
    
    NSMutableArray *existMsrobjsArray = (NSMutableArray*)[myMSRContentArray arrangedObjects] ;
    
    if(([existbarArray count] <=0) &&  ([existMsrobjsArray count] <=0))
    {
        NSAlert *alert=[NSAlert alertWithMessageText:@"warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"barcode list or msr list is empty currently, you should input some data."];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:nil];
        return;
        
    }
    
    [settingbutton setEnabled:NO] ;
    
    [self barcodeConfigAction:nil] ;
    [self msrConfigAction:nil] ;
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    // if (!acceptSocket) {
    acceptSocket = [newSocket retain] ;
    NSLog(@"did accept new socket") ;
    // }
    [connectedSockets addObject:newSocket];
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"wants runloop for new socket.");
    return [NSRunLoop currentRunLoop];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [self logInfo:FORMAT(@"Accepted client %@:%hu", host, port)];
    
    //	NSString *welcomeMsg = @"Welcome to the AsyncSocket Captuvo Simulator Controller\r\n";
    //	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    //	[sock writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    [self NotificationConnectAction:nil] ;
    
    
    NSLog(@"did connect to host");
    if (acceptSocket)
    {
        [acceptSocket readDataWithTimeout:-1 tag:1] ;
        
    }
    
    // We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
    // If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
    // queue another read if tag != WELCOME_MSG.
}

//- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
//{
//	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
//}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    //	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
    //	if(msg)
    //	{
    //		[self logMessage:msg];
    //	}
    //	else
    //	{
    //		[self logError:@"Error converting received data into UTF-8 String"];
    //	}
    //
    //	// Even if we were unable to write the incoming data to the log,
    //	// we're still going to echo it back to the client.
    //	[sock writeData:data withTimeout:-1 tag:ECHO_MSG];
    
    NSLog(@"did read data");
    NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"message is: \n%@",message);
    
    [self logInfo:message] ;
    //    [acceptSocket writeData:data withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    [self logInfo:FORMAT(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort])];
}


- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"message did write");
    if (acceptSocket)
    {
        [acceptSocket readDataWithTimeout:-1 tag:1];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    
    [DisConnectButton  setEnabled:NO];
    [ConnectButton  setEnabled:YES];
    [scanButton setEnabled:NO] ;
    [swipButton setEnabled:NO] ;
    [settingbutton setEnabled:NO] ;
    //    NSInteger indexofitem = [tabView indexOfTabViewItem:barcodeItem] ;
    //    if (indexofitem!=NSNotFound) {
    //        [tabView removeTabViewItem:barcodeItem] ;
    //    }
    //
    //    indexofitem = [tabView indexOfTabViewItem:msrItem] ;
    //    if (indexofitem!=NSNotFound) {
    //        [tabView removeTabViewItem:msrItem] ;
    //    }
    
    NSLog(@"socket did disconnect");
    [acceptSocket release];
    acceptSocket=nil;
    
}

#pragma mark ---
#pragma barcode data setting.

- (void)updateClientBarcodelist:(NSString*)barcodelist
{
    //barcodelist separate by '--';
    NSString *sendstring = nil;
    //    if ([barcodelist length]==0) {
    //       sendstring = [NSString stringWithFormat:@"Command11:"];
    //    }else{
    //       sendstring =  [NSString stringWithFormat:@"Command11:%@",barcodelist];
    sendstring =  [NSString stringWithFormat:@"%@",barcodelist];
    //    }
    
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    
}

-(void)alertEnded:(NSAlert *)alert code:(int)choice context:(void *)v{
    if (choice==NSAlertDefaultReturn) {
        NSLog(@"----------------0");
    } else if(choice==NSAlertAlternateReturn){
        NSLog(@"----------------1");
    }
}
- (IBAction)AddnewBarContentcode:(id)sender
{
    NSMutableArray *existobjsArray = (NSMutableArray*)[mybarcodeContentArray arrangedObjects] ;
    //add complete should clear the barcodeField value.
    NSLog(@"%@",existobjsArray) ;
    
    NSString *barcodevalue = barcodeField.stringValue ;
    if (barcodevalue==nil||[barcodevalue length]==0) {
        NSAlert *alert=[NSAlert alertWithMessageText:@"Add barcode warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You should input content into barcode field to add barcode list."];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:nil];
        return ;
    }
    
    NSDictionary *addDictionary = [NSDictionary dictionaryWithObject:barcodevalue forKey:@"barcode"] ;
    
    if([existobjsArray containsObject:addDictionary]){
        NSAlert *alert=[NSAlert alertWithMessageText:@"Add barcode warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You input barcode duplicate, please add a new different barcode content."];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:nil];
        
        return ;
    }
    [mybarcodeContentArray addObject:addDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:existobjsArray forKey:USER_DEFAULT_BARCODE_S] ;
    NSString *sendstring = nil;
    //    if ([barcodelist length]==0) {
    //       sendstring = [NSString stringWithFormat:@"Command11:"];
    //    }else{
    //       sendstring =  [NSString stringWithFormat:@"Command11:%@",barcodelist];
    sendstring =  [NSString stringWithFormat:@"%@",barcodevalue];
    //    }
    
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    
    [self barcodeConfigAction:nil] ;
    [barcodeField setStringValue:@""] ;
    
    
    //    NSString *barcodelist = nil;
    //    for (NSDictionary *subdict in existobjsArray) {
    //        if (barcodelist==nil||[barcodelist length]==0) {
    //            barcodelist = [subdict objectForKey:@"barcode"] ;
    //        }else{
    //            barcodelist = [NSString stringWithFormat:@"%@--%@",barcodelist,[subdict objectForKey:@"barcode"]];
    //        }
    //    }
    //    //send to client to update the current newest barcode list.
    //    [self updateClientBarcodelist:barcodelist] ;
    
}
- (IBAction)RemoveBarContentcode:(id)sender
{
    int selectindex =  barcodetableView.selectedRow  ;
    if (selectindex>=0) {
        [mybarcodeContentArray removeObjectAtArrangedObjectIndex:selectindex] ;
        NSMutableArray*existArray = (NSMutableArray*)[mybarcodeContentArray arrangedObjects] ;
        [[NSUserDefaults standardUserDefaults] setObject:existArray forKey:USER_DEFAULT_BARCODE_S] ;
        [self barcodeConfigAction:nil] ;
    }else{
        NSAlert *alert=[NSAlert alertWithMessageText:@"Remove barcode warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"barcode list is empty currently, you can not do remove action."];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:nil];
    }
    
}

- (IBAction)barcodeConfigAction:(id)sender
{
    NSMutableArray*existArray = (NSMutableArray*)[mybarcodeContentArray arrangedObjects] ;
    NSString *barcodelist = nil;
    for (NSDictionary *subdict in existArray) {
        if (barcodelist==nil||[barcodelist length]==0) {
            barcodelist = [subdict objectForKey:@"barcode"] ;
        }else{
            barcodelist = [NSString stringWithFormat:@"%@--%@",barcodelist,[subdict objectForKey:@"barcode"]];
        }
    }
    //send to client to update the current newest barcode list.
    //[self updateClientBarcodelist:barcodelist] ;
    
    [scanButton setEnabled:YES] ;
}

#pragma mark ----
#pragma msr data setting.
- (void)updateClientMSRList:(NSString*)msrList
{
    //barcodelist separate by '--';
    NSString *sendstring = nil;
    if ([msrList length]==0) {
        sendstring = [NSString stringWithFormat:@"Command12:"];
    }else{
        sendstring =  [NSString stringWithFormat:@"Command12:%@",msrList];
    }
    
    NSData *data = [sendstring dataUsingEncoding:NSUTF8StringEncoding] ;
    
    if (acceptSocket)
    {
        [acceptSocket writeData:data withTimeout:-1 tag:1] ;
    }
    
}
- (IBAction)AddnewMSRContent:(id)sender
{
    NSMutableArray *existobjsArray = (NSMutableArray*)[myMSRContentArray arrangedObjects] ;
    //add complete should clear the barcodeField value.
    NSLog(@"%@",existobjsArray) ;
    
    NSString *msrValue = msrField.stringValue ;
    if (msrValue==nil||[msrValue length]==0) {
        NSAlert *alert=[NSAlert alertWithMessageText:@"Add msr content warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You should input content into msr field to add msr list."];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:nil];
        
        return ;
    }
    NSDictionary *addDictionary = [NSDictionary dictionaryWithObject:msrValue forKey:@"msr"] ;
    if([existobjsArray containsObject:addDictionary]){
        NSAlert *alert=[NSAlert alertWithMessageText:@"Add msr warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You input msr duplicate, please add a new different msr content."];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:nil];
        return ;
    }
    [myMSRContentArray addObject:addDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:existobjsArray forKey:USER_DEFAULT_MSR_S] ;
    //add complete should clear the barcodeField value.
    [msrField setStringValue:@""] ;
    
    [self msrConfigAction:nil] ;
    //    NSString *msrlist = nil;
    //    for (NSDictionary *subdict in existobjsArray) {
    //        if (msrlist==nil||[msrlist length]==0) {
    //            msrlist = [subdict objectForKey:@"msr"] ;
    //        }else{
    //            msrlist = [NSString stringWithFormat:@"%@--%@",msrlist,
    //                           [subdict objectForKey:@"msr"]];
    //        }
    //    }
    //    //send to client to update the current newest barcode list.
    //    [self updateClientMSRList:msrlist] ;
    
}

- (IBAction)RemoveMSRContent:(id)sender
{
    int selectindex =  msrTableView.selectedRow  ;
    if (selectindex>=0) {
        [myMSRContentArray removeObjectAtArrangedObjectIndex:selectindex] ;
        NSMutableArray *existobjsArray = (NSMutableArray*)[myMSRContentArray arrangedObjects] ;
        [[NSUserDefaults standardUserDefaults] setObject:existobjsArray forKey:USER_DEFAULT_MSR_S] ;
        
        [self msrConfigAction:nil] ;
    }else{
        NSAlert *alert=[NSAlert alertWithMessageText:@"Remove msr warning" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"msr list is empty currently, you can not do remove action."];
        
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:nil];
        
    }
    
    
}
- (IBAction)msrConfigAction:(id)sender
{
    NSMutableArray *existobjsArray = (NSMutableArray*)[myMSRContentArray arrangedObjects] ;
    NSString *msrlist = nil;
    for (NSDictionary *subdict in existobjsArray) {
        if (msrlist==nil||[msrlist length]==0) {
            msrlist = [subdict objectForKey:@"msr"] ;
        }else{
            msrlist = [NSString stringWithFormat:@"%@--%@",msrlist,
                       [subdict objectForKey:@"msr"]];
        }
    }
    //send to client to update the current newest barcode list.
    [self updateClientMSRList:msrlist] ;
    
    [swipButton setEnabled:YES] ;
}
#pragma mark ----
#pragma configuration Manufacturer.
- (IBAction)configureMFG:(id)sender
{
    [self setAccessoryname:accessoryField.stringValue] ;
    [self setManufacture:ManufacturerField.stringValue] ;
    [self setModelNumber:ModelNumberField.stringValue] ;
    [self setSerialNumber:SerialNumberField.stringValue] ;
    [self setFirmwareRev:FirmwareRevField.stringValue] ;
    [self setHardwareRev:HardwareRevField.stringValue] ;
    [self setSDKRev:SDKRevField.stringValue] ;
    
}



@end
