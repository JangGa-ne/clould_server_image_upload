# clould_server_image_upload

<h1>📸 <code>setPhoto(max:completionHandler:)</code> Function Documentation</h1>

<p>
  <code>setPhoto</code> 함수는 iOS 기기 내의 사진 라이브러리에서 사용자로부터 이미지를 선택받고,
  선택된 이미지를 압축 후 가공하여 <code>(file_name, file_data, file_size)</code> 형태의 배열로 반환하는 비동기 함수입니다.
  <code>BSImagePicker</code>와 <code>Photos</code> 프레임워크를 활용하여 다중 이미지 선택, 권한 처리, 이미지 포맷 변환을 수행합니다.
</p>

<h2>📌 함수 정의</h2>
<pre><code>func setPhoto(
  max: Int?,
  completionHandler: @escaping (
    [(file_name: String, file_data: Data, file_size: Int)]
  ) -> Void
)</code></pre>

<h3>매개변수</h3>
<ul>
  <li><strong>max</strong>: 선택할 수 있는 최대 이미지 수. <code>nil</code>일 경우 기본값 1개.</li>
  <li><strong>completionHandler</strong>: 이미지 선택 및 처리 완료 시 호출되는 클로저.
    반환 형식은 <code>(file_name, file_data, file_size)</code> 튜플의 배열.
  </li>
</ul>

<h2>🛠 주요 동작 순서</h2>
<ol>
  <li>
    <strong>사진 라이브러리 접근 권한 요청</strong><br>
    <code>PHPhotoLibrary.requestAuthorization()</code> 사용.
    승인이 아닐 경우 설정 앱으로 유도하는 Alert 표시.
  </li>
  <li>
    <strong>이미지 선택기 구성 (<code>BSImagePicker</code>)</strong><br>
    <ul>
      <li><code>max</code> 값에 따라 다중/단일 선택 UI 설정.</li>
      <li>선택 스타일: `.numbered` 또는 `.checked`.</li>
      <li>다크모드 대응: iOS 13+ 은 <code>.systemBackground</code>, 그 외는 흰색.</li>
      <li>썸네일 그리드: 한 행당 4개 셀 배치.</li>
    </ul>
  </li>
  <li>
    <strong>이미지 선택 후 처리</strong><br>
    <ul>
      <li><code>PHImageManager</code>로 각 <code>PHAsset</code>의 이미지 요청 (<code>requestImage</code>).</li>
      <li>이미지를 1024×1024로 리사이징 & 압축하여 <code>Data</code> 변환.</li>
      <li>파일명 확장자에 따라 <code>SDWebImage</code>를 활용해 JPEG/PNG/HEIC/HEIF 형식으로 압축 (quality: 0.3).</li>
      <li>파일 크기가 25MB (26,214,400 바이트) 이하인 경우에만 결과에 포함.</li>
    </ul>
  </li>
  <li>
    <strong>모든 이미지 처리 완료 시</strong><br>
    <code>completionHandler(photos)</code> 호출.
  </li>
</ol>

<h2>📁 반환 데이터 구조 예시</h2>
<pre><code>[
(
  file_name: "photo1.jpg",
  file_data: &lt;compressed binary data&gt;,
  file_size: 1_452_312
),
(
  file_name: "image2.png",
  file_data: &lt;compressed binary data&gt;,
  file_size: 2_231_234
)
]</code></pre>

<h2>⚠️ 권한 미허용 처리</h2>
<p>
  권한이 거부된 경우 설정 앱으로 이동할 수 있도록 Alert를 띄우고,
  <code>UIApplication.openSettingsURLString</code>를 통해 직접 설정 화면으로 유도합니다.
</p>

<h2>✅ 의존 라이브러리</h2>
<ul>
  <li><a href="https://github.com/mikaoj/BSImagePicker" target="_blank">BSImagePicker</a>:
    커스텀 다중 이미지 선택기</li>
  <li><a href="https://github.com/SDWebImage/SDWebImage" target="_blank">SDWebImage</a>:
    이미지 포맷 변환 및 압축</li>
</ul>

<h2>📌 주의사항</h2>
<ul>
  <li>
    <code>PHImageRequestOptions().isSynchronous = true</code> 설정으로 인해 메인 스레드에서 동기 처리.
    이미지가 많을 경우 UI 지연 가능. 필요 시 비동기 처리 권장.
  </li>
  <li>
    파일명 기반 확장자 판별 로직이 단순 구현이므로, 특수 파일명이나 대소문자 변형 시 보완 필요.
  </li>
</ul>
