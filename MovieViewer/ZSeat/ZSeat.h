//
//  ZSeat.h
//  
//  Modified by Arnel Perez on 05/18/2015.
//

#import <UIKit/UIKit.h>

@interface ZSeat : UIButton

@property (nonatomic) int row;
@property (nonatomic) int column;
@property (nonatomic) BOOL available;
@property (nonatomic) BOOL disabled;
@property (nonatomic) BOOL selected_seat;
@property (nonatomic) float price;
@property (nonatomic) NSString* seatName; //Added by Arnel 

@end
