/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


import UIKit
import MobileCoreServices
import AssetsLibrary

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var overlayView: UIView?
    var imagePicker = UIImagePickerController()
    var newMedia: Bool = true
    var zoomImage = (camera: true, display: true)
    var keycloakURL:String = NSUserDefaults.standardUserDefaults().stringForKey("key_url") ?? ""

    @IBOutlet weak var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Let's register for settings update notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChangedNotification",
            name: NSUserDefaultsDidChangeNotification, object: nil)
        self.useCamera()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleSettingsChangedNotification() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let clear = userDefaults.boolForKey("clearShootKeychain")
        self.keycloakURL = userDefaults.stringForKey("key_url") ?? ""
        if clear {
            println("clearing keychain")
            let kc = KeychainWrap()
            kc.resetKeychain()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goToCamera(sender: UIButton) {
        self.useCamera()
    }
    
    @IBAction func takePicture(sender: UIBarButtonItem) {
        self.imagePicker.takePicture()
    }
    
    @IBAction func goToSettings(sender: AnyObject) {
        // iOS8 open Settings from your current app
        let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(settingsUrl!)
    }
    
    func useCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = NSArray(object: kUTTypeImage)
            imagePicker.allowsEditing = false
            
            // resize
            if (zoomImage.camera) {
                self.imagePicker.cameraViewTransform = CGAffineTransformScale(self.imagePicker.cameraViewTransform, 1.5, 1.5);
                self.zoomImage.camera = false
            }
            // custom camera overlayview
            imagePicker.showsCameraControls = false
            NSBundle.mainBundle().loadNibNamed("OverlayView", owner:self, options:nil)
            self.overlayView!.frame = imagePicker.cameraOverlayView!.frame
            imagePicker.cameraOverlayView = self.overlayView
            self.overlayView = nil

            self.presentViewController(imagePicker, animated:true, completion:{})
            newMedia = true
        } else {
            if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self;
                imagePicker.sourceType = .PhotoLibrary
                imagePicker.mediaTypes = NSArray(object: kUTTypeImage)
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated:true, completion:{})
                newMedia = false
            }
        }
    }
    
    @IBAction func shareWithFacebook() {
        SharingService.sharedService.shareWithFacebook(self.imageView.image!)
    }
    
    @IBAction func shareWithGoogleDrive() {
        SharingService.sharedService.shareWithGoogleDrive(self.imageView.image!)
    }
    
    @IBAction func shareWithKeycloak() {
        SharingService.sharedService.shareWithKeycloak(self.imageView.image!)
    }

    
    // MARK - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion:nil)
        var image: UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
        } else {
            var imageURL:NSURL = info[UIImagePickerControllerReferenceURL] as NSURL
            var assetslibrary = ALAssetsLibrary()
            assetslibrary.assetForURL(imageURL, resultBlock: {
                (asset: ALAsset!) in
                if asset != nil {
                    var assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                    self.imageView.accessibilityIdentifier = assetRep.filename()
                    self.imageView.image = image;
                }
            }, failureBlock: {
                (error: NSError!) in
                println("Error \(error)")
            })
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafePointer<Void>) {
        self.imageView.image = image;
        self.imageView.accessibilityIdentifier = "Untitled.jpg";
    
        if zoomImage.display {
            self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1.7, 1.7)
            self.zoomImage.display = false
        }
        if let error = didFinishSavingWithError {
            let alert = UIAlertView(title: "Save failed", message: "Failed to save image", delegate: nil, cancelButtonTitle:"OK", otherButtonTitles:"")
                alert.show()
        }
   }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func presentAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

