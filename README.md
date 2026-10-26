# TryOn — Virtual Try-On & AR Commerce (Flutter)

A high-performance Flutter mobile application for **on-device selfie segmentation**, **interactive 2D matrix canvas try-on**, **ARCore / ARKit live garment placement**, and **Shopify / Storefront commerce with affiliate attribution**.

Fully configured with cross-platform availability for **Android** and **iPhone (iOS)**.

---

## 1. Architecture Overview (Feature-First / Domain-Driven)

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp.router with ThemeMode
│   ├── routes.dart                # GoRouter route declarations & persistent Shell navbar
│   └── theme.dart                 # Dark/light luxury & streetwear fashion aesthetic
├── core/
│   ├── constants/                 # Assets, storage boxes, routes, affiliate defaults
│   ├── errors/                    # AppException hierarchy & domain Failure definitions
│   ├── services/
│   │   ├── camera_service.dart    # Camera controller & frame acquisition
│   │   ├── deep_link_service.dart # Inbound universal links (tryon://, https://fitpreview.com)
│   │   └── storage_service.dart   # Hive local storage abstraction
│   └── utils/                     # Matrix4 decomposition/serialization, alpha mask blending
└── features/
    ├── segmentation/              # ML Kit Selfie Segmentation pipeline
    │   ├── data/
    │   │   ├── cutout_engine.dart         # Google ML Kit segmenter + procedural fallback
    │   │   └── segmentation_repository.dart # Camera/Gallery image picker orchestration
    │   ├── domain/models/person_cutout.dart
    │   └── presentation/controllers/
    ├── try_on/                    # 2D Interactive Canvas Compositing Engine
    │   ├── domain/models/overlay_transform.dart
    │   └── presentation/
    │       ├── controllers/try_on_controller.dart
    │       ├── screens/try_on_workspace_screen.dart
    │       └── widgets/
    │           ├── interactive_clothing_canvas.dart # InteractiveViewer + Matrix4
    │           ├── layer_control_toolbar.dart       # Layer ordering, opacity, reset
    │           └── outfit_preview_modal.dart        # Snapshot export & direct buy
    ├── ar_overlay/                # Live AR Viewport (ARCore / ARKit)
    │   ├── domain/models/ar_anchor_model.dart
    │   └── presentation/screens/ar_live_view_screen.dart # Plane detection & hanger anchor
    ├── catalog/                   # Retail Storefront & Affiliate Attribution
    │   ├── data/
    │   │   ├── shopify_client.dart    # Storefront GraphQL client & permalinks
    │   │   ├── affiliate_tracker.dart # Parameter injection (?ref=fitpreview&subid=xyz)
    │   │   └── mock_catalog_data.dart # Sample garments & in-store barcodes
    │   ├── domain/models/product.dart
    │   └── presentation/
    │       ├── controllers/catalog_controller.dart
    │       └── screens/
    │           ├── catalog_screen.dart
    │           ├── product_detail_screen.dart
    │           └── barcode_scanner_screen.dart # ML Kit barcode reader
    └── wishlist/                  # Outfits & Saved Looks (Hive)
        ├── data/wishlist_repository.dart
        ├── domain/models/wishlist_item.dart
        └── presentation/
            ├── controllers/wishlist_controller.dart
            └── screens/wishlist_screen.dart
```

---

## 2. Android Availability & Configuration

The Android platform configuration is located in `android/`:
- **`AndroidManifest.xml`**:
  - `android.permission.CAMERA`: Live selfie segmentation and tag scanning.
  - `android.permission.INTERNET`: Storefront API and affiliate click recording.
  - `android.permission.READ_MEDIA_IMAGES` / storage permissions.
  - `com.google.ar.core` metadata declared as `optional` (allows devices without ARCore hardware to install and run 2D try-on seamlessly).
  - Intent filters for custom scheme (`tryon://product/{id}`) and Universal App Links (`https://fitpreview.com`).
- **`android/app/build.gradle`**:
  - `minSdkVersion 24` (required by Google ML Kit and ARCore).
  - `compileSdkVersion 34`, `targetSdkVersion 34`.
  - Multidex enabled.
  - ABI packaging rules preventing native library collisions.

### Run on Android
```bash
flutter run -d android
# Or build release APK:
flutter build apk --release
```

---

## 3. iPhone (iOS) Availability & Configuration

The iOS platform configuration is located in `ios/`:
- **`Info.plist`**:
  - `NSCameraUsageDescription`: "TryOn requires camera access for on-device selfie segmentation, in-store barcode scanning, and live AR placement."
  - `NSPhotoLibraryUsageDescription`: "TryOn requires photo library access to upload outfit photos for virtual try-on."
  - `NSPhotoLibraryAddUsageDescription`: "TryOn requires permission to save your composited outfit snapshots to your photo library."
  - `CFBundleURLTypes`: Custom URL scheme `tryon://` registered.
- **`ios/Podfile`**:
  - `platform :ios, '14.0'` (Required for Google ML Kit vision components and ARKit).
  - Post-install hook setting minimum deployment target and framework distribution flags.

### Run on iPhone / iOS Simulator
```bash
flutter run -d ios
# Or build iOS archive:
flutter build ipa
```

---

## 4. Key Capabilities & Flow

1. **Instant Try-On Canvas (Step 1)**:
   - Uses `InteractiveViewer` with `TransformationController`.
   - Pinch to scale, drag to translate, two-finger rotate.
   - Quick layer ordering toggle: drape clothes on top of silhouette or place silhouette on top.
   - Transparency / opacity slider.
   - Procedural mock silhouette generator for instant developer iteration without camera setup.

2. **On-Device ML Kit Vision (Step 2)**:
   - `google_mlkit_selfie_segmentation` runs single-mode selfie segmentation.
   - `ImageConverterUtils.applySegmentationMask` processes the confidence float buffer into an RGBA alpha mask with smoothed edges.

3. **In-Store Barcode Scanning (Step 3)**:
   - Point device at physical garment price tags (EAN-13, UPC, Code 128, QR).
   - Scans tag, matches product in cached catalog, and navigates straight into Try-On Studio.
   - Includes quick-test chips for physical and emulator testing without physical tags.

4. **AR Live View (Step 4)**:
   - `ar_flutter_plugin` detects horizontal and vertical planes (racks, hangers, walls).
   - Fallback simulated AR mode ensures flawless execution on simulators and non-AR devices.

5. **Commerce & Affiliate Attribution (Step 5)**:
   - Outgoing checkout actions are intercepted by `AffiliateTracker`.
   - Appends `?ref=fitpreview&subid=app_v1&click_id=<uuid>&source=tryon_flutter_app`.
   - Records telemetry event before launching in external browser via `url_launcher`.

6. **3D 360° Snap & Try Studio (Three.js WebGL & AR)**:
   - **Snap Real Clothing**: Take a photo of physical clothing on a hanger, bed, rack, or mannequin. `GarmentExtractorService` automatically isolates the garment from the background and encodes it into a 3D texture.
   - **Snap Person / Model**: Take a selfie or pick a picture of any person. `SegmentationRepository` extracts their silhouette.
   - **360° Orbit & Turntable**: Three.js WebGL engine renders a 3D humanoid mannequin wearing the mapped garment with interactive 360° orbital drag rotation, angle presets (Front 0°, Right 90°, Back 180°, Left 270°), and continuous rotation slider.
   - **Augmented Reality Passthrough**: Real-world camera background passthrough so you can see the 3D dressed avatar standing in your room or in-store space.

---

## 5. Running Tests

```bash
flutter test
```
Verifies:
- 2D/3D Matrix math, translation offsets, and viewport centering (`matrix_utils_test.dart`).
- Affiliate query parameter decoration and telemetry payload (`affiliate_tracker_test.dart`).
- Domain model JSON serialization and state persistence (`models_test.dart`).
