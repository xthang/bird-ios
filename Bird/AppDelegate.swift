//
//  AppDelegate.swift
//  Bird
//
//  Created by Thang Nguyen on 12/28/21.
//

import UIKit
import StoreKit

import XLibrary

@main
class AppDelegate: BaseAppDelegate {
	
	private static let TAG = "☯️"
	private let TAG = "☯️"
	
	
	override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		Helper.appHelper = AppHelper.self
		
		let x = super.application(application, didFinishLaunchingWithOptions: launchOptions)
		
		// AppConfig.initiate()
		
		_ = Payment.shared
		_ = AdsStore.shared
		// _ = Store.shared
		
		// update app data on new version update
		let appVersion = Helper.appVersion
		let appDataVersion = Helper.appDataVersion
		if appDataVersion != appVersion {
			NSLog("*******  \(TAG) | welcome to our new app / version update | old version: \(appDataVersion ?? "--") | new version: \(appVersion)")
			
			UserDefaults.standard.set(appVersion, forKey: CommonConfig.Keys.appDataVersion)
		}
		
		return x
	}
	
	override func applicationWillTerminate(_ application: UIApplication) {
		super.applicationWillTerminate(application)
		
		SKPaymentQueue.default().remove(Payment.shared)
	}
}
