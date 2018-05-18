//
//  ViewController.m
//  MovieViewer
//
//  Created by Arnel Perez on 17/05/2018.
//  Copyright © 2018 Arnel Perez. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize imgPoster, imgPosterLandscape, lblName, lblGenre, lblRelease, lblAdvisory, lblDuration, lblSypnosis;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Movie Viewer";
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callWebserviceURL) onTarget:self withObject:nil animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) callWebserviceURL{
    NSString * strPortalURL = @"http://ec2-52-76-75-52.ap-southeast-1.compute.amazonaws.com/movie.json";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
        
        lblAdvisory.text = [dictData objectForKey:@"advisory_rating"];
        lblName.text = [dictData objectForKey:@"canonical_title"];
        lblGenre.text = [dictData objectForKey:@"genre"];
        lblSypnosis.text  = [dictData objectForKey:@"synopsis"];
        
        NSString *runtime_mins  = [dictData objectForKey:@"runtime_mins"];
        NSString *release_date = [dictData objectForKey:@"release_date"];

        NSString *poster = [dictData objectForKey:@"poster"];
        NSString *poster_landscape = [dictData objectForKey:@"poster_landscape"];
        [self downloadImageWithURL:[NSURL URLWithString:poster_landscape] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                imgPosterLandscape.image = image;
            }
        }];
        [self downloadImageWithURL:[NSURL URLWithString:poster] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                imgPoster.image = image;
            }
        }];
        
    }
    else{
        
    }
}




- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error ) {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               }
                               else{
                                   completionBlock(NO,nil);
                               }
                           }];
}


@end
