//
//  ShareViewController.swift
//  SharedExt
//
//  Created by Corinne Krych on 15/12/14.
//  Copyright (c) 2014 AeroGear. All rights reserved.
//

import UIKit
import Social
import Shoot

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        SharingService.sharedService.sha
        // 7
        self.extensionContext?.completeRequestReturningItems([], nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
