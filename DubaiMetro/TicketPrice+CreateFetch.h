//
//  TicketPrice+CreateFetch.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/10/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TicketPrice.h"

@interface TicketPrice (CreateFetch)
+ (TicketPrice *)ticketPriceWithInfo:(NSDictionary *)ticketPriceDictionary
              inManagedObjectContext:(NSManagedObjectContext *)context;
+ (TicketPrice *)fetchTicketPricesinManagedObjectContext:(NSManagedObjectContext *)context;
@end
