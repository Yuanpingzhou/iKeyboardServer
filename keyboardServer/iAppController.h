#import <Cocoa/Cocoa.h>

#define USER_DEFAULT_BARCODE_S @"user.default.barcode.store"
#define USER_DEFAULT_MSR_S     @"user.default.msr.store"

@class AsyncSocket;

@interface AppController : NSObject<NSTextFieldDelegate>
{
	AsyncSocket *listenSocket;
    AsyncSocket *acceptSocket;
	NSMutableArray *connectedSockets;
	
	BOOL isRunning;
	
    
    IBOutlet NSTabView *tabView ;
    
    IBOutlet NSTabViewItem *scanItem ;
    IBOutlet NSTabViewItem *barcodeItem ;
    IBOutlet NSTabViewItem *msrItem ;
    IBOutlet NSTabViewItem *mfgItem ; 
    IBOutlet NSButton *settingbutton ;
    IBOutlet NSButton *brConfigBtn ;
    IBOutlet NSButton *msrConfigBtn ; 
    
    
    IBOutlet NSTextView * logView;
    IBOutlet NSTextField *portField;
    IBOutlet NSButton *startStopButton;
    IBOutlet NSButton * ConnectButton;
    IBOutlet NSButton *DisConnectButton;
    IBOutlet NSButton * scanButton ;
    IBOutlet NSButton *swipButton ;
    
    //Barcode setting and storage.
	IBOutlet NSArrayController	*mybarcodeContentArray;
    IBOutlet NSTableView *barcodetableView ; 
    IBOutlet NSTextField *barcodeField;
    //MSR setting and storage.
    IBOutlet NSArrayController *myMSRContentArray ;
    IBOutlet NSTableView *msrTableView ;
    IBOutlet NSTextField *msrField ; 
    
    //MFG setting and storage.
    IBOutlet NSTextField *accessoryField ;
    IBOutlet NSTextField *ManufacturerField ;
    IBOutlet NSTextField *ModelNumberField ;
    IBOutlet NSTextField *SerialNumberField ;
    IBOutlet NSTextField *FirmwareRevField ;
    IBOutlet NSTextField *HardwareRevField ;
    IBOutlet NSTextField *SDKRevField ; 
    
}

//@property(nonatomic,retain) IBOutlet NSTextField * portField;
//
//@property(nonatomic,retain) IBOutlet NSButton *DisConnectButton;
//
//@property(nonatomic,retain) NSButton *ConnectButton ;


- (IBAction)startStop:(id)sender;

- (IBAction)scanAction:(id)sender ;

- (IBAction)SwipeCardAction:(id)sender ;

- (IBAction)NotificationConnectAction:(id)sender ;

- (IBAction)NotificationDisConnectAction:(id)sender ;

- (IBAction)setBarcodeData:(id)sender ;

- (IBAction)setMsrData:(id)sender ;


- (IBAction)settingAction:(id)sender ; 

//Barcode setting.
- (void)updateClientBarcodelist:(NSString*)barcodelist ; 
- (IBAction)AddnewBarContentcode:(id)sender ;
- (IBAction)RemoveBarContentcode:(id)sender ;
- (IBAction)barcodeConfigAction:(id)sender ;
//msr setting
- (void)updateClientMSRList:(NSString*)msrList;
- (IBAction)AddnewMSRContent:(id)sender ;
- (IBAction)RemoveMSRContent:(id)sender ;
- (IBAction)msrConfigAction:(id)sender ;
//MFG configure.

- (IBAction)setAccessoryname:(id)sender;

- (IBAction)setManufacture:(id)sender ;

- (IBAction)setModelNumber:(id)sender ;

- (IBAction)setSerialNumber:(id)sender ;

- (IBAction)setFirmwareRev:(id)sender ;

-(IBAction)setHardwareRev:(id)sender ;

- (IBAction)setSDKRev:(id)sender ;


- (IBAction)configureMFG:(id)sender ; 

@end
