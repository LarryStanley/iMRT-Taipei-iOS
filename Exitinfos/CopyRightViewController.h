//
//  CopyRightViewController.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/6.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CopyRightViewController : UIViewController  <MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSString *CardTypeName;
    UIView *IconView;
}
@property (weak, nonatomic) IBOutlet UIButton *ContactUs;
@property (weak, nonatomic) IBOutlet UIButton *FacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *TwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *AppStoreRate;
@property (weak, nonatomic) IBOutlet UITableView *CardTypeTableView;
@property (weak, nonatomic) IBOutlet UILabel *VersionLable;
@property (weak, nonatomic) IBOutlet UIImageView *IconImageView;
@property (weak, nonatomic) IBOutlet UINavigationBar *NavigationBar;


@end
