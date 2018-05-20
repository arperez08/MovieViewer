//
//  ReserveViewController.m
//  MovieViewer
//
//  Created by Arnel Perez on 17/05/2018.
//  Copyright © 2018 Arnel Perez. All rights reserved.
//

#import "ReserveViewController.h"
#import "seatsCollectionViewCell.h"

@interface ReserveViewController ()

@end

@implementation ReserveViewController
@synthesize seatsMappingView, lblSelectedSeats, lblTotal, btnDate, btnTime, btnCinema;
@synthesize arrayDates, arrayTimes, arrayCinemas, arraySeats, dateID, timesID, cinemaID, pickerDate, pickerCinema, pickerTimes, arrayTimesInside, arrayCinemasInside, seatPrice;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [btnDate addTarget:self action:@selector(showDate:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [btnCinema addTarget:self action:@selector(showCinema:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [btnTime addTarget:self action:@selector(showTimes:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callScheduleURL) onTarget:self withObject:nil animated:YES];
    
//    HUB = [[MBProgressHUD alloc]initWithView:self.view];
//    [self.view addSubview:HUB];
//    [HUB showWhileExecuting:@selector(callSeatMapURL) onTarget:self withObject:nil animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) callScheduleURL{
    NSString * strPortalURL = @"http://ec2-52-76-75-52.ap-southeast-1.compute.amazonaws.com/schedule.json";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
        arrayDates = [dictData objectForKey:@"dates"];
        arrayCinemas = [dictData objectForKey:@"cinemas"];
        arrayTimes = [dictData objectForKey:@"times"];
        [arrayDates insertObject:@"---  Date  ---" atIndex:0];
    }
    else{
        NSLog(@"%@",error);
    }
}

- (void) callSeatMapURL{
    NSString * strPortalURL = @"http://ec2-52-76-75-52.ap-southeast-1.compute.amazonaws.com/seatmap.json";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        //NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        //NSLog(@"responseData: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
        [self mapSeats:dictData];
    }
    else{
        NSLog(@"%@",error);
    }
}

-(void) mapSeats :(NSDictionary *)dictData{
    ZSeatSelector *seat = [[ZSeatSelector alloc]initWithFrame:CGRectMake(0, 0, seatsMappingView.frame.size.width, seatsMappingView.frame.size.height)];
    [seat setSeatSize:CGSizeMake(10, 10)];
    [seat setAvailableImage:[UIImage imageNamed:@"available"]
        andUnavailableImage:[UIImage imageNamed:@"unavailable"]
           andDisabledImage:[UIImage imageNamed:@"unavailable"]
           andSelectedImage:[UIImage imageNamed:@"selected"]];
    [seat setSelected_seat_limit:10];
    [seat setSeat_price:seatPrice];
    [seat setMap:dictData];
    seat.seat_delegate = self;
    [seatsMappingView addSubview:seat];
}

- (void)seatSelected:(ZSeat *)seat{
    NSLog(@"Seat at Row:%ld and Column:%ld", (long)seat.row, (long)seat.column);
    NSLog(@"SeatName: %@",seat.seatName);
}

-(void)getSelectedSeats:(NSMutableArray *)seats{
    float total=0;
    NSString *selectedSeats = @"";
    for (int i=0; i<[seats count]; i++) {
        ZSeat *seat = [seats objectAtIndex:i];
        if (i == 0) {
            selectedSeats = seat.seatName;
            lblSelectedSeats.text = seat.seatName;
        }
        else{
            selectedSeats = [NSString stringWithFormat:@"%@, %@",selectedSeats,seat.seatName];
            lblSelectedSeats.text = selectedSeats;
        }
        total += seat.price;
    }
    lblTotal.text  = [NSString localizedStringWithFormat:@"Php %.2f", total];
}

-(void)showDate:(id)sender forEvent:(UIEvent*)event{
    UIViewController *showDateView = [[UIViewController alloc]init];
    showDateView.view.frame = CGRectMake(0,0, 320, 100);
    pickerDate = [[UIPickerView alloc] init];
    pickerDate.delegate = self;
    pickerDate.dataSource = self;
    pickerDate.frame  = CGRectMake(0,0, 320, 120);
    pickerDate.showsSelectionIndicator = YES;
    [showDateView.view addSubview:pickerDate];
    popoverController = [[TSPopoverController alloc] initWithContentViewController:showDateView];
    popoverController.cornerRadius = 5;
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

-(void)showTimes:(id)sender forEvent:(UIEvent*)event{
    UIViewController *showTimeView = [[UIViewController alloc]init];
    showTimeView.view.frame = CGRectMake(0,0, 320, 100);
    pickerTimes = [[UIPickerView alloc] init];
    pickerTimes.delegate = self;
    pickerTimes.dataSource = self;
    pickerTimes.frame  = CGRectMake(0,0, 320, 120);
    pickerTimes.showsSelectionIndicator = YES;
    [showTimeView.view addSubview:pickerTimes];
    popoverController = [[TSPopoverController alloc] initWithContentViewController:showTimeView];
    popoverController.cornerRadius = 5;
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

-(void)showCinema:(id)sender forEvent:(UIEvent*)event{
    UIViewController *showCinemaView = [[UIViewController alloc]init];
    showCinemaView.view.frame = CGRectMake(0,0, 320, 100);
    pickerCinema = [[UIPickerView alloc] init];
    pickerCinema.delegate = self;
    pickerCinema.dataSource = self;
    pickerCinema.frame  = CGRectMake(0,0, 320, 120);
    pickerCinema.showsSelectionIndicator = YES;
    [showCinemaView.view addSubview:pickerCinema];
    popoverController = [[TSPopoverController alloc] initWithContentViewController:showCinemaView];
    popoverController.cornerRadius = 5;
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) refeshPickerListCinema{
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callScheduleURL) onTarget:self withObject:nil animated:YES];
    arrayCinemasInside = [[NSMutableArray alloc] init];
    for (int i=0; i < [arrayCinemas count]; i++) {
        NSMutableDictionary * dictCinema = [arrayCinemas objectAtIndex:i];
        NSString *parentID = [dictCinema objectForKey:@"parent"];
        if ([parentID isEqualToString: dateID]) {
            arrayCinemasInside = [dictCinema objectForKey:@"cinemas"];
        }
    }
    [arrayCinemasInside insertObject:@"--- Cinema ---" atIndex:0];
    [pickerCinema reloadAllComponents];
}

-(void) refeshPickerListTime{
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callScheduleURL) onTarget:self withObject:nil animated:YES];
   arrayTimesInside = [[NSMutableArray alloc] init];
    for (int i=0; i < [arrayTimes count]; i++) {
        NSMutableDictionary * dictTimes = [arrayTimes objectAtIndex:i];
        NSString *parentID = [dictTimes objectForKey:@"parent"];
        if ([parentID isEqualToString: cinemaID]) {
            arrayTimesInside =  [dictTimes objectForKey:@"times"];
        }
    }
    [arrayTimesInside insertObject:@"--- Time ---" atIndex:0];
    [pickerTimes reloadAllComponents];
}

#pragma mark - PickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (thePickerView == pickerDate){
        return [arrayDates count];
    }
    if (thePickerView == pickerTimes){
        return [arrayTimesInside count];
    }
    if (thePickerView == pickerCinema){
        return [arrayCinemasInside count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
        tView = [[UILabel alloc] init];
    [tView setFont:[UIFont fontWithName:@"Helvetica" size:18.5]];
    [tView setTextColor:[UIColor darkGrayColor]];
    [tView setTextAlignment:NSTextAlignmentCenter];
    
    if (thePickerView == pickerDate) {
        if (row > 0) {
            NSMutableDictionary *dictDates = [arrayDates objectAtIndex:row];
            tView.text = [dictDates objectForKey:@"label"];
            return tView;
        }
        else{
            tView.text = @"---  Date  ---";
            return tView;
        }
    }
    if (thePickerView == pickerCinema) {
        if (row > 0) {
            NSMutableDictionary *dictDates = [arrayCinemasInside objectAtIndex:row];
            tView.text = [dictDates objectForKey:@"label"];
            return tView;
        }
        else{
            tView.text = [arrayCinemasInside objectAtIndex:row];
            return tView;
        }
    }
    if (thePickerView == pickerTimes) {
        if (row > 0) {
            NSMutableDictionary *dictDates = [arrayTimesInside objectAtIndex:row];
            tView.text = [dictDates objectForKey:@"label"];
            return tView;
        }
        else{
            tView.text =  [arrayTimesInside objectAtIndex:row];
            return tView;
        }
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (thePickerView == pickerDate) {
        if (row > 0) {
            btnCinema.titleLabel.text = @"--- Cinema ---";
            NSMutableDictionary *dicDates = [arrayDates objectAtIndex:row];
            btnDate.titleLabel.text = [dicDates objectForKey:@"label"];
            dateID =  [dicDates objectForKey:@"id"];
        }
        else{
            btnDate.titleLabel.text =  [arrayDates objectAtIndex:row];
            dateID = 0;
        }
        [self refeshPickerListCinema];
    }
    if (thePickerView == pickerCinema) {
        if (row > 0) {
            btnTime.titleLabel.text = @"--- Time ---";
            NSMutableDictionary *dicCinema = [arrayCinemasInside objectAtIndex:row];
            btnCinema.titleLabel.text = [dicCinema objectForKey:@"label"];
            cinemaID =  [dicCinema objectForKey:@"id"];
        }
        else{
            btnCinema.titleLabel.text = [arrayCinemasInside objectAtIndex:row];
            cinemaID = 0;
        }
        [self refeshPickerListTime];
        
    }
    if (thePickerView == pickerTimes) {
        if (row > 0) {
            NSMutableDictionary *dicTimes = [arrayTimesInside objectAtIndex:row];
            btnTime.titleLabel.text = [dicTimes objectForKey:@"label"];
            timesID =  [dicTimes objectForKey:@"id"];
            seatPrice = [[dicTimes objectForKey:@"price"] floatValue];
            
            [seatsMappingView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            lblTotal.text = @"Php 0.00";
            lblSelectedSeats.text = @"";
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callSeatMapURL) onTarget:self withObject:nil animated:YES];
        }
        else{
            btnTime.titleLabel.text = [arrayTimesInside objectAtIndex:row];
            timesID =  0;
        }
    }

    [popoverController dismissPopoverAnimatd:YES];
}

@end
