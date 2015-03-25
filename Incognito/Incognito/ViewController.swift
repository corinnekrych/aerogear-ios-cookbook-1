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

import AeroGearOAuth1
import AeroGearHttp

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hatImage: UIImageView!
    @IBOutlet weak var glassesImage: UIImageView!
    @IBOutlet weak var moustacheImage: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Gesture Action
    
    @IBAction func move(recognizer: UIPanGestureRecognizer) {
        //return
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    @IBAction func pinch(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform,
            recognizer.scale, recognizer.scale)
        recognizer.scale = 1
    }
    
    @IBAction func rotate(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        recognizer.rotation = 0

    }
    
    // MARK: - Menu Action
    
    @IBAction func openCamera(sender: AnyObject) {
        openPhoto()
    }
    
    @IBAction func hideShowHat(sender: AnyObject) {
        hatImage.hidden = !hatImage.hidden
    }
    
    @IBAction func hideShowGlasses(sender: AnyObject) {
        glassesImage.hidden = !glassesImage.hidden
    }
    
    @IBAction func hideShowMoustache(sender: AnyObject) {
        moustacheImage.hidden = !moustacheImage.hidden
    }
    
    @IBAction func share(sender: AnyObject) {
       
        let config = OAuth1Config(accountId:"Twitter",
            base: "https://api.twitter.com/oauth/",
            requestTokenEndpoint: "request_token",
            authorizeEndpoint: "authorize",
            accessTokenEndpoint: "access_token",
            redirectURL: "org.aerogear.Incognito://oauth-callback/twitter",
            clientId: "YOUR_CLIENT_ID",
            clientSecret: "YOUR_CLIENT_SECRET")
        let oauth1 = OAuth1Module(config: config)

        var http = Http(requestSerializer: HttpRequestSerializer())
        http.authzModule = oauth1
        
        var parameters =  [String: AnyObject]()
        parameters["media"] = snapshot().base64EncodedStringWithOptions(nil)
        http.POST("https://upload.twitter.com/1.1/media/upload.json", parameters: parameters, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
            if let error = error {
                println("ERROR::\(error)")
            }
            let imageId = (response as NSDictionary)["media_id_string"] as String
            var unique = (NSUUID().UUIDString as NSString)
            var parameters =  [String: AnyObject]()
            parameters["status"] = "coucou \(unique)"
            parameters["media_ids"] = imageId
            http.POST("https://api.twitter.com/1.1/statuses/update.json", parameters: parameters, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    println("ERROR::\(error)")
                }
                println("TWEETED")
            })
        })

        
        /*
        var http = Http(requestSerializer: HttpRequestSerializer())
        http.authzModule = oauth1
        // Explicit call to requestAccess
        oauth1.requestAccess { (reposnse: AnyObject?, error: NSError?) -> Void in
            if let error = error {
                println("ERROR::\(error)")
                return
            }
            var parameters =  [String: AnyObject]()
            parameters["media"] = self.snapshot().base64EncodedStringWithOptions(nil)
            http.POST("https://upload.twitter.com/1.1/media/upload.json", parameters: parameters, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    println("ERROR::\(error)")
                    return
                }
                let imageId = (response as NSDictionary)["media_id_string"] as String
                var unique = (NSUUID().UUIDString as NSString)
                var parameters =  [String: AnyObject]()
                parameters["status"] = "coucou \(unique)"
                parameters["media_ids"] = imageId
                http.POST("https://api.twitter.com/1.1/statuses/update.json", parameters: parameters, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                    if let error = error {
                        println("ERROR::\(error)")
                        return
                    }
                    println("TWEETED")
                })
            })
        }
        */
        

    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    // MARK: - Private functions
    
    private func openPhoto() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func snapshot() -> NSData {
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(fullScreenshot, nil, nil, nil)
        return UIImageJPEGRepresentation(fullScreenshot, 0.5)
    }

}

