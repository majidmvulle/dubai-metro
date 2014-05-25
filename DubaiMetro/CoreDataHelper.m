//
//  CoreDataHelper.m
//  CoreDataSpot
//
//  Created by Majid Mvulle on 8/21/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "CoreDataHelper.h"

#define MANAGED_DOCUMENT_NAME @"MetroStations.db"

@implementation CoreDataHelper

@synthesize managedDocumentFileName = _managedDocumentFileName;
@synthesize managedDocument = _managedDocument;

+ (CoreDataHelper *)sharedManagedDocument
{
        //----- It's a singleton --------------------------------------------
    static dispatch_once_t coreDataHelperDispatcher = 0;
    __strong static CoreDataHelper *_sharedManagedDocument = nil;

    dispatch_once(&coreDataHelperDispatcher, ^{
        _sharedManagedDocument = [[self alloc] init];
    });
    
    return _sharedManagedDocument;
}

- (NSFileManager *)fileManager
{
    if(!_fileManager) _fileManager = [[NSFileManager alloc] init];

    return _fileManager;
}

+ (NSURL *)documentDirectoryURL
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    NSURL *documentsDirectoryURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                        inDomains:NSUserDomainMask] lastObject];
        //Delete old version
    if([fileManager fileExistsAtPath:[[documentsDirectoryURL URLByAppendingPathComponent:@"/DubaiMetro"] path]]){
            //we don't care about the error
        [fileManager removeItemAtURL:[documentsDirectoryURL URLByAppendingPathComponent:@"/DubaiMetro"] error:nil];
    }

    NSString *pathComponent = [@"/CoreData/MetroStations/" stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];

    BOOL isDir = NO;

    NSURL *storageURL = [documentsDirectoryURL URLByAppendingPathComponent:pathComponent isDirectory:YES];


    if([fileManager fileExistsAtPath:[storageURL path] isDirectory:&isDir]){
        if(isDir){
            return storageURL;
        }
    }

    NSError *error = nil;

    [fileManager createDirectoryAtPath:[storageURL path] withIntermediateDirectories:YES attributes:nil error:&error];

    if(!error)
        return storageURL;

    return nil;
}

- (UIManagedDocument *)managedDocument
{
    if (!_managedDocument) {
        _managedDocument = [[UIManagedDocument alloc] initWithFileURL:[[CoreDataHelper documentDirectoryURL] URLByAppendingPathComponent:self.managedDocumentFileName]];
    }

    return _managedDocument;
}

- (void)setManagedDocument:(UIManagedDocument *)managedDocument
{
    _managedDocument = managedDocument;
    _managedObjectContext = _managedDocument.managedObjectContext;
}

- (NSString *)managedDocumentFileName
{
    if(!_managedDocumentFileName) _managedDocumentFileName = MANAGED_DOCUMENT_NAME;

    return _managedDocumentFileName;
}

- (void)setManagedDocumentFileName:(NSString *)managedDocumentFileName
{
    if(_managedDocumentFileName != managedDocumentFileName){
        _managedDocumentFileName = managedDocumentFileName;
        self.managedDocument = nil; //reset the document
    }
}

- (void)openManagedDocumentUsingBlock:(void (^)(BOOL success))block
{
    CoreDataHelper *coreDataHelper = [CoreDataHelper sharedManagedDocument];

    if (![coreDataHelper.fileManager fileExistsAtPath:[coreDataHelper.managedDocument.fileURL path]]) {
            //Create it
        [coreDataHelper.managedDocument saveToURL:coreDataHelper.managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:block];

    } else if (coreDataHelper.managedDocument.documentState == UIDocumentStateClosed) {
            //Open it
        [coreDataHelper.managedDocument openWithCompletionHandler:block];

    } else {
            //Use it
        BOOL success = YES;
        block(success);
    }
}

- (void)performWithDocument:(OnDocumentReady)onDocumentReady
{
    void (^OnDocumentDidLoad)(BOOL) = ^(BOOL success) {
        onDocumentReady(self.managedDocument);
    };

    if (![self.fileManager fileExistsAtPath:[self.managedDocument.fileURL path]]){
        [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating  completionHandler:OnDocumentDidLoad];

    } else if (self.managedDocument.documentState == UIDocumentStateClosed) {
        [self.managedDocument openWithCompletionHandler:OnDocumentDidLoad];

    } else if (self.managedDocument.documentState == UIDocumentStateNormal) {
        OnDocumentDidLoad(YES);

    }
}

@end