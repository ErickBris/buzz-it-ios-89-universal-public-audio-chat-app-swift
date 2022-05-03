/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/


import UIKit
import Parse

class Login: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var logo: UIImageView!

    
    
    
override func prefersStatusBarHidden() -> Bool {
    return true
}

override func viewWillAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            dismissViewControllerAnimated(false, completion: nil)
        }
}
    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round views corners
        logo.layer.cornerRadius = logo.bounds.size.width/2
        
        containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 550)
        
        navigationController?.navigationBarHidden = true
}
    
    
    
// MARK: - LOGIN BUTTON
@IBAction func loginButt(sender: AnyObject) {
        passwordTxt.resignFirstResponder()
        
        view.showHUD(view)
        
        PFUser.logInWithUsernameInBackground(usernameTxt.text!, password:passwordTxt.text!.lowercaseString) {
            (user, error) -> Void in
            
            if user != nil { // Login successfull
                self.dismissViewControllerAnimated(true, completion: nil)
                hudView.removeFromSuperview()
                
            } else { // Login failed. Try again or SignUp
                let alert = UIAlertView(title: APP_NAME,
                    message: "\(error!.localizedDescription)",
                    delegate: self,
                    cancelButtonTitle: "Retry",
                    otherButtonTitles: "Sign Up")
                alert.show()
                
                hudView.removeFromSuperview()
            } }
}
    // AlertView delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Sign Up" {
            signupButt(self)
        }
        
        if alertView.buttonTitleAtIndex(buttonIndex) == "Reset Password" {
            PFUser.requestPasswordResetForEmailInBackground("\(alertView.textFieldAtIndex(0)!.text!)")
            showNotifAlert()
        }
    }
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("Signup") as! Signup
    signupVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    presentViewController(signupVC, animated: true, completion: nil)
}
    
    
    
    
// MARK: - TEXTFIELD DELEGATES
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTxt {
            passwordTxt.becomeFirstResponder()
        }
        if textField == passwordTxt  {
            passwordTxt.resignFirstResponder()
        }
        return true
}
    
    
    // TAP TO DISMISS KEYBOARD
    @IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
    }
    
    
// RESET PASSWORD BUTTON
@IBAction func resetPasswButt(sender: AnyObject) {
        let alert = UIAlertView(title: APP_NAME,
            message: "Type your email address you used to register.",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Reset Password")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
}
    
 
// NOTIFICATION ALERT FOR PASSWORD RESET
func showNotifAlert() {
    let alert = UIAlertView(title: APP_NAME,
    message: "You will receive an email shortly with a link to reset your password",
    delegate: nil,
    cancelButtonTitle: "OK")
    alert.show()
}
 
    
// OPEN TERMS OF USE
@IBAction func touButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad { // iPad
        let popOver = UIPopoverController(contentViewController: touVC)
        touVC.preferredContentSize = CGSizeMake(view.frame.size.width-320, view.frame.size.height-450)
        popOver.presentPopoverFromRect(CGRectMake(400, 400, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(), animated: true)
    } else { // iPhone
        presentViewController(touVC, animated: true, completion: nil)
    }
}
    

    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

