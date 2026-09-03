# 🚀 คู่มือการนำแอป Finclub ขึ้น Google Play Store & Apple App Store (ตั้งแต่เริ่มต้นจนจบ)

คู่มือนี้สรุปขั้นตอนทีละขั้น (Step-by-Step) อย่างละเอียด สำหรับนำแอปพลิเคชัน **Finclub (Flutter + Node.js/MySQL)** ขึ้นเผยแพร่บนสโตร์ทางการทั้ง **Google Play Store (Android)** และ **Apple App Store (iOS)** หลังจากสมัครบัญชีนักพัฒนา (Developer Account) เรียบร้อยแล้ว

---

## 📌 สารบัญ
1. [สิ่งที่ต้องเตรียมพร้อมก่อนเริ่ม (สำคัญมาก)](#1-สิ่งที่ต้องเตรียมพร้อมก่อนเริ่ม-สำคัญมาก)
2. [ขั้นตอนที่ 1: นำแอปขึ้น Google Play Store (Android)](#ขั้นตอนที่-1-นำแอปขึ้น-google-play-store-android)
3. [ขั้นตอนที่ 2: นำแอปขึ้น Apple App Store (iOS)](#ขั้นตอนที่-2-นำแอปขึ้น-apple-app-store-ios)
4. [ข้อกำหนดพิเศษสำหรับแอปสินเชื่อ/การเงิน (Fintech Policy)](#ข้อกำหนดพิเศษสำหรับแอปสินเชื่อการเงิน-fintech-policy)
5. [Checklist สรุปก่อนกดส่งรีวิว](#checklist-สรุปก่อนกดส่งรีวิว)

---

## 1. สิ่งที่ต้องเตรียมพร้อมก่อนเริ่ม (สำคัญมาก)

### 1.1 เซิร์ฟเวอร์และฐานข้อมูล (Backend & MySQL)
> ⚠️ **คำเตือน**: Reviewer ของ Google (สหรัฐฯ/อินเดีย) และ Apple (สหรัฐฯ/ไอร์แลนด์) จะโหลดแอปไปเปิดทดสอบบนเครื่องจริงของพวกเขา จึง**ไม่สามารถเชื่อมต่อ `localhost` หรือ `192.168.1.88` ได้**

- Backend (Node.js) และฐานข้อมูล MySQL จะต้องถูก Deploy ขึ้นคลาวด์สาธารณะและมี URL ที่เป็น **HTTPS** เช่น:
  - บริการยอดนิยมที่ตั้งค่าง่าย: **Railway, Render, Fly.io, DigitalOcean, AWS, หรือ Cloud VPS**
  - ตัวอย่าง URL จริง: `https://api.finclub-app.com/api`
- ต้องสร้าง **บัญชีผู้ใช้ทดสอบ (Demo Test Account)** ไว้ในฐานข้อมูล เพื่อนำ Username และ Password ไปกรอกในช่อง "App Access / Review Notes" ให้เจ้าหน้าที่สโตร์ใช้ล็อกอินทดสอบ

### 1.2 การเปลี่ยน Package Name / Bundle ID
ค่าเริ่มต้นของโปรเจกต์คือ `com.example.fintech` ซึ่งทั้ง Google Play และ Apple App Store **จะปฏิเสธการอัปโหลดทันที** หากขึ้นต้นด้วย `com.example`
- ต้องเปลี่ยนเป็นชื่อเฉพาะขององค์กรคุณ เช่น:
  - `com.finclub.loan` หรือ `com.augajom.finclub`

### 1.3 นโยบายความเป็นส่วนตัว (Privacy Policy URL)
- แอปที่มีการสมัครสมาชิก, อัปโหลดรูปภาพ, และเกี่ยวข้องกับการเงิน **จำเป็นต้องมีลิงก์ Privacy Policy สาธารณะ** 
- สามารถสร้างเป็นหน้าเว็บง่าย ๆ หรือเขียนบน Notion / GitHub Pages แล้วแชร์เป็น Public Link ได้

---

## ขั้นตอนที่ 1: นำแอปขึ้น Google Play Store (Android)

### ตอนที่ 1.1: สร้าง Keystore และตั้งค่า Signing สำหรับ Android
Google Play ไม่อนุญาตให้อัปโหลด APK/AAB ที่เซ็นด้วย Debug Key คุณต้องสร้าง **Release Keystore** ของตัวเอง:

1. **สร้างไฟล์ Keystore ผ่าน Terminal**:
   เปิด PowerShell ในโฟลเดอร์โปรเจกต์ แล้วรันคำสั่ง:
   ```powershell
   keytool -genkey -v -keystore "C:\app\fintech\android\app\finclub-release-key.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias finclub -storetype JKS
   ```
   *(ระบบจะให้ตั้งรหัสผ่าน และกรอกข้อมูลชื่อองค์กร ให้จดจำรหัสผ่านนี้ไว้ให้ดี ห้ามทำหายเด็ดขาด)*

2. **สร้างไฟล์ `android/key.properties`**:
   สร้างไฟล์ชื่อ `key.properties` ในโฟลเดอร์ `android/` โดยใส่เนื้อหา:
   ```properties
   storePassword=รหัสผ่านที่คุณตั้ง
   keyPassword=รหัสผ่านที่คุณตั้ง
   keyAlias=finclub
   storeFile=finclub-release-key.jks
   ```
   *(หมายเหตุ: ไฟล์นี้มีใน `.gitignore` แล้ว จะไม่ถูก push ขึ้น GitHub เพื่อความปลอดภัย)*

3. **ผูก Signing เข้ากับ `android/app/build.gradle.kts`**:
   อัปเดตไฟล์ `android/app/build.gradle.kts` ให้โหลด `key.properties`:
   ```kotlin
   import java.util.Properties
   import java.io.FileInputStream

   val keystorePropertiesFile = rootProject.file("key.properties")
   val keystoreProperties = Properties()
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String?
               keyPassword = keystoreProperties["keyPassword"] as String?
               storeFile = keystoreProperties["storeFile"]?.let { file(it) }
               storePassword = keystoreProperties["storePassword"] as String?
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
               isMinifyEnabled = false
               isShrinkResources = false
           }
       }
   }
   ```

4. **สั่งคอมไพล์เป็นไฟล์ `.aab` (Android App Bundle)**:
   ```bash
   flutter build appbundle --release --dart-define=API_URL=https://api.yourdomain.com/api
   ```
   ไฟล์ที่ได้จะอยู่ที่:
   `build/app/outputs/bundle/release/app-release.aab`

---

### ตอนที่ 1.2: จัดการบน Google Play Console (หน้าเว็บ)
เข้าสู่ระบบที่: [https://play.google.com/console](https://play.google.com/console)

1. **สร้างแอป (Create App)**:
   - กดปุ่ม **Create app**
   - App name: `Finclub`
   - Default language: `Thai - th` (หรือ English)
   - App or game: เลือก `App`
   - Free or paid: เลือก `Free`
   - ยอมรับข้อกำหนดแล้วกด **Create app**

2. **ตั้งค่าข้อมูลแอป (App Content & Policies)**:
   ไปที่เมนูด้านซ้ายเลือก **Policy and programs** ➡️ **App content** ต้องตอบคำถามให้ครบทุกหัวข้อ:
   - **Privacy Policy**: ใส่ URL ของหน้านโยบายความเป็นส่วนตัว
   - **App Access**: เลือก *"All or some functionality is restricted"* แล้วกด **Add new instructions** ใส่ Username / Password ทดสอบ พร้อมเขียนโน้ตวิธีเข้าสู่ระบบ
   - **Ads**: เลือก *"No, my app does not contain ads"* (หากไม่มีโฆษณา)
   - **Content rating**: ตอบแบบสอบถาม IARC (เลือกประเภท Consumer / Finance)
   - **Target audience**: เลือกกลุ่มอายุ (เช่น 18 ขึ้นไป สำหรับแอปสินเชื่อ)
   - **Financial Features / Personal Loans Policy**: 
     - เลือกหมวดหมู่การเงิน (Personal Loans)
     - ระบุอัตราดอกเบี้ย APR สูงสุด (เช่น 35.80% p.a.)
     - ระบุระยะเวลาผ่อนชำระ (เช่น คงที่ 7 วัน หรือ 3-6 เดือน)
     - อัปโหลดเอกสารใบอนุญาตประกอบธุรกิจการเงิน (ถ้ามี)
   - **Data safety (ความปลอดภัยของข้อมูล)**:
     - ระบุว่าเก็บข้อมูลใดบ้าง เช่น: Name, Email, Financial Info, Photos (โปรไฟล์), Biometric

3. **ตั้งค่าหน้าร้าน (Store Listing)**:
   ไปที่ **Grow** ➡️ **Store presence** ➡️ **Main store listing**:
   - **Short description (สั้น)**: เช่น *"สินเชื่อส่วนบุคคลดิจิทัล อนุมัติไว โปร่งใส ไม่มีค่าใช้จ่ายแอบแฝง"* (ไม่เกิน 80 ตัวอักษร)
   - **Full description (เต็ม)**: อธิบายฟังก์ชันการทำงาน สูตรคำนวณ 7 วัน อัตราดอกเบี้ย และเงื่อนไขการกู้ยืม
   - **App Icon**: รูปขนาด `512 x 512 px` (PNG 32-bit)
   - **Feature Graphic**: แบนเนอร์ขนาด `1024 x 500 px` (JPG หรือ PNG)
   - **Phone Screenshots**: ภาพหน้าจออย่างน้อย 4 รูป (อัตราส่วน 16:9 หรือ 9:16 ความละเอียดไม่ต่ำกว่า 1080px)

4. **การทดสอบก่อนขึ้นจริง (สำหรับบัญชีส่วนตัวใหม่)**:
   > 📌 **กฎใหม่ของ Google Play (สำหรับบัญชีบุคคล)**: บัญชีที่สมัครหลัง พ.ย. 2023 จะต้องผ่านรอบ **Closed Testing** โดยต้องมีผู้ทดสอบอย่างน้อย **20 คน ร่วมนาน 14 วัน** ถึงจะสามารถยื่นขอเปิดสิทธิ์ลง Production ได้
   - ไปที่ **Testing** ➡️ **Closed testing** ➡️ สร้าง Track
   - อัปโหลดไฟล์ `app-release.aab`
   - เชิญอีเมลเพื่อน/ผู้ทดสอบ 20 อีเมลเข้ามาร่วมทดสอบ
   - เมื่อครบ 14 วัน จึงกดปุ่ม **Apply for Production Access**

5. **ปล่อยขึ้น Production**:
   - ไปที่ **Production** ➡️ กด **Create new release**
   - แนบไฟล์ `.aab` ➡️ ใส่ Release Notes ➡️ กด **Review and roll out to Production**
   - รอทีมงาน Google รีวิวประมาณ 3 - 7 วัน

---

## ขั้นตอนที่ 2: นำแอปขึ้น Apple App Store (iOS)

### ตอนที่ 2.1: เตรียม Bundle ID และ Certificate ใน Apple Developer Portal
เข้าสู่ระบบที่: [https://developer.apple.com/account](https://developer.apple.com/account)

1. **สร้าง App Identifier (App ID)**:
   - ไปที่ **Certificates, Identifiers & Profiles** ➡️ **Identifiers** ➡️ กดเครื่องหมาย `+`
   - เลือก **App IDs** ➡️ ประเภท **App**
   - Description: `Finclub App`
   - Bundle ID: เลือก **Explicit** ใส่ชื่อเดียวกับในโปรเจกต์ เช่น `com.finclub.loan`
   - ตรง Capabilities: ติ๊กเลือกบริการที่ใช้ เช่น AutoFill Credential Provider, Sign In with Apple (ถ้ามี)
   - กด **Continue** ➡️ **Register**

2. **สร้าง Distribution Certificate**:
   - ในหน้า **Certificates** กดเครื่องหมาย `+`
   - เลือก **Apple Distribution**
   - ทำการอัปโหลดไฟล์ Certificate Signing Request (CSR) จากโปรแกรม Keychain Access บน Mac (หรือสร้างผ่าน GitHub Actions / Codemagic)

3. **สร้าง Provisioning Profile**:
   - ในหน้า **Profiles** กดเครื่องหมาย `+`
   - เลือก **App Store Connect** ภายใต้หัวข้อ Distribution
   - เลือก App ID: `com.finclub.loan`
   - เลือก Certificate ที่สร้างไว้
   - ตั้งชื่อโปรไฟล์ เช่น `Finclub_AppStore_Profile` แล้วกด Download

---

### ตอนที่ 2.2: สร้าง Record ใน App Store Connect
เข้าสู่ระบบที่: [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)

1. **สร้างแอปใหม่ (New App)**:
   - ไปที่เมนู **My Apps** ➡️ กดปุ่ม `+` ➡️ เลือก **New App**
   - Platforms: ติ๊กเลือก `iOS`
   - Name: `Finclub - Digital Loans` (หรือชื่อแบรนด์ของคุณ)
   - Primary Language: `Thai` หรือ `English`
   - Bundle ID: เลือก Bundle ID ที่ลงทะเบียนไว้ (`com.finclub.loan`)
   - SKU: ตั้งรหัสอ้างอิง เช่น `FINCLUB-IOS-001`
   - User Access: `Full Access` ➡️ กด **Create**

2. **กรอกข้อมูลบน App Store Connect**:
   - **Screenshots (ขนาดที่ Apple บังคับ)**:
     - จอ 6.7 นิ้ว (iPhone 15 Pro Max / 16 Pro Max): ความละเอียด `1290 x 2796 px` อย่างน้อย 3-5 รูป
     - จอ 6.5 นิ้ว (iPhone 11 Pro Max / XS Max): ความละเอียด `1242 x 2688 px`
   - **Promotional Text / Description**: คำบรรยายจุดเด่น และรายละเอียดการคำนวณสินเชื่อ
   - **Keywords**: คำค้นหา เช่น `สินเชื่อ, กู้เงิน, คำนวณดอกเบี้ย, finclub, loan` (คั่นด้วยจุลภาค ไม่เกิน 100 ตัวอักษร)
   - **Support URL**: ลิงก์หน้าเว็บติดต่อช่วยเหลือ (เช่น หน้า Facebook Page หรือหน้า Contact Us)
   - **Marketing URL**: เว็บไซต์หลักของแอป

3. **ตั้งค่า App Privacy (Nutrition Labels)**:
   - ไปที่แถบ **App Privacy** ด้านซ้าย
   - ตอบแบบสอบถามว่าแอปเก็บข้อมูลประเภทใดบ้าง (Contact Info, Financial Info, Identifiers, User Content)
   - ใส่ Privacy Policy URL

---

### ตอนที่ 2.3: Build และอัปโหลดไฟล์เข้าสู่ App Store Connect

#### วิธีที่ A: ผ่านเครื่อง Mac (ด้วย Xcode) — แนะนำ
1. เปิดโฟลเดอร์โปรเจกต์บนเครื่อง Mac
2. เปิดไฟล์ `ios/Runner.xcworkspace` ด้วย Xcode
3. เลือก Device ด้านบนเป็น **Any iOS Device (arm64)**
4. ไปที่เมนูด้านบนเลือก **Product** ➡️ **Archive**
5. เมื่อ Archive สำเร็จ หน้าต่าง Organizer จะเด้งขึ้นมา ➡️ กดปุ่ม **Distribute App**
6. เลือกปลายทางเป็น **App Store Connect** ➡️ กด **Upload** ไปเรื่อย ๆ จนสำเร็จ

#### วิธีที่ B: ผ่าน GitHub Actions (สำหรับคนที่ไม่มีเครื่อง Mac)
1. ใช้ GitHub Actions สร้างไฟล์ `.ipa` ที่ลงลายเซ็น Apple Distribution Certificate (ผ่าน Fastlane หรือ Match)
2. อัปโหลดตรงผ่านคำสั่ง `xcrun altool` หรือ App Store Connect API Key เข้า TestFlight อัตโนมัติ

---

### ตอนที่ 2.4: ทดสอบผ่าน TestFlight และกด Submit Review
1. เมื่ออัปโหลด Build สำเร็จ ให้เข้าไปที่แท็บ **TestFlight** ใน App Store Connect (รอประมวลผลประมาณ 10-15 นาที)
2. เมื่อสถานะขึ้นว่า **Ready to Test** สามารถเชิญอีเมลตัวเองเข้าไปทดสอบบน iPhone ผ่านแอป **TestFlight** ได้ทันที
3. **เตรียมข้อมูลสำหรับ Apple Reviewer (App Review Information)**:
   - **Sign-in required**: ติ๊กถูก ➡️ ใส่ Username และ Password ของ Demo Account
   - **Contact Information**: เบอร์โทรศัพท์ และอีเมลของคุณ
   - **Notes**: เขียนอธิบายให้ชัดเจน เช่น:
     > *"Finclub is a micro-loan calculation & application platform. Please use the demo credentials provided to test full features including the 7-day loan calculator, saved plans, and profile avatar upload. Backend API is live at https://api.finclub-app.com"*
4. เลือก Build ล่าสุดเข้าไปในหน้าเวอร์ชัน ➡️ กดปุ่ม **Add for Review** ➡️ กด **Submit to App Review**
5. รอทีมงาน Apple ตรวจสอบ (โดยเฉลี่ย 24 - 48 ชั่วโมง)

---

## ข้อกำหนดพิเศษสำหรับแอปสินเชื่อ/การเงิน (Fintech Policy)

เนื่องจาก Finclub เป็นแอปพลิเคชันประเภท **สินเชื่อ (Personal Loans / Micro-Loans)** ทั้ง Google และ Apple มีนโยบายคุมเข้มเป็นพิเศษเพื่อป้องกันการหลอกลวง (Anti-Predatory Lending Policies):

### 1. การเปิดเผยข้อมูลสินเชื่อ (Disclosure Requirements)
ในหน้ารายละเอียดของแอป (Store Description) และภายในตัวแอป **ต้องระบุข้อมูลเหล่านี้อย่างชัดเจน**:
- ระยะเวลาชำระคืนขั้นต่ำและสูงสุด (เช่น ชำระคืนภายใน 7 วัน หรือ 90 - 180 วัน)
- อัตราดอกเบี้ยร้อยละต่อปีสูงสุด (Maximum Annual Percentage Rate - APR) เช่น สูงสุดไม่เกิน 35.80% ต่อปี
- ตัวอย่างการคำนวณสินเชื่อที่ชัดเจน (Representative Example) เช่น:
  > *"ตัวอย่าง: กู้ยืม 10,000 บาท ระยะเวลา 7 วัน ดอกเบี้ย 35.80% ต่อปี (ดอกเบี้ย 68.67 บาท) ค่าดำเนินการ 58.1% (5,810 บาท) ยอดรวมที่ต้องชำระคืนคือ 15,878.67 บาท"*
- นโยบายความเป็นส่วนตัวที่ระบุเรื่องการจัดการข้อมูลเครดิตอย่างถูกต้อง

### 2. นโยบายระยะเวลาผ่อนชำระของ Google Play
> ⚠️ **ข้อควรระวังสำคัญของ Google Play**:  
> ในหลายประเทศ (เช่น สหรัฐฯ หรือผู้ให้บริการสินเชื่อรายย่อยทั่วไป) Google Play มีนโยบาย **ห้ามสินเชื่อส่วนบุคคลที่มีระยะเวลาผ่อนชำระคืนสั้นกว่า 60 วัน (Short-term personal loans under 60 days)**  
> **ทางออก**:  
> หากต้องการเผยแพร่ทั่วไปบน Google Play แนะนำให้เปิดฟังก์ชันสินเชื่อแบบผ่อนชำระ **3 - 6 เดือน** (ซึ่งระบบของเรามีโค้ดรองรับการผ่อนชำระแบบ 3, 4, 5, 6 เดือนอยู่แล้วในแท็บ Schedule & Compare) เพื่อใช้เป็นตัวหลักในการส่งตรวจสโตร์

### 3. นโยบายของ Apple (App Store Review Guideline 3.2.1 - Financial Services)
- Apple กำหนดว่า แอปที่ให้บริการด้านสินเชื่อ/การเงิน **จะต้องส่งภายใต้บัญชี Apple Developer ในนามนิติบุคคล/บริษัท (Organization Account) เท่านั้น** ห้ามส่งในนามบุคคลธรรมดา (Individual Account)
- ต้องมีเอกสารรับรองการประกอบธุรกิจการเงินตามกฎหมายของประเทศนั้น ๆ ยื่นแนบในระบบ

---

## Checklist สรุปก่อนกดส่งรีวิว

- [ ] Backend & MySQL ถูก Deploy ขึ้น Cloud และใช้ HTTPS เรียบร้อยแล้ว
- [ ] เปลี่ยน Package Name / Bundle ID จาก `com.example.fintech` เป็นชื่อเฉพาะแล้ว
- [ ] มีลิงก์ Privacy Policy (หน้านโยบายความเป็นส่วนตัว) ที่เปิดดูได้จริง
- [ ] สร้างบัญชีทดสอบ (Demo Account) ที่ Reviewer สามารถเข้าใช้งานได้ทันที
- [ ] ออกแบบภาพสกรีนช็อตครบทุกขนาดตามที่แต่ละสโตร์กำหนด
- [ ] ตรวจสอบว่าในแอปไม่มีคำที่ส่อไปในทางหลอกลวง และแสดงอัตราดอกเบี้ย/ค่าธรรมเนียมโปร่งใส
- [ ] สำหรับ Google Play: ผ่านรอบ Closed Testing 20 คน 14 วันแล้ว (กรณีบัญชีบุคคล)
- [ ] สำหรับ Apple: ดำเนินการในนามบัญชีนิติบุคคล (Organization) และเตรียมใบอนุญาตให้พร้อม
