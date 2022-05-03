/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/


import UIKit

class Settings: UIViewController {
    
    /* Views */
    @IBOutlet weak var tenMessSwitch: UISwitch!
    
    

    
override func viewDidLoad() {
        super.viewDidLoad()

    // Set the message limit swicth
    if tenMessLimit { tenMessSwitch.setOn(true, animated: false)
    } else { tenMessSwitch.setOn(false, animated: false) }

}

 
// MARK: - TELL A FRIEND BUTTON
@IBAction func tellAfriendButt(sender: AnyObject) {
    let messageStr = "Hi there, join \(APP_NAME) and let's chat together! \(APPSTORE_LINK)"
    let img = UIImage(named: "logo")
    
    let shareItems = [messageStr, img!]
    
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.presentPopoverFromRect(CGRectZero, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(), animated: true)
    } else {
        // iPhone
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}
    
    
    
// MARK: - RATE THE APP BUTTON
@IBAction func rateButt(sender: AnyObject) {
    let reviewURL = NSURL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(APP_ID)")
    UIApplication.sharedApplication().openURL(reviewURL!)
}
    
    
// MARK: - SWITCH CHANGES
@IBAction func messSwitchChanged(sender: AnyObject) {
    let sw = sender as! UISwitch
    
    if sw.on { tenMessLimit = true
    } else { tenMessLimit = false }
    
    // Save the state of the Switch
    NSUserDefaults.standardUserDefaults().setBool(tenMessLimit, forKey: "tenMessLimit")
}
    
    
// READ TERMS BUTTON
@IBAction func readTOUbutt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}
 
    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
