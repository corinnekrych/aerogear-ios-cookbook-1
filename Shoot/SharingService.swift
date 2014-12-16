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

public class SharingService {
    var keycloakURL:String = NSUserDefaults.standardUserDefaults().stringForKey("key_url") ?? ""
    var googleHttp: Http!
    var facebookHttp: Http!
    var keycloakHttp: Http!
    
    public required init() {
        self.googleHttp = Http()
        self.facebookHttp = Http()
        self.keycloakHttp = Http()
    }

    public class var sharedService: SharingService {
        struct Singleton {
            static let instance = SharingService()
        }
        return Singleton.instance
    }
    
    func shareWithFacebook(image: UIImage) {
        println("Perform photo upload with Facebook")
        let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"])
        
        let fbModule =  AccountManager.addFacebookAccount(facebookConfig)
        self.facebookHttp.authzModule = fbModule
        // Multipart Upload
        let multiPartData = MultiPartData(data: UIImageJPEGRepresentation(image, 0.2),
            name: "image",
            filename: "name.jpg",
            mimeType: "image/jpg")
        
        let parameters = ["file": multiPartData]
        self.facebookHttp.POST("https://graph.facebook.com/me/photos", parameters: parameters, completionHandler: {(response, error) in
            if (error != nil) {
                println("Error")
            } else {
                println("Success")
            }
        })
    }
    
    func shareWithGoogleDrive(image: UIImage) {
        println("Perform photo upload with Google")
        let googleConfig = GoogleConfig(
            clientId: "873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com",
            scopes:["https://www.googleapis.com/auth/drive"])
        let gdModule = AccountManager.addGoogleAccount(googleConfig)
        self.googleHttp.authzModule = gdModule
        // Multipart Upload
        let multiPartData = MultiPartData(data: UIImageJPEGRepresentation(image, 0.2),
            name: "image",
            filename: "name.jpg",
            mimeType: "image/jpg")
        
        let parameters = ["file": multiPartData]
        self.googleHttp.POST("https://www.googleapis.com/upload/drive/v2/files", parameters: parameters, completionHandler: {(response, error) in
            if (error != nil) {
                println("Error")
            } else {
                println("Success")
            }
        })
    }
    
    func shareWithKeycloak(image: UIImage) {
        println("Perform photo upload with Keycloak")
        if self.keycloakURL != "" {
            let keycloakConfig = KeycloakConfig(
                clientId: "shoot-third-party",
                host: "\(self.keycloakURL)",
                realm: "shoot-realm")
            
            let gdModule = AccountManager.addKeycloakAccount(keycloakConfig)
            self.keycloakHttp.authzModule = gdModule
            
            let multiPartData = MultiPartData(data: UIImageJPEGRepresentation(image, 0.2),
                name: "image",
                filename: "name.jpg",
                mimeType: "image/jpg")
            
            let parameters = ["file": multiPartData]
            self.keycloakHttp.POST("\(self.keycloakURL)/shoot/rest/photos", parameters: parameters, completionHandler: {(response, error) in
                if (error != nil) {
                    println("Error")
                } else {
                    println("Success")
                }
            })
        } else {
            println("Keycloak URL should be filled")
        }
    }
    

}

