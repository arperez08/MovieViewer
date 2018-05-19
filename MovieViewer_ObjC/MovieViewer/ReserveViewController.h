//
//  ReserveViewController.h
//  MovieViewer
//
//  Created by Arnel Perez on 17/05/2018.
//  Copyright © 2018 Arnel Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ZSeatSelector.h"
#import "ZSeat.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"

@interface ReserveViewController : UIViewController <ZSeatSelectorDelegate>
{
    MBProgressHUD *HUB;
    TSPopoverController *popoverController;
    UIPickerView *pickerDate;
    UIPickerView *pickerCinema;
    UIPickerView *pickerTimes;
    NSMutableArray *arraySeats;
    NSMutableArray *arrayDates;
    NSMutableArray *arrayCinemas;
    NSMutableArray *arrayTimes;
    NSMutableArray *arrayCinemasInside;
    NSMutableArray *arrayTimesInside;
    NSString *dateID;
    NSString *cinemaID;
    NSString *timesID;
    float seatPrice;
}
@property (nonatomic) float seatPrice;
@property (strong, nonatomic) NSMutableArray *arraySeats;
@property (strong, nonatomic) NSMutableArray *arrayDates;
@property (strong, nonatomic) NSMutableArray *arrayCinemas;
@property (strong, nonatomic) NSMutableArray *arrayTimes;
@property (strong, nonatomic) NSMutableArray *arrayCinemasInside;
@property (strong, nonatomic) NSMutableArray *arrayTimesInside;
@property (strong, nonatomic) NSString *dateID;
@property (strong, nonatomic) NSString *cinemaID;
@property (strong, nonatomic) NSString *timesID;
@property (strong, nonatomic) UIPickerView *pickerDate;
@property (strong, nonatomic) UIPickerView *pickerCinema;
@property (strong, nonatomic) UIPickerView *pickerTimes;
@property (strong, nonatomic) IBOutlet UIView *seatsMappingView;
@property (strong, nonatomic) IBOutlet UILabel *lblSelectedSeats;
@property (strong, nonatomic) IBOutlet UILabel *lblTotal;
@property (strong, nonatomic) IBOutlet UIButton *btnDate;
@property (strong, nonatomic) IBOutlet UIButton *btnCinema;
@property (strong, nonatomic) IBOutlet UIButton *btnTime;


@end
