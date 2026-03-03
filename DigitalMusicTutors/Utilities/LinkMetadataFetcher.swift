import Foundation
import LinkPresentation
import UIKit

enum LinkMetadataFetcher {
    static func fetch(url: URL, completion: @escaping (String?, Data?) -> Void) {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            guard error == nil, let metadata else {
                completion(nil, nil)
                return
            }

            let title = metadata.title
            var imageData: Data?

            if let imageProvider = metadata.imageProvider {
                imageProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        imageData = uiImage.jpegData(compressionQuality: 0.7)
                    }
                    completion(title, imageData)
                }
            } else {
                completion(title, nil)
            }
        }
    }
}
