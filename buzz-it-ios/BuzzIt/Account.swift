/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox
import iAd


class Account: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate,
GADBannerViewDelegate,
ADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    
    @IBOutlet weak var myRoomsTableView: UITableView!
    
    //Ad banners properties
    var iAdBannerView = ADBannerView()
    var adMobBannerView = GADBannerView()
    
    
    
    
    /* Variables */
    var userArray = NSMutableArray()
    var roomsArray = NSMutableArray()
    
    
  
 
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Round views corners
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    userView.layer.cornerRadius = 8
    myRoomsTableView.layer.cornerRadius = 8
    myRoomsTableView.layer.borderColor = UIColor.whiteColor().CGColor
    myRoomsTableView.layer.borderWidth = 1.5
    
    
    // Init ad banners
    initiAdBanner()
    initAdMobBanner()
}

    
override func viewWillAppear(animated: Bool) {
    
    // QUERY CURRENT USER (IF LOGGED IN)
    if PFUser.currentUser() != nil {
        userArray.removeAllObjects()
        
        let query = PFUser.query()
        query?.whereKey(USER_USERNAME, equalTo: PFUser.currentUser()!.username!)
        query?.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects /* as! [PFObject] */ {
                    for object in objects {
                        self.userArray.addObject(object)
                    } }
                // Pupolate TextFiled
                self.showUserDetails()
                
            } else {
                let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK" )
                alert.show()
            } }
    
        
    // USER IS NOT LOGGED IN/REGISTERED
    } else {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
}

func showUserDetails() {
    var user = PFObject(className: USER_CLASS_NAME)
    user = userArray[0] as! PFUser
    
    // Get image
    let imageFile = user[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.avatarImage.image = UIImage(data:imageData)
    } } }
    
    // get username
    usernameTxt.text = "\(user[USER_USERNAME]!)"
    

    
    // Call a query for your rooms
    queryMyRooms()
}
    
    
    
    
// MARK: - QUERY THE ROOMS YOU'VE CREATED (IF ANY)
func queryMyRooms() {
    roomsArray.removeAllObjects()
    
    let query = PFQuery(className: ROOMS_CLASS_NAME)
    query.whereKey(ROOMS_USER_POINTER, equalTo: PFUser.currentUser()!)
    query.includeKey(USER_CLASS_NAME)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects /* as? [PFObject] */ {
                for object in objects {
                    self.roomsArray.addObject(object)
                } }
            // Reload a TableView
            self.myRoomsTableView.reloadData()
            
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "\(error!.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        } }
    
}
    
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
    
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return roomsArray.count
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MyRoomsCell", forIndexPath: indexPath) as! MyRoomsCell
    
    var myRoomsClass = PFObject(className: ROOMS_CLASS_NAME)
    myRoomsClass = roomsArray[indexPath.row] as! PFObject
    
    // Get data
    cell.rTitle.text = "\(myRoomsClass[ROOMS_NAME]!)"
    
    // Get image
    let imageFile = myRoomsClass[ROOMS_IMAGE] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.rImage.image = UIImage(data:imageData)
    } } }
    cell.rImage.layer.cornerRadius = 5
    
    
return cell
}
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
}


// MARK: -  CELL HAS BEEN TAPPED -> GO TO THE SELECTED CHAT ROOM
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! MyRoomsCell
    
    let cVC = storyboard?.instantiateViewControllerWithIdentifier("Chats") as! Chats
    theRoomName = "\(cell.rTitle!.text!)"
    navigationController?.pushViewController(cVC, animated: true)
}


// MARK: - DELETE ROW BY SWIPING THE CELL LEFT
func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
}
func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if editingStyle == UITableViewCellEditingStyle.Delete {
        
        var roomsClass = PFObject(className: ROOMS_CLASS_NAME)
        roomsClass = roomsArray[indexPath.row] as! PFObject
        
        // Deleting block
        roomsClass.deleteInBackgroundWithBlock {(success, error) -> Void in
            if error == nil {
                // Remove the swiped cell
                self.roomsArray.removeObjectAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                let alert = UIAlertView(title: APP_NAME,
                    message: "\(error!.localizedDescription)",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                alert.show()
            } }
    }
        
}
    
    
    

 
    
// MARK: - EDIT AVATAR BUTTON
@IBAction func editAvatarButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
        message: "Select source",
        delegate: self,
        cancelButtonTitle: "Cancel",
        otherButtonTitles: "Camera", "Photo Library")
    alert.show()
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Camera" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
            
        } else if alertView.buttonTitleAtIndex(buttonIndex) == "Photo Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
    }
    
}
// ImagePicker delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        avatarImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
}
  
 
    
    
    
// MARK: -  UPDATE PROFILE BUTTON
@IBAction func updateProfileButt(sender: AnyObject) {
    view.showHUD(view)
    let updatedUser = PFUser.currentUser()
    
    updatedUser?.setObject(usernameTxt.text!, forKey: USER_USERNAME)
    
    // Save Image (if exists)
    if avatarImage.image != nil {
        let imageData = UIImageJPEGRepresentation(avatarImage.image!, 0.5)
        let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
        updatedUser?.setObject(imageFile, forKey: USER_AVATAR)
    }
    
    // Saving block
    updatedUser!.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            let alert = UIAlertView(title: APP_NAME,
            message: "Your Profile has been updated!",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            hudView.removeFromSuperview()
            self.usernameTxt.resignFirstResponder()
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "\(error!.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            hudView.removeFromSuperview()
            self.usernameTxt.resignFirstResponder()
        } }

}

  
// MARK: - TEXT FIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    usernameTxt.resignFirstResponder()

return true
}

    
    
  
// MARK: - MAKE A NEW ROOM BUTTON
@IBAction func newRoomButt(sender: AnyObject) {
    let nrVC = self.storyboard?.instantiateViewControllerWithIdentifier("NewRoom") as! NewRoom
    nrVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    presentViewController(nrVC, animated: true, completion: nil)
}
  
    

// MARK: - SETTINGS BUTTON
@IBAction func settingsButt(sender: AnyObject) {
    let settVC = self.storyboard?.instantiateViewControllerWithIdentifier("Settings") as! Settings
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad { // iPad
        let popOver = UIPopoverController(contentViewController: settVC)
        settVC.preferredContentSize = CGSizeMake(view.frame.size.width-320, view.frame.size.height-450)
        popOver.presentPopoverFromRect(CGRectMake(400, 400, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(), animated: true)
    } else { // iPhone
        presentViewController(settVC, animated: true, completion: nil)
    }
    

}
    
    
    
    
    
// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(sender: AnyObject) {
    PFUser.logOut()
    
    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
    presentViewController(loginVC, animated: true, completion: nil)
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
