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

class ViewController: UIViewController, UINavigationControllerDelegate {
    var oauth2: OAuth2Module
    
    required init(coder aDecoder: NSCoder) {
        var keycloakConfig = Config(base: "http://192.168.0.37:8080/auth",
            authzEndpoint: "realms/shoot-realm/tokens/login",
            redirectURL: "org.aerogear.Shared://oauth2Callback",
            accessTokenEndpoint: "realms/shoot-realm/tokens/access/codes",
            clientId: "shoot-openid",
            refreshTokenEndpoint: "realms/shoot-realm/tokens/refresh",
            revokeTokenEndpoint: "realms/shoot-realm/tokens/logout")
        self.oauth2 = OAuth2Module(config: keycloakConfig, accountId:"myLogin", session: UntrustedMemoryOAuth2Session(accountId:"myLogin"))
        
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(sender: UIButton) {
        
        oauth2.requestAccess { (response: AnyObject?, error:NSError?) -> Void in
            if(error != nil) {
                println("ERROR:: \(error!)")
                return
            }
            var token = response as NSString
            println("token \(token)")
//            kc.tokenParsed = JSON.parse(decodeURIComponent(escape(window.atob( token.split('.')[1] ))));


            let string = token.componentsSeparatedByString(".")
            let secondPart = string[1] as NSString
            println(">>> \(secondPart)")
            
            var base64Decoded = self.decode(secondPart)

            
            println("decoded token \(base64Decoded)")
            
        }
        
    }
    func decode(encoded:NSString) -> NSString {
        var stringtoDecode:NSString = encoded.stringByReplacingOccurrencesOfString("-", withString: "+") // 62nd char of encoding
        stringtoDecode = stringtoDecode.stringByReplacingOccurrencesOfString("_", withString: "/") // 63rd char of encoding
        switch (stringtoDecode.length % 4) {
        case 2: stringtoDecode = "\(stringtoDecode)=="
        case 3: stringtoDecode = "\(stringtoDecode)="
        default: println("none")
        }
        let dataToDecode = NSData(base64EncodedString: stringtoDecode, options: .allZeros)
        let base64Decoded = NSString(data: dataToDecode, encoding: NSUTF8StringEncoding)
        return base64Decoded
    }
}

