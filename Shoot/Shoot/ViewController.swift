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

import AeroGearHttp
import AeroGearOAuth2

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var overlayView: UIView?
    var imagePicker = UIImagePickerController()
    var newMedia: Bool = true
    var http: Http!
    @IBOutlet weak var imageView: UIImageView!


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {

        super.viewDidLoad()

        // Let's register for settings update notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChangedNotification",
            name: NSUserDefaultsDidChangeNotification, object: nil)
        self.http = Http()
        self.useCamera()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func handleSettingsChangedNotification() {

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let clear = userDefaults.boolForKey("clearShootKeychain")

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
        if "".respondsToSelector(Selector("containsString:")) == true { // iOS8
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsUrl!)
        }
        // else in iOS7 no settings access via app, but available in device settings
    }

    func useCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = [kUTTypeImage]
            imagePicker.allowsEditing = false

            if "".respondsToSelector(Selector("containsString:")) == true { // iOS8
                // custom camera overlayview
                imagePicker.showsCameraControls = false
                NSBundle.mainBundle().loadNibNamed("OverlayView", owner:self, options:nil)
                self.overlayView!.frame = imagePicker.cameraOverlayView!.frame
                imagePicker.cameraOverlayView = self.overlayView
                self.overlayView = nil
            }

            self.presentViewController(imagePicker, animated:true, completion:{})
            newMedia = true
        } else {
            if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self;
                imagePicker.sourceType = .PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated:true, completion:{})
                newMedia = false
            }
        }
    }

    @IBAction func shareWithFacebook() {
        println("Perform photo upload with Facebook")
        let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"])
        //facebookConfig.isWebView = true
        let fbModule =  AccountManager.addFacebookAccount(facebookConfig)
        self.http.authzModule = fbModule

        self.performUpload("https://graph.facebook.com/me/photos",  parameters: self.extractImageAsMultipartParams())
    }
    
    class WebViewController: UIViewController, UIWebViewDelegate {
        /// Login URL for OAuth.
        var targetURL : NSURL?
        /// WebView intance used to load login page.
        var webView : UIWebView = UIWebView()
        var content: String?

        /// Overrride of viewDidLoad to load the login page.
        override internal func viewDidLoad() {
            super.viewDidLoad()
            
            webView.frame = UIScreen.mainScreen().applicationFrame
            webView.delegate = self
            self.view.addSubview(webView)
            loadAddressURL()
            loadContent()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            self.webView.frame = self.view.bounds
        }
        
        override internal func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        func loadAddressURL() {
            if let targetURL = targetURL {
            let req = NSURLRequest(URL: targetURL)
            webView.loadRequest(req)
            }
        }
        
        func loadContent() {
            if let content = content {
                webView.loadHTMLString(content, baseURL: nil)
            }
        }
    }

    @IBAction func shareWithGoogleDrive() {
        println("TEST SAML Keycloak example")
        //var webView = WebViewController()
        //webView.targetURL = NSURL(string: "http://192.168.0.10:8080/sales-post/")!
        //UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(webView, animated: true, completion: nil)
        
        let myHttp = Http(baseURL: nil, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration(), requestSerializer: HttpRequestSerializer(), responseSerializer: StringResponseSerializer())
        
        // step1: check if Oauthn is required
        // TODO
        
        // step2: (if required) ask for authn with a POST messages containing SAML Request
        myHttp.GET("http://localhost:8080/auth/realms/saml-demo/protocol/saml", parameters: ["SAMLRequest" : "jVLJbtswEP0VgXeaWixDISwDjt3FQFIYsZNDL8GYHtlEKVLlUGn796XkBk2AwuiNnHkzbyHnBK3p5LIPZ/uA33ukkPxsjSU5NmrWeysdkCZpoUWSQcnd8v5O5pNUdt4Fp5xhl5HrYCBCH7SzLFm+HlfOUt+i36F/0QofH+5q5vxpAujdCcFPdmfnghTCQRSYr8CYA6hvLFlHndrCsKNm5xC6iDFOgTk7CrJKq1QME8IjmJbE4IUfsXXiVfJYYslH5xWO5mvWgCFkyWZds836WZVYTAsseXFzSPk0Oxb8pmqAz1ShqqZRU8inEUzb6Eu/4N9xoh43lgLYULM8zUqeVjyf7bNclpnM8kk2K7+yZPtHyK22R21P17M7XEAkP+/3W/7pw54lT+hpdB/7bDEf7MiR2795v/99kcW/IyQwSLyLdzEXbxgudJ38Eldu1ltntPqVLI1xP1Yx8BDDCL7HMd0WwnURQ0UfeTNCZfBgSaMNTCwulO//5uI3"], credential: nil) { (obj:AnyObject?, err:NSError?) -> Void in
            // step3.: display login form
            if let err = err {
                println("Error \(err)")
                return
            }
            println("Success in asking login form")
            var webView = WebViewController()
            webView.content = obj as? String
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(webView, animated: true, completion: nil)
        }
    }

    @IBAction func shareWithKeycloak() {
        println("Perform photo upload with Keycloak")

        let keycloakHost = "http://localhost:8080"
        let keycloakConfig = KeycloakConfig(
            clientId: "shoot-third-party",
            host: keycloakHost,
            realm: "shoot-realm")
        //keycloakConfig.isWebView = true
        let gdModule = AccountManager.addKeycloakAccount(keycloakConfig)
        self.http.authzModule = gdModule
        self.performUpload("\(keycloakHost)/shoot/rest/photos", parameters: self.extractImageAsMultipartParams())

    }

    func performUpload(url: String, parameters: [String: AnyObject]?) {
        self.http.POST(url, parameters: parameters, completionHandler: {(response, error) in
            if (error != nil) {
                self.presentAlert("Error", message: error!.localizedDescription)
            } else {
                self.presentAlert("Success", message: "Successfully uploaded!")
            }
        })
    }

    // MARK - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion:nil)
        var image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
        } else {
            var imageURL:NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
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
            }
            )
        }
    }

    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafePointer<Void>) {
        self.imageView.image = image;
        self.imageView.accessibilityIdentifier = "Untitled.jpg";

        if let error = didFinishSavingWithError {
            let alert = UIAlertView(title: "Save failed", message: "Failed to save image", delegate: nil, cancelButtonTitle:"OK", otherButtonTitles:"")
                alert.show()
        }
   }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    func extractImageAsMultipartParams() -> [String: AnyObject] {
        // extract the image filename
        let filename = self.imageView.accessibilityIdentifier;

        let multiPartData = MultiPartData(data: UIImageJPEGRepresentation(self.imageView.image, 0.2),
            name: "image",
            filename: filename,
            mimeType: "image/jpg")

        return ["file": multiPartData]
    }

    func presentAlert(title: String, message: String) {
        if "".respondsToSelector(Selector("containsString:")) == true { // iOS8
            var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else { // iOS7 style
            let alert = UIAlertView()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
}

