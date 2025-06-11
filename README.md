# 📸 RxPhotoPicker

RxSwift 기반의 `BSImagePicker` + `PHAsset`을 활용한 iOS 다중 이미지 선택 및 압축 유틸리티

---

## 🧩 Features

- ✅ RxSwift로 처리하는 **사진 접근 권한 요청**
- ✅ `BSImagePicker` 기반 **멀티 이미지 선택**
- ✅ `PHAsset` → `UIImage` → **압축된 Data 변환**
- ✅ JPEG / PNG / HEIC / HEIF 포맷 자동 판별 및 처리
- ✅ 최대 용량 제한 (`25MB` 이하)

---

## 📦 Requirements

- iOS 11.0+
- Swift 5.0+
- Xcode 14+
- [BSImagePicker](https://github.com/mikaoj/BSImagePicker)
- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [SDWebImage](https://github.com/SDWebImage/SDWebImage)

---

## CocoaPods

pod 'BSImagePicker'
pod 'RxSwift'
pod 'RxCocoa'
pod 'SDWebImage'

---

## 🚀 Usage

<pre><code>let disposeBag = DisposeBag()

self.rx.requestPhotoAuthorization()
    .flatMap { status -&gt; Observable&lt;[PHAsset]&gt; in
        guard status == .authorized else {
            self.presentSettingsAlert()
            return .empty()
        }
        return self.rx.presentImagePicker(max: 5)
    }
    .flatMap { assets in
        Observable.from(assets)
            .flatMap { self.rx.imageData(from: $0) }
            .toArray()
            .asObservable()
    }
    .observe(on: MainScheduler.instance)
    .subscribe(onNext: { compressedImages in
        // [(file_name: String, file_data: Data, file_size: Int)]
        print("압축된 이미지 수: \(compressedImages.count)")
    })
    .disposed(by: disposeBag)</code></pre>

---

## 📘 Sample Alert (권한 거부 시)

<pre><code>func presentSettingsAlert() {
    let alert = UIAlertController(
        title: "'앱'에서 '설정'을 열려고 합니다.",
        message: "사진 접근 권한이 필요합니다.",
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    })
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    self.present(alert, animated: true)
}</code></pre>

---

🔒 License
MIT License
