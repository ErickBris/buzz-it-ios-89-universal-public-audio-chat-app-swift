/*-------------------------

- BuzzIt -

created by FV iMAGINATION © 2015
All Rights reserved

-------------------------*/

import UIKit
import AVFoundation


class Record: UIViewController,
AVAudioRecorderDelegate,
AVAudioPlayerDelegate,
UIAlertViewDelegate
{

    /* Views */
    @IBOutlet weak var recContainerView: UIView!
    @IBOutlet weak var recordImg: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var circularProgress: KYCircularProgress!

    @IBOutlet weak var customAlertView: UIView!
    
    /* Variables */
    var recorder : AVAudioRecorder?
    var player : AVAudioPlayer?
    var recTimer = NSTimer()
    
    
    
    
// Hide the StatusBar
override func prefersStatusBarHidden() -> Bool {
    return true
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Move customAlertView out of the screen
    customAlertView.frame.origin.y = view.frame.size.height
    
    
    // Prepare the device for recording
    prepareRecorder()
    
}

// MARK: - PREPARE THE AUDIO RECORDER
func prepareRecorder() {
    let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let recordingName = "sound.caf"
    let pathArray = [dirPath, recordingName]
    let filePath = NSURL.fileURLWithPathComponents(pathArray)
    let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
        AVEncoderBitRateKey: 16,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100.0]
    print(filePath)
    
    let session = AVAudioSession.sharedInstance()
    do { try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
         recorder = try AVAudioRecorder(URL: filePath!, settings: recordSettings as! [String : AnyObject])
    } catch _ {  print("Error") }
    
    recorder!.delegate = self
    recorder!.meteringEnabled = true
    recorder!.prepareToRecord()
    
}
    

    
// MARK: - START RECORDING
override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    // Get the location of the finger touch on the screen
    let touch = touches.first
    let touchLocation = touch!.locationInView(self.recordImg)
    
    if CGRectContainsPoint(recordImg.frame, touchLocation) {
      if !recorder!.recording {
        progress = 0
        let calcTime = RECORD_MAX_DURATION * 0.004
        setupCircularProgress()
        recTimer = NSTimer.scheduledTimerWithTimeInterval(calcTime, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        recorder!.recordForDuration(RECORD_MAX_DURATION)
        
        // Set Info Label
        infoLabel.text = "Recording..."
        infoLabel.textColor = UIColor(red: 237.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0)

      }
    }
}



// MARK: - STOP RECORDING
override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if recorder!.recording {
        recorder!.stop()
        
        // reset info Label
        infoLabel.text = "Tap and hold to record"
        infoLabel.textColor = UIColor.darkGrayColor()
        
        // Check NSData out of the recorded audio
        let audioData = NSData(contentsOfURL: recorder!.url)!
        print("AUDIO DATA: \(audioData.length)")
        
        // Get recorded file's length in seconds
        let audioAsset = AVURLAsset(URL: recorder!.url, options: nil)
        let audioDuration: CMTime = audioAsset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        print("AUDIO DURATION: \(audioDurationSeconds)")
    }
    
  
}
    

    
// MARK: - SETUP CIRCULAR PROGRESS
func setupCircularProgress() {
    circularProgress = KYCircularProgress(frame: CGRectMake(0, 0, recContainerView.frame.size.width, recContainerView.frame.size.width))
    circularProgress.colors = [0xa4d22c, 0xa4d22c, 0xa4d22c, 0xa4d22c]
    circularProgress.center = recordImg.center
    circularProgress.lineWidth = 8
        
    circularProgress.progressChangedClosure({ (progress: Double, circularView: KYCircularProgress) in })
    recContainerView.addSubview(circularProgress)
    recContainerView.sendSubviewToBack(circularProgress)
}
    
func updateTimer() {
    progress = progress + 1
    let normalizedProgress = Double(progress) / 255.0
    circularProgress.progress = normalizedProgress
    // println("progress: \(normalizedProgress)")
        
    // Timer ends
    if normalizedProgress >= 1.01 {  recTimer.invalidate()  }
}
    
    
    
    
// MARK: - AUDIO RECORDER AND PLAYER DELEGATES
func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    showAlert()
    
    recTimer.invalidate()
    circularProgress.removeFromSuperview()
}
    
func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    showAlert()
}
    
   
    
    
// MARK: - DISMISS VIEW BUTTON
@IBAction func dismissButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
    
// MARK: - SHOW/HIDE CUSTOM ALERT VIEW
func showAlert() {
    customAlertView.layer.cornerRadius = 10
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.customAlertView.center.y = self.view.center.y
    }, completion: { (finished: Bool) in })
}
func hideAlert() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.customAlertView.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in })
}
 
    
// MARK: - CUSTOM ALERTVIEW BUTTONS:
@IBAction func alertButtons(sender: AnyObject) {
    let button = sender as! UIButton
    
    switch button.tag {
    // Replay your recorded message
    case 0:
        
        do {
            player = try AVAudioPlayer(contentsOfURL: recorder!.url)
            //(URL: filePath!, settings: recordSettings as! [String : AnyObject])
        } catch _ {
            print("Error")
        }
        
        player!.delegate = self
        player!.play()
        break
        
    // Send your message
    case 1:
        audioURLStr = "\(recorder!.url)"
        dismissViewControllerAnimated(true, completion: nil)
        break
        
    // Retake message
    case 2:
        hideAlert()
        break
    default:break }
    
    
    // Hide the customAlertView
    hideAlert()
}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}

