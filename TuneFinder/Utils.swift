import SwiftUI

extension String {

     func localize(comment: String = "") -> String {
         let defaultLanguage = "zh-hk"
         let value = NSLocalizedString(self, comment: comment)
         if value != self || NSLocale.preferredLanguages.first == defaultLanguage {
             return value // String localization was found
         }

         guard let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj"), let bundle = Bundle(path: path) else {
             return value
         }

         return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
