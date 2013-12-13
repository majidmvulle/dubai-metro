//
//  TicketPrice+CreateFetch.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/10/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TicketPrice+CreateFetch.h"

@implementation TicketPrice (CreateFetch)
+ (TicketPrice *)ticketPriceWithInfo:(NSDictionary *)ticketPriceDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    TicketPrice *ticketPrice = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TicketPrice"];
    request.predicate = nil;

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ //no record found
        ticketPrice = [NSEntityDescription insertNewObjectForEntityForName:@"TicketPrice" inManagedObjectContext:context];
        
        ticketPrice.t0 = ticketPriceDictionary[@"t0"];
        ticketPrice.t1 = ticketPriceDictionary[@"t1"];
        ticketPrice.t2 = ticketPriceDictionary[@"t2"];
        ticketPrice.t3 = ticketPriceDictionary[@"t3"];
    }else{
        ticketPrice = [matches lastObject];
    }

    return ticketPrice;
}

+ (TicketPrice *)fetchTicketPricesinManagedObjectContext:(NSManagedObjectContext *)context
{
    TicketPrice *ticketPrice = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TicketPrice"];
    request.predicate = nil;

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ![matches count]){
            //handle error
    }else{
        ticketPrice = [matches lastObject];
    }

    return ticketPrice;
}

@end