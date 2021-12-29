//
//  Created by Thang Nguyen on 12/28/21.
//

import Foundation

import XLibrary

class AppHelper: IHelper {
	
	private static let TAG = "~🧰"
	
	internal class func buildUserActivitiesInfo(_ tag: String, _ err: inout [String: Any]) -> [String: Any] {
		var data: [String: Any] = Helper.buildUserActivitiesInfo(tag, &err)
		
		data["game_level"] = UserDefaults.standard.object(forKey: CommonConfig.Keys.gameLevel) as? Int
		
		NSLog("--> \(TAG) | build User Activities Info [\(tag)]: \(data)")
		
		return data
	}
}
