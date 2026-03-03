import Foundation
import UIKit

enum ImagePersistence {
    private static var appIconURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("app_icon.png")
    }

    static func saveAppIcon(data: Data) {
        try? data.write(to: appIconURL)
    }

    static func loadAppIcon() -> Data? {
        try? Data(contentsOf: appIconURL)
    }

    static func deleteAppIcon() {
        try? FileManager.default.removeItem(at: appIconURL)
    }
}
