//
//  ViewController.m
//  LocationObjC
//
//  Created by Nishanth Vishnu on 27/12/18.
//  Copyright © 2018 Nishanth Vishnu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    int viewWidth;
    int viewHeight;
    BOOL timerStarted;
    CLLocationManager *locationManager;
    NSMutableString *latLong;
    NSDate *currentDate;
    float timeInterval;
}
@end

@implementation ViewController
@synthesize lblLatLong, lblTimeStamp;
@synthesize btnStartStop;

NSTimer *timer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    viewWidth = self.view.frame.size.width;
    viewHeight = self.view.frame.size.height;
    timerStarted = false;
    
    timeInterval = 1.0;
    
    [self addUIElements];
    
}

- (void) addUIElements{
    lblLatLong = [[UILabel alloc] init];
    
    int lblLatLongWidth = viewWidth;
    int lblLatLongHeight = 90;
    int lblLatLongXLoc = 0;
    int lblLatLongYLoc = viewHeight - lblLatLongHeight;
    
    lblLatLong.frame = CGRectMake(lblLatLongXLoc, lblLatLongYLoc, lblLatLongWidth, lblLatLongHeight);
    [lblLatLong setBackgroundColor: [UIColor blueColor]];
    [lblLatLong setText:@" Lat Long "];
    [lblLatLong setTextAlignment:NSTextAlignmentCenter];
    [lblLatLong setTextColor: [UIColor whiteColor]];
    
    [self.view addSubview: lblLatLong];
    
    lblTimeStamp = [[UILabel alloc] init];
    
    int lblTimeStampWidth = lblLatLongWidth;
    int lblTimeStampHeight = lblLatLongHeight;
    int lblTimeStampXLoc = lblLatLongXLoc;
    int lblTimeStampYLoc = lblLatLongYLoc - lblTimeStampHeight;
    
    lblTimeStamp.frame = CGRectMake(lblTimeStampXLoc, lblTimeStampYLoc, lblTimeStampWidth, lblTimeStampHeight);
    [lblTimeStamp setBackgroundColor: [UIColor redColor]];
    [lblTimeStamp setText:@" Time Stamp "];
    [lblTimeStamp setTextAlignment:NSTextAlignmentCenter];
    [lblTimeStamp setTextColor: [UIColor whiteColor]];
    
    [self.view addSubview: lblTimeStamp];
    
    btnStartStop = [[UIButton alloc] init];
    
    int btnStartStopWidth = viewWidth/2;
    int btnStartStopHeight = lblLatLongHeight;
    int btnStartStopXLoc = (viewWidth - btnStartStopWidth)/2;
    int btnStartStopYLoc = (viewHeight - btnStartStopHeight)/2;
    
    btnStartStop.frame = CGRectMake(btnStartStopXLoc, btnStartStopYLoc, btnStartStopWidth, btnStartStopHeight);
    [btnStartStop setBackgroundColor: [UIColor darkGrayColor]];
    [btnStartStop setTitle:@"START TRACKING" forState:UIControlStateNormal];
    [btnStartStop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnStartStop addTarget:self action:@selector(startTimer:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: btnStartStop];
    
}

- (void) startTimer : (UIButton *) buttonObj{
    
    if(timerStarted){
        [self stopTimer];
        
        return;
    }
    
    if([self checkLocationServicesON]){
        if([self checkLocationPermissionEnabled]){
            if(!timerStarted){
                
                timerStarted = YES;
                
                [btnStartStop setTitle:@"STOP TRACKING" forState:UIControlStateNormal];
                [btnStartStop setBackgroundColor: [UIColor lightGrayColor]];
                
                timer = [NSTimer
                         scheduledTimerWithTimeInterval:timeInterval
                         target:self
                         selector:@selector(getUserLatLong)
                         userInfo:nil
                         repeats:YES];                
                
            }
        }
    }
}

- (void) getUserLatLong{
    
    if(locationManager == nil){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    
    
    currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    
    NSString *dateString = [formatter stringFromDate:currentDate];
    
    
    
    NSLog(@"Timestamp: %@", dateString);
    NSLog(@"latLong: %@", latLong);
    NSLog(@"");
    
    if(latLong != nil && timerStarted){
        [lblLatLong setText: latLong];
        [lblTimeStamp setText: dateString];
        if(timeInterval == 1){
            timeInterval = 5.0;
            
            [self stopTimer];
            timerStarted = YES;
            timer = [NSTimer
                     scheduledTimerWithTimeInterval:timeInterval
                     target:self
                     selector:@selector(getUserLatLong)
                     userInfo:nil
                     repeats:YES];
        }
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusDenied) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Switch On Location Services." message:@"Your Location Services option is OFF. Do you wish to switch it ON?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:[NSDictionary new] completionHandler:nil];
            
        }];
        
        UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [btnStartStop setTitle:@"STOP TRACKING" forState:UIControlStateNormal];
        [btnStartStop setBackgroundColor: [UIColor lightGrayColor]];

        
        if(timer == nil){
            timerStarted = YES;
            timer = [NSTimer
                     scheduledTimerWithTimeInterval:timeInterval
                     target:self
                     selector:@selector(getUserLatLong)
                     userInfo:nil
                     repeats:YES];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *loc = [locations lastObject];
    latLong = [[NSMutableString alloc] init];
    [latLong appendString:@"LAT: "];
    [latLong appendString:[NSString stringWithFormat:@"%f", loc.coordinate.latitude]];
    [latLong appendString:@"  - LONG: "];
    [latLong appendString:[NSString stringWithFormat:@"%f", loc.coordinate.longitude]];
}


//Check if device location services settings is ON
- (BOOL) checkLocationServicesON{
    
    if(![CLLocationManager locationServicesEnabled]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Switch On Location Services." message:@"Your Location Services option is OFF. Do you wish to switch it ON?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:[NSDictionary new] completionHandler:nil];
            
        }];
        
        UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

//Check if App Permission for Location Services is ENABLED
- (BOOL) checkLocationPermissionEnabled{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        
        [self stopTimer];
        
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
        
        return NO;
        
    } else {
        return YES;
    }
}

- (void) stopTimer{
    
    if(timer != nil){
        [timer invalidate];
        timer = nil;
        
        timerStarted = NO;
        
        [btnStartStop setTitle:@"START TRACKING" forState:UIControlStateNormal];
        [btnStartStop setBackgroundColor: [UIColor darkGrayColor]];
        
        NSLog(@"Timer Stopped");
    }
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self stopTimer];
}


@end
