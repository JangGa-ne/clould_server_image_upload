import RxSwift
import RxCocoa
import BSImagePicker
import Photos

extension Reactive where Base: UIViewController {
    
    // 1. 권한 요청
    func requestPhotoAuthorization() -> Single<PHAuthorizationStatus> {
        return Single.create { single in
            PHPhotoLibrary.requestAuthorization { status in
                single(.success(status))
            }
            return Disposables.create()
        }
    }

    // 2. 이미지 피커 프레젠트
    func presentImagePicker(max: Int = 1) -> Observable<[PHAsset]> {
        return Observable.create { [weak base] observer in
            let picker = ImagePickerController()
            picker.settings.selection.max = max
            picker.settings.theme.selectionStyle = (max > 1) ? .numbered : .checked
            picker.settings.fetch.assets.supportedMediaTypes = [.image]
            picker.settings.list.cellsPerRow = { _, _ in 4 }
            picker.settings.theme.backgroundColor = {
                if #available(iOS 13.0, *) { return .systemBackground }
                return .white
            }()
            
            base?.presentImagePicker(picker, select: nil, deselect: nil, cancel: {
                observer.onCompleted()
            }, finish: { assets in
                observer.onNext(assets)
                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    // 3. 이미지 추출 및 압축
    func imageData(from asset: PHAsset) -> Observable<(file_name: String, file_data: Data, file_size: Int)> {
        return Observable.create { observer in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 1024, height: 1024),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                let fileName = PHAssetResource.assetResources(for: asset).first?.originalFilename.lowercased() ?? ""
                guard let image = image else {
                    observer.onNext((file_name: fileName, file_data: Data(), file_size: 0))
                    observer.onCompleted()
                    return
                }

                let types: [(String, SDImageFormat)] = [
                    ("jpeg", .JPEG), ("jpg", .JPEG),
                    ("png", .PNG), ("heic", .HEIC),
                    ("heif", .HEIF)
                ]

                for (ext, format) in types where fileName.contains(ext) {
                    if let data = image.sd_imageData(as: format, compressionQuality: 0.3), data.count <= 25_165_824 {
                        observer.onNext((file_name: fileName, file_data: data, file_size: data.count))
                        observer.onCompleted()
                        return
                    }
                }

                observer.onNext((file_name: fileName, file_data: Data(), file_size: 0))
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }
}
