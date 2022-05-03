/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/


import UIKit

class TermsOfUse: UIViewController {

    /* Views */
    @IBOutlet var webView: UIWebView!
    
    
  
    
override func prefersStatusBarHidden() -> Bool {
        return true
}
override func viewDidLoad() {
        super.viewDidLoad()
    
    let url = NSBundle.mainBundle().URLForResource("tou", withExtension: "html")
    webView.loadRequest(NSURLRequest(URL: url!))

}

    
    
    
// DISMISS BUTTON
@IBAction func dismissButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
