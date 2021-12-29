//
//  Created by Thang Nguyen on 10/30/21.
//

import UIKit

import XLibrary

class About: PopupView {
	
	private let TAG = "Ab"
	
	// @IBOutlet weak var appVersion: UILabel!
	
	@IBOutlet weak var webView: UIWebView!
	@IBOutlet var loadIndicator: UIActivityIndicatorView!
	
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		animationStyle = .fade
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		loadIndicator.hidesWhenStopped = true
		
		webView.delegate = self
		
		var errors: [String: Any] = [:]
		var jsonObj = try! Helper.buildBaseRequestBody(TAG, &errors, false)
		
		jsonObj["errors"] = !errors.isEmpty ? errors as Any : nil
		
		let components = createURLComponents("awakeFromNib")
		let url = components.url(relativeTo: URL(string: AppConfig.aboutURL)!)!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("ios", forHTTPHeaderField: "platform")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONSerialization.data(withJSONObject: jsonObj, options: [])
		webView.loadRequest(request)
	}
	
	private func createURLComponents(_ tag: String) -> URLComponents {
		var params: [String: String] = [:]
		params["tag"] = tag
		if let info = Bundle.main.infoDictionary {
			params["app-name"] = info["CFBundleDisplayName"] as? String
			params["app-version"] = info["CFBundleShortVersionString"] as? String
			params["app-version-code"] = info["CFBundleVersion"] as? String
		}
		params["device-id"] = try? KeychainItem.getUserIdentifier("\(tag)|device-info", AppConfig.keychainDeviceIdKey)
		
#if DEBUG
		params["env"] = "DEBUG"
#endif
		
		var components = URLComponents()
		components.queryItems = params.map {
			URLQueryItem(name: $0, value: $1)
		}
		
		return components
	}
}

extension About: UIWebViewDelegate {
	
	func webViewDidStartLoad(_ webView: UIWebView) {
		// print("--  \(TAG) | webViewDidStartLoad")
		loadIndicator.startAnimating()
	}
	
	func webViewDidFinishLoad(_ webView: UIWebView) {
		print("--  \(TAG) | webViewDidFinishLoad: \(webView.request?.url as Any? ?? "--")")
		loadIndicator.stopAnimating()
	}
	
	func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
		NSLog("!-  \(TAG) | webView: didFailLoadWithError: \(webView.request?.url as Any? ?? "--") | \(error)")
		loadIndicator.stopAnimating()
		
		if let html = Bundle.main.url(forResource: "about", withExtension: "html") {
			let components = createURLComponents("didFailLoadWithError")
			let url = components.url(relativeTo: html)!
			let request = URLRequest(url: url)
			webView.loadRequest(request)
		}
	}
}
