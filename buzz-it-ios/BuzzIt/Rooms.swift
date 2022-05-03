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



class Rooms: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
GADBannerViewDelegate,
ADBannerViewDelegate
{

   /* Views */
    @IBOutlet weak var roomsCollView: UICollectionView!
    
    
    //Ad banners properties
    var iAdBannerView = ADBannerView()
    var adMobBannerView = GADBannerView()
    

    
    /* Variables */
    var roomsArray = NSMutableArray()
    
    
    

override func viewWillAppear(animated: Bool) {
    
    // User is NOT logged in or registered
    if PFUser.currentUser() == nil {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        presentViewController(loginVC, animated: true, completion: nil)
    }
}

    
override func viewDidLoad() {
        super.viewDidLoad()
 
    
    // Init ad banners
    initiAdBanner()
    initAdMobBanner()

    // Call the query
    queryRooms()
}

    
// MARK: - QUERY ROOMS CLASS
func queryRooms() {
    roomsArray.removeAllObjects()
    
    let query = PFQuery(className: ROOMS_CLASS_NAME)
    query.orderByDescending("createAt")
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects {
                //objects as? [PFObject] {
                for object in objects {
                    self.roomsArray.addObject(object)
                } }
            // Reload CollView
            self.roomsCollView.reloadData()
            
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "\(error!.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        } }
}
    
    
    
    
// MARK: - COLLECTION VIEW DELEGATES
func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
}
func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return roomsArray.count
}

func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RoomCell", forIndexPath: indexPath) as! RoomCell
    
    var roomsClass = PFObject(className: ROOMS_CLASS_NAME)
    roomsClass = roomsArray[indexPath.row] as! PFObject
    
    // Get data
    let imageFile = roomsClass[ROOMS_IMAGE] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.roomImage.image = UIImage(data:imageData)
    } } }

    cell.nameLabel.text = "  \(roomsClass[ROOMS_NAME]!)"
    
    cell.layer.cornerRadius = 10
    
return cell
}

func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(view.frame.size.width/3, view.frame.size.width/3)
}

func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    var roomsClass = PFObject(className: ROOMS_CLASS_NAME)
    roomsClass = roomsArray[indexPath.row] as! PFObject
    
    theRoomName = "\(roomsClass[ROOMS_NAME]!)"

    let chatsVC = storyboard?.instantiateViewControllerWithIdentifier("Chats") as! Chats
    navigationController?.pushViewController(chatsVC, animated: true)
}
   

    
// MARK: - REFRESH ROOMS BUTTON
@IBAction func refreshButt(sender: AnyObject) {
    queryRooms()
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
