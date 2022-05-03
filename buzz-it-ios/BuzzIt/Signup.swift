/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/

import UIKit
import Parse

class Signup: UIViewController,
    UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    
    
   
  
override func prefersStatusBarHidden() -> Bool {
        return true
}

override func viewDidLoad() {
        super.viewDidLoad()
        
        containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 300)
        
        navigationController?.navigationBarHidden = true
}
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
// TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}
    
    
    
// MARK: - SIGNUP BUTTON
    @IBAction func signupButt(sender: AnyObject) {
        view.showHUD(view)
        
        let userForSignUp = PFUser()
        userForSignUp.username = usernameTxt.text!.lowercaseString
        userForSignUp.password = passwordTxt.text
        
        userForSignUp.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
            if error == nil { // Successful Signup
                self.dismissViewControllerAnimated(true, completion: nil)
                hudView.removeFromSuperview()
                
            } else { // No signup, something went wrong
                let alert = UIAlertView(title: APP_NAME,
                    message: "\(error!.localizedDescription)",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
                hudView.removeFromSuperview()
            }
        }
        
    }
    
    
    
// MARK: -  TEXTFIELD DELEGATE */
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt {   passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {   passwordTxt.resignFirstResponder()  }
    
return true
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

