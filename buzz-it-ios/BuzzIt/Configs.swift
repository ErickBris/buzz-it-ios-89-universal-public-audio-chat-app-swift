/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/


import Foundation
import UIKit



// YOU CAN CHANGE THE VALUE OF THE MAX. DURATION OF A RECORDING (PLEASE NOTE THAT HIGHER VALUES MAY AFFET THE LOADING TIME OF POSTS)
let RECORD_MAX_DURATION: NSTimeInterval = 10.0

// YOU CAN CHANGE THE TIME WHEN THE APP WILL REFRESH THE CHATS (PLEASE NOTE THAT A LOW VALUE MAY AFFECT THE STABILITY OF THE APP, WE THINK 30 seconds A GOOD MINIMUM REFRESH TIME)
let REFRESH_TIME: NSTimeInterval = 30.0

// EDIT THE RED STRING BELOW ACCORDINGLY TO THE NEW NAME YOU'LL GIVE TO THIS APP
let APP_NAME = "BuzzIt"

// EDIT THE RED EMAIL ADDRESS BELOW ACCORDINGLY TO THE ONE YOU'LL DEDICATE TO ALLOW USERS TO REPORT INAPPROPRIATE CONTENTS
let REPORT_EMAIL_ADDRESS = "report@example.com"


// REPLACE THE RED STRING BELOW WITH YOUR OWN BANNER UNIT ID YOU'VE GOT ON http://apps.admob.com
let ADMOB_UNIT_ID = "ca-app-pub-9733347540588953/7805958028"

// REPLACE THE RED STRING BELOW WITH THE LINK TO YOUR OWN APP (You can find it on iTunes Connect, click More -> View on the App Store)
let APPSTORE_LINK = "https://itunes.apple.com/app/id957290825"

// REPLACE THE RED STRING BELOW WITH YOUR APP ID (still on iTC, click on More -> About this app)
let APP_ID = "957290825"




// HUD View
let hudView = UIView(frame: CGRectMake(0, 0, 80, 80))
let indicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
extension UIView {
    func showHUD(view: UIView) {
        hudView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2)
        hudView.backgroundColor = UIColor.darkGrayColor()
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = hudView.bounds.size.width/2
        
        indicatorView.center = CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
}




// PARSE KEYS --------------------------------------------------------------
let PARSE_APP_KEY = "v1QXGjNBpYQ2jNkGjvHPIUm2ZPzO1p9HghQKzhXs"
let PARSE_CLIENT_KEY = "7z9n297YE8fBWsctPCEuNTPlePxUyA88BhRQoEBV"


/* USER CLASS */
let USER_CLASS_NAME = "User"
let USER_USERNAME = "username"
let USER_AVATAR = "avatar"

/* CHAT ROOMS CLASS */
let CHAT_CLASS_NAME = "ChatRooms"
let CHAT_USER_POINTER = "userPointer"
let CHAT_ROOM_NAME = "name"
let CHAT_MESSAGE = "message"
let CHAT_SENT_DATE = "sent"

/* ROOMS CLASS */
let ROOMS_CLASS_NAME = "Rooms"
let ROOMS_NAME = "name"
let ROOMS_IMAGE = "image"
let ROOMS_USER_POINTER = "userPointer"



/* UNEDITABLE VARIABLES */
var theRoomName = ""
var audioURLStr = ""
var tenMessLimit = NSUserDefaults.standardUserDefaults().boolForKey("tenMessLimit")

