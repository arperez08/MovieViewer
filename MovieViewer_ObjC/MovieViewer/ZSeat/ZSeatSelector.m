//
//  ZSeatSelector.m
//  
//  Modified by Arnel Perez on 05/18/2015.
//

#import "ZSeatSelector.h"

@implementation ZSeatSelector

#pragma mark - Init and Configuration

- (void)setSeatSize:(CGSize)size{
    seat_width = size.width;
    seat_height = size.height;
}

- (void)setMap:(NSDictionary*)map{
    // remove original code that uses char and change to support personal data from JSON - Arnel
    self.delegate = self;
    zoomable_view = [[UIView alloc]init];
    
    int initial_seat_x = 0;
    int initial_seat_y = 0;
    int final_width = 0;
    
    NSMutableArray * arraySeatmap = [map objectForKey:@"seatmap"];
    NSMutableDictionary * arrayAvailableSeat = [map objectForKey:@"available"];
    NSMutableArray *arraySeats = [arrayAvailableSeat objectForKey:@"seats"];
    
    for (int i=0; i < [arraySeatmap count]; i++) {
        NSMutableArray *alphabets = [[NSMutableArray alloc] initWithArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
        
        NSString *seatLetter = [alphabets objectAtIndex:initial_seat_y];
        
        NSMutableArray *seatsPerRow = [arraySeatmap objectAtIndex:i];
        [self createSeatLetterWithPosition:initial_seat_x and:initial_seat_y isAvailable:TRUE isDisabled:TRUE seatName:seatLetter];
        
        initial_seat_x += 1;
        for (int x=0; x < [seatsPerRow count]; x++){
            NSString *seatName = [seatsPerRow objectAtIndex:x];
            if (([seatName isEqual: @"a(30)"]) || ([seatName isEqual: @"b(20)"])){
                initial_seat_x += 1;
            }
            else{
                BOOL isAvailable = [arraySeats containsObject:seatName];
                if (isAvailable == YES) {
                    [self createSeatButtonWithPosition:initial_seat_x and:initial_seat_y isAvailable:TRUE isDisabled:FALSE seatName:seatName];
                    initial_seat_x += 1;
                }
                else{
                    [self createSeatButtonWithPosition:initial_seat_x and:initial_seat_y isAvailable:FALSE isDisabled:FALSE seatName:seatName];
                    initial_seat_x += 1;
                }
            }
        }
        [self createSeatLetterWithPosition:initial_seat_x and:initial_seat_y isAvailable:TRUE isDisabled:TRUE seatName:seatLetter];
        
        final_width = initial_seat_x;
        initial_seat_x = 0;
        initial_seat_y += 1;
    }
    
    zoomable_view.frame = CGRectMake(0, 0, final_width*seat_width, initial_seat_y*seat_height);
    [self setContentSize:zoomable_view.frame.size];
    CGFloat newContentOffsetX = (self.contentSize.width - self.frame.size.width) / 2;
    self.contentOffset = CGPointMake(newContentOffsetX, 0);
    selected_seats = [[NSMutableArray alloc]init];
    [self addSubview:zoomable_view];
}

- (void)createSeatLetterWithPosition:(int)initial_seat_x and:(int)initial_seat_y isAvailable:(BOOL)available isDisabled:(BOOL)disabled seatName:(NSString*)seatName{
    
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:
                         CGRectMake(initial_seat_x*seat_width,
                                    initial_seat_y*seat_height,
                                    seat_width,
                                    seat_height)];
    fromLabel.text = seatName;
    fromLabel.numberOfLines = 1;
    fromLabel.font = [UIFont fontWithName:@"Helvetica" size: 8.0];
    fromLabel.baselineAdjustment = YES;
    fromLabel.adjustsFontSizeToFitWidth = YES;
    fromLabel.clipsToBounds = YES;
    fromLabel.backgroundColor = [UIColor clearColor];
    fromLabel.textColor = [UIColor lightGrayColor];
    fromLabel.textAlignment = NSTextAlignmentCenter;
    [zoomable_view addSubview:fromLabel];
}

- (void)createSeatButtonWithPosition:(int)initial_seat_x and:(int)initial_seat_y isAvailable:(BOOL)available isDisabled:(BOOL)disabled seatName:(NSString*)seatName{
    
    ZSeat *seatButton = [[ZSeat alloc]initWithFrame:
                         CGRectMake(initial_seat_x*seat_width,
                                    initial_seat_y*seat_height,
                                    seat_width,
                                    seat_height)];
    if (available && disabled) {
        [self setSeatAsDisabled:seatButton];
    } else if (available && !disabled) {
        [self setSeatAsAvaiable:seatButton];
    } else {
        [self setSeatAsUnavaiable:seatButton];
    }
    [seatButton setAvailable:available];
    [seatButton setDisabled:disabled];
    [seatButton setRow:initial_seat_y+1];
    [seatButton setColumn:initial_seat_x+1];
    [seatButton setPrice:self.seat_price];
    [seatButton setSeatName:seatName];
    [seatButton addTarget:self action:@selector(seatSelected:) forControlEvents:UIControlEventTouchDown];
    [zoomable_view addSubview:seatButton];
}

#pragma mark - Seat Selector Methods

- (void)seatSelected:(ZSeat*)sender{
    if (!sender.selected_seat && sender.available) {
        if (self.selected_seat_limit) {
            [self checkSeatLimitWithSeat:sender];
        }
        else {
            [self setSeatAsSelected:sender];
            [selected_seats addObject:sender];
        }
    }
    else {
        [selected_seats removeObject:sender];
        if (sender.available && sender.disabled) {
            [self setSeatAsDisabled:sender];
        }
        else if (sender.available && !sender.disabled) {
            [self setSeatAsAvaiable:sender];
        }
    }
    [self.seat_delegate seatSelected:sender];
    [self.seat_delegate getSelectedSeats:selected_seats];
}

- (void)checkSeatLimitWithSeat:(ZSeat*)sender{
    if ([selected_seats count]<self.selected_seat_limit) {
        [self setSeatAsSelected:sender];
        [selected_seats addObject:sender];
    }
//    else {
//        ZSeat *seat_to_make_avaiable = [selected_seats objectAtIndex:0];
//        if (seat_to_make_avaiable.disabled)
//            [self setSeatAsDisabled:seat_to_make_avaiable];
//        else
//            [self setSeatAsAvaiable:seat_to_make_avaiable];
//        [selected_seats removeObjectAtIndex:0];
//        [self setSeatAsSelected:sender];
//        [selected_seats addObject:sender];
//    }
}

#pragma mark - Seat Images & Availability

- (void)setAvailableImage:(UIImage *)available_image andUnavailableImage:(UIImage *)unavailable_image andDisabledImage:(UIImage *)disabled_image andSelectedImage:(UIImage *)selected_image{
    self.available_image    = available_image;
    self.unavailable_image  = unavailable_image;
    self.disabled_image     = disabled_image;
    self.selected_image     = selected_image;
}
- (void)setSeatAsUnavaiable:(ZSeat*)sender{
    [sender setImage:self.unavailable_image forState:UIControlStateNormal];
    [sender setSelected_seat:TRUE];
}
- (void)setSeatAsAvaiable:(ZSeat*)sender{
    [sender setImage:self.available_image forState:UIControlStateNormal];
    [sender setSelected_seat:FALSE];
}
- (void)setSeatAsDisabled:(ZSeat*)sender{
    [sender setImage:self.disabled_image forState:UIControlStateNormal];
    [sender setSelected_seat:FALSE];
}
- (void)setSeatAsSelected:(ZSeat*)sender{
    [sender setImage:self.selected_image forState:UIControlStateNormal];
    [sender setSelected_seat:TRUE];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    // NSLog(@"didZoom");
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [self.subviews objectAtIndex:0];
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    //NSLog(@"scrollViewWillBeginZooming");
}

@end
