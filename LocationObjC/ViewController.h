//
//  ViewController.h
//  LocationObjC
//
//  Created by Nishanth Vishnu on 27/12/18.
//  Copyright © 2018 Nishanth Vishnu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblLatLong;
@property (strong, nonatomic) IBOutlet UILabel *lblTimeStamp;
@property (strong, nonatomic) IBOutlet UIButton *btnStartStop;
@end

