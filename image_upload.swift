import BSImagePicker
import Photos

func setPhoto(max: Int?, completionHandler: @escaping (([(file_name: String, file_data: Data, file_size: Int)]) -> Void)) {
    
    PHPhotoLibrary.requestAuthorization({ status in
        if (status == .authorized) {
            
            var photos: [(file_name: String, file_data: Data, file_size: Int)] = []
            
            let imagePicker = ImagePickerController()
            imagePicker.settings.selection.max = max ?? 1
            if (max ?? 1 > 1) {
                imagePicker.settings.theme.selectionStyle = .numbered
            } else {
                imagePicker.settings.theme.selectionStyle = .checked
            }
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
            if #available(iOS 13.0, *) { imagePicker.settings.theme.backgroundColor = .systemBackground } else { imagePicker.settings.theme.backgroundColor = .white }
            imagePicker.settings.list.cellsPerRow = { (verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in return 4 }
            self.presentImagePicker(imagePicker, select: nil, deselect: nil, cancel: nil) { assets in
                assets.forEach { asset in
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .aspectFill, options: options) { image, _ in
                        let file_name = (PHAssetResource.assetResources(for: asset).first?.originalFilename ?? "").lowercased()
                        guard let img = image else { return }
                        if (file_name.contains("jpeg") || file_name.contains("jpg")), let image = img.sd_imageData(as: .JPEG, compressionQuality: 0.3), image.count <= 26214400 {
                            photos.append((file_name: file_name, file_data: image, file_size: image.count))
                        } else if file_name.contains("png"), let image = img.sd_imageData(as: .PNG, compressionQuality: 0.3), image.count <= 26214400 {
                            photos.append((file_name: file_name, file_data: image, file_size: image.count))
                        } else if file_name.contains("heic"), let image = img.sd_imageData(as: .HEIC, compressionQuality: 0.3), image.count <= 26214400 {
                            photos.append((file_name: file_name, file_data: image, file_size: image.count))
                        } else if file_name.contains("heif"), let image = img.sd_imageData(as: .HEIF, compressionQuality: 0.3), image.count <= 26214400 {
                            photos.append((file_name: file_name, file_data: image, file_size: image.count))
                        } else {
                            photos.append((file_name: file_name, file_data: Data(), file_size: 0))
                        }
                        if (assets.count == photos.count) { completionHandler(photos) }
                    }
                }
            }
        } else {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "\'App\'에서 \'설정\'을(를) 열려고 합니다.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    if let settingUrl = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(settingUrl) }
                }))
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    })
}