/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/

import UIKit
import Parse


class NewRoom: UIViewController,
UITextFieldDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate
{

    /* Views */
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var roomImage: UIImageView!
    
    
    /* Variables */
    
    
    
// Hide StatusBar
override func prefersStatusBarHidden() -> Bool {
        return true
}
    
override func viewDidLoad() {
        super.viewDidLoad()

}

  
    
// MARK: - CHANGE IMAGE BUTTON
@IBAction func changeImageButt(sender: AnyObject) {
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
        roomImage.image = image
    dismissViewControllerAnimated(true, completion: nil)
}

    
    
// CREATE ROOM BUTTON -> SAVE IT TO PARSE DATABASE
@IBAction func createRoomButt(sender: AnyObject) {
    view.showHUD(view)
    
    let roomsClass = PFObject(className: ROOMS_CLASS_NAME)
    let currentUser = PFUser.currentUser()
    
    // Save PFUser as a Pointer
    roomsClass[ROOMS_USER_POINTER] = currentUser
    
    // Save data
    roomsClass[ROOMS_NAME] = nameTxt.text!.uppercaseString
    
    // Save Image (if exists)
    if roomImage.image != nil {
        let imageData = UIImageJPEGRepresentation(roomImage.image!, 0.8)
        let imageFile = PFFile(name:"image.jpg", data:imageData!)
        roomsClass[ROOMS_IMAGE] = imageFile
    }
    
    // Saving block
    roomsClass.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            let alert = UIAlertView(title: APP_NAME,
            message: "Your new room has been created!",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            hudView.removeFromSuperview()
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "\(error!.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            hudView.removeFromSuperview()
        } }

    
}
    

// MARK: - TEXT FIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    nameTxt.resignFirstResponder()

return true
}
    
    
    
@IBAction func closeButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
