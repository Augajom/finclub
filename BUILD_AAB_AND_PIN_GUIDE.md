# 📱 คู่มือการจัดการ App Icon, ระบบรหัส PIN ข้ามเครื่อง และการ Build .aab (Release)

เอกสารนี้รวบรวมคู่มือทางเทคนิคสำหรับการพัฒนาและเผยแพร่แอป **Finclub** ครอบคลุม 3 หัวข้อหลัก:
1. การเปลี่ยนและสร้าง App Icon / Logo
2. สถาปัตยกรรมระบบรหัส PIN (สาเหตุที่ไม่จำข้ามเครื่อง & แนวทางการจัดเก็บใน Database)
3. ขั้นตอนการ Build ไฟล์ Android App Bundle (`.aab`) ด้วยตนเองทีละขั้นตอน

---

## 🎨 1. การเปลี่ยนและจัดการ App Icon (Logo)

### 1.1 ไฟล์ต้นฉบับ
- **ที่อยู่ไฟล์**: `assets/images/01_app_icon_512x512.png` (ขนาด 512x512 พิกเซล ตามมาตรฐาน Google Play และ Apple App Store)

### 1.2 การตั้งค่าใน `pubspec.yaml`
ระบบใช้แพ็กเกจ `flutter_launcher_icons` ในการสร้างไอคอนอัตโนมัติ:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/01_app_icon_512x512.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/01_app_icon_512x512.png"
```

### 1.3 คำสั่งสร้าง Icon ใหม่ (เมื่อมีการเปลี่ยนรูปภาพ)
หากในอนาคตต้องการเปลี่ยนรูปไอคอน ให้วางไฟล์ภาพทับที่เดิม หรือระบุ path ใหม่ แล้วรันคำสั่ง:
```powershell
dart run flutter_launcher_icons
```
ระบบจะสร้างไฟล์ไอคอนทุกความละเอียดให้อัตโนมัติ:
- **Android**: `android/app/src/main/res/mipmap-mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`
- **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset`

---

## 🔐 2. สถาปัตยกรรมระบบรหัส PIN (การทำงานข้ามเครื่อง & การเก็บใน Database)

### 2.1 ทำไมล็อกอินในอีกเครื่องแล้วไม่จำ PIN เดิม?
จากการตรวจสอบโค้ดปัจจุบันใน [session_service.dart](file:///C:/app/fintech/lib/core/services/session_service.dart):
```dart
// โค้ดปัจจุบัน: บันทึกลง Local Storage ของเครื่องนั้นๆ
await _prefs.setString('user_pin_code_hash', pin);
```
- **พฤติกรรม**: การจัดเก็บในปัจจุบันใช้ `SharedPreferences` ซึ่งเป็นหน่วยความจำภายในเครื่อง (Local Storage)
- **ผลลัพธ์**: เมื่อนำบัญชีเดิมไปล็อกอินใน **เครื่องที่ 2** เครื่องใหม่จะไม่มีค่าใน `SharedPreferences` ส่งผลให้ฟังก์ชัน `hasPin()` คืนค่าเป็น `false` แอปจึงเปิดหน้า `PinSetupScreen` เพื่อให้ผู้ใช้ตั้งรหัส PIN ใหม่ของเครื่องนั้นเสมอ

---

### 2.2 เปรียบเทียบแนวทางการออกแบบระบบ PIN

| มิติการเปรียบเทียบ | แนวทางที่ 1: Device PIN (ประจำเครื่อง) | แนวทางที่ 2: Account PIN (ผูกกับบัญชีผู้ใช้) |
| :--- | :--- | :--- |
| **ตัวอย่างแอปที่ใช้** | **LINE, Telegram, แอปสมุดโน้ต / App Lock** | **Mobile Banking (K PLUS, SCB EASY, TrueMoney, Krungthai NEXT)** |
| **ตำแหน่งที่บันทึก** | อยู่ในเครื่องผู้ใช้เท่านั้น (`SharedPreferences` / `FlutterSecureStorage`) | บันทึกใน **Database (MySQL)** บนเซิร์ฟเวอร์ |
| **การใช้งานข้ามเครื่อง** | แต่ละเครื่องตั้งรหัสแยกกันได้ ย้ายเครื่องต้องตั้งใหม่ | ล็อกอินเครื่องไหนก็ใช้รหัส PIN เดิมชุดเดียวกัน |
| **ความปลอดภัย (Security)** | รหัส PIN ไม่หลุดออกจากเครื่อง เซิร์ฟเวอร์ไม่ล่วงรู้รหัส | ต้องมีมาตรการความปลอดภัยบน Backend สูงมาก (ต้อง Hash ด้วย `bcrypt`) |
| **ความซับซ้อนในการพัฒนา** | ไม่ต้องแก้ Backend ไม่ต้องมี API เพิ่มเติม | ต้องเพิ่มฟิลด์ใน DB และสร้าง API ตรวจสอบ/ตั้งรหัส PIN |

---

### 2.3 ข้อแนะนำและขั้นตอนหากต้องการบันทึก PIN ใน Database (แบบ Mobile Banking)

หากต้องการให้ผู้ใช้ตั้ง PIN ครั้งเดียวแล้วจำได้ทุกเครื่อง ควรปรับปรุงระบบดังนี้:

#### 1) ปรับปรุงฐานข้อมูล (MySQL Schema)
เพิ่มคอลัมน์ในตาราง `users`:
```sql
ALTER TABLE users ADD COLUMN pin_hash VARCHAR(255) NULL AFTER password_hash;
```

#### 2) มาตรการความปลอดภัยขั้นวิกฤต (Critical Security Rules)
> [!CAUTION]
> **ห้ามบันทึกเลข PIN 6 หลักตรงๆ (Plaintext) ลงใน Database เด็ดขาด**
> ต้องทำ Hash ด้วยอัลกอริทึมทางเดียว เช่น **`bcrypt`** (ความปลอดภัยระดับเดียวกับรหัสผ่านหลัก) บนฝั่ง Backend เสมอ

#### 3) ออกแบบ API ฝั่ง Backend (Node.js)
- **`POST /api/auth/login`**:
  - Response ให้ส่ง flag สถานะ PIN กลับมาด้วย เช่น:
    ```json
    {
      "success": true,
      "data": {
        "token": "jwt_token...",
        "user": {
          "id": "1",
          "email": "user@example.com",
          "has_pin": true  // true หาก user มี pin_hash ในระบบแล้ว
        }
      }
    }
    ```
- **`POST /api/auth/setup-pin`**:
  - Request: `{ "pin": "123456" }`
  - Backend: นำ PIN ไป `bcrypt.hash(pin, 10)` แล้วบันทึกลง `users.pin_hash`
- **`POST /api/auth/verify-pin`**:
  - Request: `{ "pin": "123456" }`
  - Backend: ใช้ `bcrypt.compare(pin, user.pin_hash)` เพื่อตรวจสอบความถูกต้อง

#### 4) โครงสร้าง Flow บนหน้าจอ Flutter
```
ผู้ใช้ Login ผ่านอีเมล/รหัสผ่าน
           │
           ▼
เช็คค่า `has_pin` จาก Backend
     ├── หาก `has_pin == false` ──> ไปหน้า PinSetupScreen (ตั้งค่า PIN ใหม่แล้วยิง API setup-pin)
     └── หาก `has_pin == true`  ──> ไปหน้า PinVerifyScreen (กรอก PIN แล้วยิง API verify-pin)
```

---

## 📦 3. คู่มือการ Build ไฟล์ Android App Bundle (.aab) ด้วยตนเอง

ไฟล์ `.aab` เป็นฟอร์แมตไฟล์ติดตั้งที่ Google Play Store บังคับใช้สำหรับการเผยแพร่แอป

### 3.1 สิ่งที่ได้รับการตั้งค่าไว้แล้วในโปรเจกต์
- **Keystore Signing Key**: สร้างไว้ที่ `android/app/finclub-release-key.jks`
- **Key Properties**: บันทึกค่า Key Alias, รหัสผ่าน ไว้ที่ `android/key.properties` (อยู่ใน `.gitignore` ปลอดภัยไม่หลุดขึ้น Git)
- **Gradle Config**: [android/app/build.gradle.kts](file:///C:/app/fintech/android/app/build.gradle.kts) มีการผูก `signingConfigs.create("release")` เรียบร้อยแล้ว

---

### 3.2 ขั้นตอนการ Build ทีละขั้น (Step-by-Step)

#### ขั้นตอนที่ 1: อัปเดต Version Code ใน `pubspec.yaml`
Google Play จะ **ปฏิเสธการอัปโหลด** ทันทีหากเลข Version ซ้ำกับไฟล์เดิมที่เคยอัปโหลด:
1. เปิดไฟล์ [pubspec.yaml](file:///C:/app/fintech/pubspec.yaml)
2. แก้ไขบรรทัด `version:` 
   ```yaml
   # รูปแบบ: version: [SemanticVersion]+[VersionCode]
   version: 1.0.0+2   # สำหรับการ build อัปเดตครั้งถัดไป ให้เปลี่ยนเป็น +3, +4, +5 ไปเรื่อยๆ
   ```

#### ขั้นตอนที่ 2: เปิด Terminal ในโฟลเดอร์โปรเจกต์
เปิด Terminal (PowerShell หรือ VS Code Terminal) ที่โฟลเดอร์:
```powershell
cd C:\app\fintech
```

#### ขั้นตอนที่ 3: เคลียร์ Cache และดึง Dependency (แนะนำทำเสมอ)
```powershell
flutter clean
flutter pub get
```

#### ขั้นตอนที่ 4: รันคำสั่ง Build App Bundle
รันคำสั่งสำหรับสร้าง Release Bundle:
```powershell
flutter build appbundle --release
```

> [!TIP]
> หากต้องการระบุ Base API URL ของ Production Server ให้แน่นอนผ่าน Dart Define สามารถรันคำสั่งนี้ได้:
> ```powershell
> flutter build appbundle --release --dart-define=API_URL=https://api.finnova.co.th/api
> ```

#### ขั้นตอนที่ 5: รับไฟล์ผลลัพธ์
เมื่อระบบประมวลผลเสร็จสิ้น (มักใช้เวลาประมาณ 1-2 นาที) จะขึ้นข้อความ:
```text
√ Built build\app\outputs\bundle\release\app-release.aab (xx.xMB)
```
ไฟล์ `.aab` ที่สร้างเสร็จแล้วจะอยู่ที่:
```text
C:\app\fintech\build\app\outputs\bundle\release\app-release.aab
```

---

## 🚀 4. วิธีนำไฟล์ `.aab` ไปอัปโหลดขึ้น Google Play Console (Internal Testing)

1. เข้าสู่ระบบ [Google Play Console](https://play.google.com/console)
2. เลือกแอป **Finclub**
3. ไปที่เมนูด้านซ้าย: **Testing (การทดสอบ)** > **Internal testing (การทดสอบภายใน)**
4. คลิกปุ่ม **Create new release (สร้างรุ่นใหม่)** ที่มุมบนขวา
5. ในส่วน **App bundles**: คลิกปุ่ม **Upload** แล้วเลือกไฟล์:
   ```text
   C:\app\fintech\build\app\outputs\bundle\release\app-release.aab
   ```
6. กรอก **Release notes** เช่น:
   ```text
   - อัปเดตโลโก้แอปพลิเคชันใหม่
   - ปรับปรุงประสิทธิภาพการคำนวณและเชื่อมต่อระบบเซิร์ฟเวอร์
   ```
7. คลิก **Next (ถัดไป)** ตรวจสอบความถูกต้อง แล้วกด **Save and publish (บันทึกและเผยแพร่)**
8. สมาชิกผู้ทดสอบ (Testers) ที่อยู่ในรายชื่อจะสามารถกดลิงก์ดาวน์โหลดและอัปเดตเวอร์ชันใหม่ได้ทันที

---

## 🛠️ 5. การแก้ไขปัญหาที่พบบ่อย (Troubleshooting)

### ปัญหาที่ 1: Google Play แจ้งว่า "Version code has already been used"
- **สาเหตุ**: ลืมเพิ่มเลขหลังเครื่องหมาย `+` ใน `pubspec.yaml`
- **วิธีแก้**: เปลี่ยน `version: 1.0.0+1` เป็น `1.0.0+2` (หรือเลขที่มากกว่ารุ่นล่าสุดบนสโตร์) แล้วรันคำสั่ง Build ใหม่

### ปัญหาที่ 2: Gradle Lock Error หรือ Process ค้าง
- **วิธีแก้**: ปิด IDE แล้วรันคำสั่ง:
  ```powershell
  Stop-Process -Name java,dart -Force -ErrorAction SilentlyContinue
  flutter clean
  flutter pub get
  flutter build appbundle --release
  ```

---

## 📸 6. ระบบบันทึกภาพหน้าจอหลักฐานการยอมรับเงื่อนไข (Policy Consent Evidence)

ระบบบันทึกภาพหน้าจอขณะลูกค้ากด **"ยอมรับข้อตกลงและเข้าสู่ระบบ"** เพื่อใช้เป็นพยานหลักฐานทางอิเล็กทรอนิกส์ (Audit Trail) ตาม พ.ร.บ. ว่าด้วยธุรกรรมทางอิเล็กทรอนิกส์ พ.ศ. 2544 และ PDPA

### 6.1 โฟลเดอร์จัดเก็บภาพบนเซิร์ฟเวอร์
- รูปภาพหลักฐานทั้งหมดจะถูกจัดเก็บไว้ที่:
  ```text
  C:\app\fintech\backend\uploads\capture_policy\
  ```
- ชื่อไฟล์ถูกตั้งโดยอัตโนมัติ: `terms-evidence-[timestamp]-[random].png`

### 6.2 การบันทึกลงฐานข้อมูล (MySQL)
ตาราง `terms_logs` จัดเก็บข้อมูลครบถ้วน:
```sql
CREATE TABLE IF NOT EXISTS `terms_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `accepted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` VARCHAR(255) DEFAULT NULL,
  `evidence_image_url` VARCHAR(500) DEFAULT NULL,
  CONSTRAINT `fk_terms_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);
```
- ข้อมูลที่ถูกบันทึกพร้อมภาพ:
  1. `user_id`: บัญชีผู้ใช้ที่กดยอมรับ
  2. `accepted_at`: วันเวลาที่กดยืนยันตามเวลาเซิร์ฟเวอร์
  3. `ip_address`: IP Address ของผู้ใช้ขณะทำรายการ
  4. `user_agent`: ข้อมูลระบบปฏิบัติการและรุ่นอุปกรณ์
  5. `evidence_image_url`: URL/Path ของไฟล์ภาพใน `uploads/capture_policy`

### 6.3 การทำงานใน Flutter (iOS & Android 100%)
- ใช้ `RepaintBoundary` แปลง UI ของไดอะล็อกข้อตกลงและสถานะติ๊กถูกเป็นภาพ PNG ความละเอียดสูง (`pixelRatio: 2.0`)
- **ไม่ต้องขอ Permissions** ใดๆ บนมือถือ ไม่กระทบ Sandbox ของ iOS และ Android
- มีแถบข้อความแจ้งเตือนทางกฎหมายอย่างโปร่งใสตามเกณฑ์ของ Google Play Store & PDPA
- ส่งข้อมูลขึ้นเซิร์ฟเวอร์ผ่าน `POST /api/auth/accept-terms` (Multipart Form Data)

