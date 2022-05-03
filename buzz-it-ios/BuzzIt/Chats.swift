/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/


import UIKit
import Parse
import AVFoundation
import MessageUI
import GoogleMobileAds
import AudioToolbox
import iAd

var progress = 0


class Chats: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
AVAudioPlayerDelegate,
UIAlertViewDelegate,
MFMailComposeViewControllerDelegate,
GADBannerViewDelegate,
ADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var chatsTableView: UITableView!
    
    var circularProgress: KYCircularProgress!

    //Ad banners properties
    var iAdBannerView = ADBannerView()
    var adMobBannerView = GADBannerView()
    
    
    
    /* Variables */
    var chatsArray = NSMutableArray()

    var audioPlayer : AVAudioPlayer?
    var messTimer = NSTimer()
    var buttTAG = 0
    var refreshTimer = NSTimer()
    
    
    

override func viewWillAppear(animated: Bool) {

    // Check id audio URL String is nil
    print("audio Str: \(audioURLStr)")
    
    // Send an audio message or load chat
    if audioURLStr != "" { sendAudioMessage(audioURLStr)
    } else { loadChats()  }
    
}

// Stop the Refresh Timer
override func viewDidDisappear(animated: Bool) {
    refreshTimer.invalidate()
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Set title
    self.title = theRoomName
    

    // Initialize a Record BarButton Item
    let butt = UIButton(type: UIButtonType.Custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRectMake(0, 0, 44, 44)
    butt.setBackgroundImage(UIImage(named: "miniRecButt"), forState: UIControlState.Normal)
    butt.addTarget(self, action: "recButt:", forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
    
    // Initialize a BACK BarButton Item
    let backButt = UIButton(type: UIButtonType.Custom)
    backButt.adjustsImageWhenHighlighted = false
    backButt.frame = CGRectMake(0, 0, 44, 44)
    backButt.setBackgroundImage(UIImage(named: "backButt"), forState: UIControlState.Normal)
    backButt.addTarget(self, action: "backButt:", forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
    
    
    // Init ad banners
    initiAdBanner()
    initAdMobBanner()
   
}

func backButt(sender:UIButton) {
    if audioPlayer?.playing == true {
        audioPlayer?.stop()
    }
    navigationController?.popViewControllerAnimated(true)
}

    
    
// MARK: - LOAD CHATS OF THIS ROOM
func loadChats() {
    view.showHUD(view)
    chatsArray.removeAllObjects()
    
    let query = PFQuery(className: CHAT_CLASS_NAME)
    query.orderByAscending(CHAT_SENT_DATE)
    query.whereKey(CHAT_ROOM_NAME, equalTo: theRoomName)
    query.includeKey(USER_CLASS_NAME)
    
    // Set a limit of 10 to the query (if switch is on in the Settings screen)
    if tenMessLimit { query.limit = 10 }
    
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects  {
                for object in objects {
                    self.chatsArray.addObject(object)
                } }
            // Reload a TableView)
            self.chatsTableView.reloadData()
            hudView.removeFromSuperview()
            
            // Refresh the Chat Room
            self.refreshTimer.invalidate()
            self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(REFRESH_TIME, target: self, selector: "loadChats", userInfo: nil, repeats: true)
            
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "\(error!.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            hudView.removeFromSuperview()
        } }

}
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
    
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatsArray.count
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as! ChatCell
    
    
    var chatsClass = PFObject(className: CHAT_CLASS_NAME)
    chatsClass = chatsArray[indexPath.row] as! PFObject
    var userPointer = chatsClass[CHAT_USER_POINTER] as! PFUser
    do { userPointer = try userPointer.fetchIfNeeded() } catch {  print("Error") }
    
    
        // Get user avatar
        let imageFile = userPointer[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.userAvatar.image = UIImage(data:imageData)
        } } }
        cell.userAvatar.layer.cornerRadius = cell.userAvatar.bounds.size.width/2
    
    
        // Get username
        cell.usernameLabel.text = "\(userPointer.username!)"
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "YYY/MM/DD hh:mm aa"
    let dateStr = dateFormatter.stringFromDate(chatsClass[CHAT_SENT_DATE] as! NSDate)
    cell.dateLabel.text = "\(dateStr)"
    
    
    
    // Assign tags to buttons
    cell.playOutlet.tag = indexPath.row

    
return cell
}
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 65
}




    
// MARK: - EDIT ACTIONS ON SWIPE ON A CELL
func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
}
func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
    // Get message's data (based on the cell you've swiped)
    var chatsClass = PFObject(className: CHAT_CLASS_NAME)
    chatsClass = self.chatsArray[indexPath.row] as! PFObject
    let userPointer = chatsClass[CHAT_USER_POINTER] as! PFUser
    
    
    // REPORT INAPPROPRIATE MESSAGE
    let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Report" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            // Prepare eMail
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([REPORT_EMAIL_ADDRESS])
            mailComposer.setSubject("Reporting inappropriate contents")
            mailComposer.setMessageBody("Hello \(APP_NAME) staff,<br>I'm contacting you to report inappropriate/offensive contents of the message with ID: <strong>\(chatsClass.objectId!)</strong><br>by User: <strong>\(userPointer.username!)</strong><br><br>Please review it and take the necessary actions.<br><br>Thanks,<br>Regards.", isHTML: true)
            
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposer, animated: true, completion: nil)
            } else {
                let alert = UIAlertView(title: APP_NAME,
                    message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
            }
    })
    
    
    
    // DELETE SELECTED MESSAGE
    let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in

        if userPointer.username == PFUser.currentUser()?.username {
            chatsClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                if error == nil {
                    self.chatsArray.removeObjectAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                
            } else {
                let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK" )
                alert.show()
            } }
    
            // YOU CAN DELETE ONLY YOUR OWN MESSAGE
        } else {
            let alert = UIAlertView(title: APP_NAME,
                message: "You can't remove message of other Users!",
                delegate: nil,
                cancelButtonTitle: "OK" )
            alert.show()
        }

    })
    
    
    // Set colors of the actions
    deleteAction.backgroundColor = UIColor.redColor()
    reportAction.backgroundColor = UIColor.darkGrayColor()
    
    
return [reportAction, deleteAction]
}

// Email delegate (for the deleteAction above)
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
    var outputMessage = ""
    switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            outputMessage = "Mail cancelled"
        case MFMailComposeResultSaved.rawValue:
            outputMessage = "Mail saved"
        case MFMailComposeResultSent.rawValue:
            outputMessage = "Mail sent"
        case MFMailComposeResultFailed.rawValue:
            outputMessage = "Something went wrong with sending Mail, try again later."
        default: break
    }
        let alert = UIAlertView(title: APP_NAME,
        message: outputMessage,
        delegate: nil,
        cancelButtonTitle: "OK" )
        alert.show()
        
        dismissViewControllerAnimated(false, completion: nil)
}
    
    
    
    

// MARK: - PLAY MESSAGE BUTTON
@IBAction func playButt(sender: AnyObject) {
    let button = sender as! UIButton
    buttTAG = button.tag
    button.setBackgroundImage(UIImage(named: "playingIcon"), forState: UIControlState.Normal)

    // Setup circular progress
    circularProgress = KYCircularProgress(frame: CGRectMake(0, 0, button.frame.size.width, button.frame.size.height))
    circularProgress.colors = [0xa4d22c, 0xa4d22c, 0xa4d22c, 0xa4d22c]
    circularProgress.lineWidth = 3
    
    circularProgress.progressChangedClosure({ (progress: Double, circularView: KYCircularProgress) in })
    button.addSubview(circularProgress)
    button.sendSubviewToBack(circularProgress)
    
    
    
    var chatsClass = PFObject(className: CHAT_CLASS_NAME)
    chatsClass = chatsArray[button.tag] as! PFObject
    
    let audioFile = chatsClass[CHAT_MESSAGE] as? PFFile
    audioFile?.getDataInBackgroundWithBlock { (audioData, error) -> Void in
        if error == nil {
            self.audioPlayer = try? AVAudioPlayer(data: audioData!)
            self.audioPlayer?.delegate = self
            print("message duration: \(self.audioPlayer!.duration)")
            self.audioPlayer?.play()
            
            // Start timer (shows the progress of the message while playing)
            progress = 0
            let calcTime = self.audioPlayer!.duration * 0.004
            self.messTimer = NSTimer.scheduledTimerWithTimeInterval(calcTime, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
            
    } }
    
}

func updateTimer() {
    progress = progress + 1
    let normalizedProgress = Double(progress) / 255.0
    circularProgress.progress = normalizedProgress
    
    // Timer ends
    if normalizedProgress >= 1.01 {  messTimer.invalidate()  }
}
    
func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    audioPlayer = nil
    messTimer.invalidate()
    circularProgress.removeFromSuperview()
    
    for var i = 0;  i < chatsArray.count;  i++ {
        let indexP = NSIndexPath(forRow: i, inSection: 0)
        let cell = chatsTableView.cellForRowAtIndexPath(indexP) as! ChatCell
        cell.playOutlet.setBackgroundImage(UIImage(named: "playButt"), forState: UIControlState.Normal)
    }
}
    
    
    
// MARK: - RECORD BUTTON
func recButt(sender:UIButton) {
    if PFUser.currentUser() != nil {
        let recVC = self.storyboard?.instantiateViewControllerWithIdentifier("Record") as! Record
        recVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        presentViewController(recVC, animated: true, completion: nil)

    } else {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        presentViewController(loginVC, animated: true, completion: nil)
    }
}
    
    
  
// MARK: - SEND AUDIO MESSAGE
func sendAudioMessage(urlStr: String) {
    view.showHUD(view)
    
    let chatsClass = PFObject(className: CHAT_CLASS_NAME)
    let currentUser = PFUser.currentUser()
        
    // Save PFUser as a Pointer
    chatsClass[CHAT_USER_POINTER] = currentUser
        
    // Save data
    chatsClass[CHAT_ROOM_NAME] = theRoomName
    let currentDate = NSDate()
    chatsClass[CHAT_SENT_DATE] = currentDate
    
    let audioURL = NSURL(string: audioURLStr)
    let audioData = NSData(contentsOfURL: audioURL!)!
    print("AUDIO DATA 2: \(audioData.length)")
    let audioFile = PFFile(name: "sound.mp3", data: audioData)
    chatsClass[CHAT_MESSAGE] = audioFile
    
    // Saving block
    chatsClass.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            audioURLStr = ""
            self.loadChats()
            hudView.removeFromSuperview()
            
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "\(error!.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            hudView.removeFromSuperview()
        } }
}
    
    
    


    

    
// MARK: - iAd + AdMob BANNER METHODS
    
    // Initialize Apple iAd banner
    func initiAdBanner() {
        iAdBannerView = ADBannerView(frame: CGRectMake(0, self.view.frame.size.height, 0, 0) )
        iAdBannerView.delegate = self
        iAdBannerView.hidden = true
        view.addSubview(iAdBannerView)
    }
    
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(320, 50))
        adMobBannerView.frame = CGRectMake(0, self.view.frame.size.height, 320, 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
    }
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        // Hide the banner moving it below the bottom of the screen
        banner.frame = CGRectMake(0, self.view.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = true
        
    }
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRectMake(0, self.view.frame.size.height - banner.frame.size.height - 44,
            banner.frame.size.width, banner.frame.size.height);
        UIView.commitAnimations()
        banner.hidden = false
        
    }
    
    // iAd banner available
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        print("iAd loaded!")
        hideBanner(adMobBannerView)
        showBanner(iAdBannerView)
    }
    
    // NO iAd banner available
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("iAd can't looad ads right now, they'll be available later")
        hideBanner(iAdBannerView)
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
    }
    
    
    // AdMob banner available
    func adViewDidReceiveAd(view: GADBannerView!) {
        print("AdMob loaded!")
        hideBanner(iAdBannerView)
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}
