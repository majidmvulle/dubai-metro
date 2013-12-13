//
//  Journey.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/18/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "Journey.h"
#import "MetroStation+CreateFetch.h"
#import "TrainTime.h"
#import "TrainTiming+Create.h"
#import "MetroStationLine+CreateFetch.h"
#import "MetroStationOrder+CreateFetch.h"
#import "TicketPrice+CreateFetch.h"

#pragma mark - JourneyInterchange implementation
@implementation JourneyInterchange
@end

#pragma mark - JourneyRoute implementation
@implementation JourneyRoute

- (NSMutableArray *)interchanges
{
    if(!_interchanges) _interchanges = [[NSMutableArray alloc] init];
    return _interchanges;
}

- (NSMutableSet *)stationZoneNumbers
{
    if(!_stationZoneNumbers) _stationZoneNumbers = [NSMutableSet set];
    
    return _stationZoneNumbers;
}

@end

#pragma mark - Journey implementation
@interface Journey()
@property (nonatomic, strong) MetroStation *fromStation;
@property (nonatomic, strong) MetroStation *toStation;
@property (nonatomic, strong) NSMutableArray *visitedStations;
@property (nonatomic, strong) NSMutableArray *visitedInterchanges;
@property (nonatomic, strong) NSMutableArray *journeyRoutes;
@property (nonatomic, readwrite) float ticketPrice;
@end

@implementation Journey

- (id)initFromStation:(MetroStation *)fromStation toStation:(MetroStation *)toStation
{
    self = [self init];

    if(self){
        self.fromStation = fromStation;
        self.toStation = toStation;
    }

    return self;
}

- (NSMutableArray *)journeyRoutes
{
    if(!_journeyRoutes) _journeyRoutes = [[NSMutableArray alloc] init];

    return _journeyRoutes;
}

- (NSMutableArray *)visitedInterchanges
{
    if(!_visitedInterchanges) _visitedInterchanges = [NSMutableArray array];
    return _visitedInterchanges;
}

- (NSMutableArray *)visitedStations
{
    if(!_visitedStations) _visitedStations = [NSMutableArray arrayWithObject:self.fromStation];
    return _visitedStations;
}

- (float)ticketPrice:(JourneyRoute *)journeyRoute
{
    TicketPrice *ticketPrice = [TicketPrice fetchTicketPricesinManagedObjectContext:journeyRoute.fromStation.managedObjectContext];

    float kmCovered = 0.0;
    float zonesCovered = 0.0;
    float distanceBetweenStations = 1.5; //km
    float price = 0.0;

    kmCovered = (journeyRoute.numberOfStationsToTravel * distanceBetweenStations);
    zonesCovered = [journeyRoute.stationZoneNumbers count];

    if(zonesCovered == 2.f){ //starts in one zone, ends in neighbouring zone (T2)
        price = [ticketPrice.t2 floatValue];

    }else if(zonesCovered > 2.f){ //exceeds two zones (T3)
        price = [ticketPrice.t3 floatValue];

    }else{ //same zone
        if(kmCovered < 3.f){ //Less than 3km (T0):  (or equal to ??)
            price = [ticketPrice.t0 floatValue];

        }else{ //Starts and ends in the same zone (T1)
            price = [ticketPrice.t1 floatValue];

        }
    }

    return price;
}

- (NSArray *)findJourneyRoutes
{
        //We are on the same lines
    if([self.fromStation.stationLines intersectsSet:self.toStation.stationLines]){

        for(MetroStationLine *stationLine in self.fromStation.stationLines){

            NSArray *metroStationsOnThisLine = [self metroStations:stationLine];
            int fromIndex = [metroStationsOnThisLine indexOfObject:self.fromStation];

                //can get to destination on this line?
            if([self.toStation.stationLines containsObject:stationLine]){
                JourneyRoute *journeyRoute = [self findShortestRouteOnSameLineFrom:self.fromStation toStation:self.toStation
                                                                     onStationLine:stationLine];


                if(journeyRoute){
                    journeyRoute.trainTime = [[TrainTime alloc] initWithMetroStation:self.fromStation];
[self.journeyRoutes addObject:journeyRoute];
                }

                    //FINDING ALTERNATE
                NSArray *fromNearestInterchanges = [self nearestInterchanges:self.fromStation onStationLine:stationLine];
                NSMutableArray *toNearestInterchanges = [[self nearestInterchanges:self.toStation onStationLine:stationLine] mutableCopy];

                for(MetroStation *fromNearestInterchangeStation in fromNearestInterchanges){
                    int fromNearestInterchangeStationIndex = [metroStationsOnThisLine indexOfObject:fromNearestInterchangeStation];
                    int numberOfStations = 0;

                    int from = fromIndex;
                    int to = fromNearestInterchangeStationIndex;

                    if(from > to){
                            //swap the variables
                        from = from + to;
                        to = from - to;
                        from = from - to;
                    }

                    BOOL isPassingThroughDestinationStation = NO;

                    for(int i = from; i < to; i++){
                        numberOfStations++;
                            //if we are not passing thru destination
                        if([metroStationsOnThisLine[i] isEqual:self.toStation]){
                            isPassingThroughDestinationStation = YES;
                            numberOfStations = 0; //reset number of stations
                            break;
                        }
                    }

                    [toNearestInterchanges removeObject:fromNearestInterchangeStation];

                    if(!isPassingThroughDestinationStation){

                            //change to other line at interchange
                        NSMutableSet *otherLines = [fromNearestInterchangeStation.stationLines mutableCopy];
                        [otherLines removeObject:stationLine];

                            //Find an interchange that connects to destination
                        for(MetroStationLine *aStationLine in otherLines){

                                //Does it get to an interchange that connects to an interchange that connects to destination?
                            for(MetroStation *anInterchange in [self interchangesOnStationLine:aStationLine]){
                                if(![anInterchange isEqual:fromNearestInterchangeStation]){
                                    if([toNearestInterchanges containsObject:anInterchange]){

                                        NSMutableSet *toStationLines = [self.toStation.stationLines mutableCopy];
                                        [toStationLines intersectSet:anInterchange.stationLines];

                                        for(MetroStationLine *toStationLine in toStationLines){

                                            int aNumber = [self numberOfStationFromInterchange:fromNearestInterchangeStation
                                                                                 toInterchange:anInterchange onStationLine:aStationLine];
                                            if(aNumber != NSNotFound){
                                                numberOfStations += aNumber;
                                            }

                                            JourneyRoute *aJourneyRoute = [self findShortestRouteOnSameLineFrom:anInterchange
                                                                                                      toStation:self.toStation
                                                                                                  onStationLine:toStationLine];
                                            aJourneyRoute.fromStation = self.fromStation;
                                            aJourneyRoute.towardsStation = [self towardsStationFrom:self.fromStation toStation:self.toStation onSameStationLine:stationLine];
                                            aJourneyRoute.numberOfStationsToTravel += numberOfStations;

                                                //Record First Interchange
                                            JourneyInterchange *firstInterchange = [[JourneyInterchange alloc] init];
                                            firstInterchange.towardsStation = [self towardsStationFrom:fromNearestInterchangeStation
                                                                                             toStation:anInterchange
                                                                                     onSameStationLine:aStationLine];
                                            firstInterchange.interchangeStation = fromNearestInterchangeStation;

                                                //Record Second Interchange
                                            JourneyInterchange *secondInterchange = [[JourneyInterchange alloc] init];
                                            secondInterchange.towardsStation = [self towardsStationFrom:anInterchange toStation:self.toStation
                                                                                      onSameStationLine:toStationLine];
                                            secondInterchange.interchangeStation = anInterchange;

                                            if(firstInterchange) [aJourneyRoute.interchanges addObject:firstInterchange];
                                            if(secondInterchange) [aJourneyRoute.interchanges addObject:secondInterchange];

                                            [aJourneyRoute.stationZoneNumbers addObject:fromNearestInterchangeStation.stationZone];
                                            [aJourneyRoute.stationZoneNumbers addObject:anInterchange.stationZone];
                                            
                                            if(aJourneyRoute){
                                                aJourneyRoute.trainTime = [[TrainTime alloc] initWithMetroStation:self.fromStation];
                                                [self.journeyRoutes addObject:aJourneyRoute];
                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }else{
            //We are not on the same lines
        if([self.fromStation.stationLines count] == 1){
            [self findShortestRouteOnDifferentLinesFrom:self.fromStation
                                              toStation:self.toStation
                                          onStationLine:[self.fromStation.stationLines anyObject]];
        }
    }



#ifdef DM_DEBUG
    int routeNumber = 1;

    for(JourneyRoute *jr in self.journeyRoutes){

        NSLog(@"---------------------------------------------------------------");
        NSLog(@"");
        NSLog(@"Route %d: ", routeNumber);
        NSLog(@"From: %@", jr.fromStation.stationName);
        NSLog(@"Towards: %@", jr.towardsStation.stationName);

        if([jr.interchanges count]){
            for(JourneyInterchange *interchangeStation in jr.interchanges){

                NSLog(@"Interchange at: %@; towards: %@", interchangeStation.interchangeStation.stationName,
                      interchangeStation.towardsStation.stationName);
            }
        }



        NSLog(@"To: %@", jr.toStation.stationName);
        NSLog(@"Number of Stops: %d", jr.numberOfStationsToTravel);
        NSLog(@"Zones: %@", jr.stationZoneNumbers);
        
        routeNumber++;
    }
#endif


        //wrap in arrays for sections in cells
    NSMutableArray *theJourneyRoutes = [NSMutableArray array];

    for(id journeyRoute in self.journeyRoutes){
            //add towards station zone
        [((JourneyRoute *)journeyRoute).stationZoneNumbers addObject:self.toStation.stationZone];

        float price = [self ticketPrice:journeyRoute];

        if(!self.ticketPrice || price > self.ticketPrice){
            self.ticketPrice = price;
        }

        [theJourneyRoutes addObject:[NSArray arrayWithObject:journeyRoute]];
    }

    return theJourneyRoutes;
}

- (JourneyRoute *)findShortestRouteOnSameLineFrom:(MetroStation *)fromStation
                                        toStation:(MetroStation *)toStation
                                    onStationLine:(MetroStationLine *)stationLine
{
    if(![fromStation.stationLines containsObject:stationLine] || ![toStation.stationLines containsObject:stationLine]) return nil;

    JourneyRoute *route = [[JourneyRoute alloc] init];
    NSArray *metroStationsOnThisLine = [self metroStations:stationLine];
    int fromIndex = [metroStationsOnThisLine indexOfObject:fromStation];
    int toIndex = [metroStationsOnThisLine indexOfObject:toStation];

    if(fromIndex > toIndex){
            //swap the variables
        fromIndex = fromIndex + toIndex;
        toIndex = fromIndex - toIndex;
        fromIndex = fromIndex - toIndex;
    }

    int numberOfStations = toIndex - fromIndex;

    route.fromStation = fromStation;
    route.toStation = toStation;
    route.towardsStation = [self towardsStationFrom:fromStation toStation:toStation onSameStationLine:stationLine];
    route.numberOfStationsToTravel = numberOfStations ? (numberOfStations - 1) : numberOfStations;

        //Populate visited interchanges
    for(int i = fromIndex; i <= toIndex; i++){
        [route.stationZoneNumbers addObject:((MetroStation *)metroStationsOnThisLine[i]).stationZone];

        if([self isMetroStationAnInterchange:metroStationsOnThisLine[i]]){

            [self.visitedInterchanges addObject:metroStationsOnThisLine[i]];
        }
    }

    return route;
}

- (void)findShortestRouteOnDifferentLinesFrom:(MetroStation *)fromStation
                                    toStation:(MetroStation *)toStation
                                onStationLine:(MetroStationLine *)stationLine
{

    NSMutableSet *interchanges = [NSMutableSet set];

    [[self nearestInterchanges:toStation onStationLine:nil] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [interchanges addObject:(MetroStation *)obj];
    }];

    [[self nearestInterchanges:fromStation onStationLine:stationLine] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [interchanges addObject:(MetroStation *)obj];
    }];

    for(MetroStation *interchangeStation in interchanges){

        JourneyRoute *route = [self findShortestRouteOnSameLineFrom:self.fromStation toStation:interchangeStation
                                                      onStationLine:[self.fromStation.stationLines anyObject]];
        route.toStation = self.toStation;
        JourneyInterchange *intchange = [[JourneyInterchange alloc] init];
        intchange.towardsStation = [self towardsStationFrom:interchangeStation toStation:self.toStation
                                          onSameStationLine:[self.toStation.stationLines anyObject]];
        intchange.interchangeStation = interchangeStation;

        [route.interchanges addObject:intchange];

        NSArray *metroStationsOnThisLine = [self metroStations:[self.toStation.stationLines anyObject]];
        int fromIndex = [metroStationsOnThisLine indexOfObject:interchangeStation];
        int toIndex = [metroStationsOnThisLine indexOfObject:toStation];

        if(fromIndex > toIndex){
                //swap the variables
            fromIndex = fromIndex + toIndex;
            toIndex = fromIndex - toIndex;
            fromIndex = fromIndex - toIndex;
        }

        int numberOfStations = toIndex - fromIndex;
        route.numberOfStationsToTravel += numberOfStations;

        [route.stationZoneNumbers addObject:interchangeStation.stationZone];

        if(route){
            route.trainTime = [[TrainTime alloc] initWithMetroStation:self.fromStation];
            [self.journeyRoutes addObject:route];
        }
    }
}

- (NSArray *)nearestInterchanges:(MetroStation *)metroStation onStationLine:(MetroStationLine *)stationLine
{
    NSMutableArray *nearestInterchanges = [NSMutableArray array];

    if([metroStation.stationLines count] == 1){

        MetroStationLine *stationLine = [metroStation.stationLines anyObject];
        NSArray *interchanges = [self interchangesOnStationLine:stationLine];
        NSArray *metroStationsOnThisLines = [self metroStations:stationLine];

        int stationIndex = [metroStationsOnThisLines indexOfObject:metroStation];
        int nearestInterchangeIndex = NSNotFound;

        for(MetroStation *interchangeStation in interchanges){

            int interchangeIndex = [metroStationsOnThisLines indexOfObject:interchangeStation];

            if((nearestInterchangeIndex == NSNotFound) || abs(interchangeIndex - stationIndex) <= abs(nearestInterchangeIndex - stationIndex)) {
                nearestInterchangeIndex = interchangeIndex;
            }

            if(![nearestInterchanges containsObject:metroStationsOnThisLines[nearestInterchangeIndex]]){

                MetroStation *nearestInterchangeStation = nil;

                if(nearestInterchangeIndex != NSNotFound) nearestInterchangeStation = metroStationsOnThisLines[nearestInterchangeIndex];

                if(nearestInterchangeStation) [nearestInterchanges addObject:nearestInterchangeStation];

                NSMutableArray *tempNearestInterchanges = [nearestInterchanges mutableCopy];

                [tempNearestInterchanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){

                    int aStationIndex = [metroStationsOnThisLines indexOfObject:(MetroStation *)obj];

                    if(abs(interchangeIndex - stationIndex) < abs(aStationIndex - stationIndex)){
                        [nearestInterchanges removeObject:(MetroStation *)obj];
                    }

                }];
            }
        }
    }

    return nearestInterchanges;
}

- (NSArray *)interchangesOnStationLine:(MetroStationLine *)stationLine
{
    NSMutableArray *interchanges = [NSMutableArray array];

    for(MetroStation *metroStation in [self metroStations:stationLine]){
        if([self isMetroStationAnInterchange:metroStation]){
            [interchanges addObject:metroStation];
        }
    }

    return interchanges;
}

- (MetroStation *)towardsStationFrom:(MetroStation *)fromStation
                           toStation:(MetroStation *)toStation
                   onSameStationLine:(MetroStationLine *)stationLine
{
    MetroStation *towardsStation = nil;

        //if we are directly connected
    if([fromStation.stationLines containsObject:stationLine] && [toStation.stationLines containsObject:stationLine]){

        NSArray *metroStationForLine = [self metroStations:stationLine];

        int fromIndex = [metroStationForLine indexOfObject:fromStation];
        int toIndex = [metroStationForLine indexOfObject:toStation];

        if(toIndex > fromIndex){
            towardsStation = [metroStationForLine lastObject];
        }else if(fromIndex > toIndex){
            towardsStation = [metroStationForLine firstObject];
        }
    }

    return towardsStation;
}

- (NSArray *)metroStations:(MetroStationLine *)stationLine
{
    return [[stationLine.metroStations allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        MetroStationOrder *stationOrder1 = [MetroStationOrder fetchStationOrder:(MetroStation *)obj1 stationLine:stationLine];
        MetroStationOrder *stationOrder2 = [MetroStationOrder fetchStationOrder:(MetroStation *)obj2 stationLine:stationLine];
        
        return [stationOrder1.stationNumber compare:stationOrder2.stationNumber];
    }];
}

- (BOOL)isMetroStationAnInterchange:(MetroStation *)station
{
    if([station.stationLines count] > 1) return YES;
    return NO;
}

- (int)numberOfStationFromInterchange:(MetroStation *)fromInterchange
                        toInterchange:(MetroStation *)toInterchange
                        onStationLine:(MetroStationLine *)stationLine
{
    int numberOfStations = -1;

    int fromIndex = [[self metroStations:stationLine] indexOfObject:fromInterchange];
    int toIndex = [[self metroStations:stationLine] indexOfObject:toInterchange];

    if(fromIndex > toIndex){
            //swap the variables
        fromIndex = fromIndex + toIndex;
        toIndex = fromIndex - toIndex;
        fromIndex = fromIndex - toIndex;
    }

    numberOfStations = (toIndex - fromIndex);

    if(numberOfStations >= 0){
        return numberOfStations;
    }

    return NSNotFound;
}

@end