//
//  ViewController.h
//  MovieViewer
//
//  Created by Arnel Perez on 17/05/2018.
//  Copyright © 2018 Arnel Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ViewController : UIViewController
{
    MBProgressHUD *HUB;
}

@property (strong, nonatomic) IBOutlet UIImageView *imgPoster;
@property (strong, nonatomic) IBOutlet UIImageView *imgPosterLandscape;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblGenre;
@property (strong, nonatomic) IBOutlet UILabel *lblAdvisory;
@property (strong, nonatomic) IBOutlet UILabel *lblDuration;
@property (strong, nonatomic) IBOutlet UILabel *lblRelease;
@property (strong, nonatomic) IBOutlet UILabel *lblSypnosis;


@end

