# 🚀 คู่มือการนำแอป Finclub (เครื่องมือคำนวณดอกเบี้ยสินเชื่อ / Loan Calculator) ขึ้น Google Play Store & Apple App Store

คู่มือนี้สรุปขั้นตอนทีละขั้น (Step-by-Step) อย่างละเอียด สำหรับนำแอปพลิเคชัน **Finclub (Flutter + Node.js/MySQL)** ขึ้นเผยแพร่บนสโตร์ทางการทั้ง **Google Play Store (Android)** และ **Apple App Store (iOS)** ในฐานะ **"เครื่องมือคำนวณดอกเบี้ยและวางแผนสินเชื่อ (Loan & Interest Calculator / Financial Simulator)"** ซึ่งไม่ใช่แอปกู้ยืมเงินจริง

---

## 📌 ข้อมูลสำคัญเบื้องต้น (ตอบคำถาม: Make ได้ไหม / ต้องเตรียมอะไรบ้าง)

### 1. Make ขึ้นมาได้ไหม หรือต้องใช้ของจริง?
* **"Make / จำลองได้เกือบ 100%" ครับ!**
  - **ข้อมูลในฐานข้อมูล**: ตัวเลขคำนวณ, ประวัติแผนที่บันทึก, ผู้ใช้งานจำลอง สามารถ Mock ข้อมูลขึ้นมาได้ทั้งหมด Reviewer จะไม่ตรวจสอบชื่อหรือบัตรประชาชนจริง
  - **ไม่ต้องใช้ใบอนุญาตจาก ธปท. หรือกระทรวงการคลัง**: เนื่องจากแอปนี้เป็นเพียง **เครื่องมือคำนวณทางคณิตศาสตร์ (Calculator / Simulator)** ไม่ได้ให้บริการปล่อยกู้จริง จึงไม่ต้องขอใบอนุญาตสินเชื่อ (Nano/Pico Finance)
  - **หน้านโยบายความเป็นส่วนตัว (Privacy Policy URL)**: สามารถสร้างเว็บหน้าเดียวฟรีผ่าน **Google Sites, Notion หรือ GitHub Pages** ได้เลย โดยระบุเนื้อหาว่าเป็นแอปเครื่องมือคำนวณดอกเบี้ย
  - **สิ่งที่ต้องเป็นของจริง**:
    1. เซิร์ฟเวอร์ API (Node.js) ต้องเชื่อมต่ออินเทอร์เน็ตได้จริง (HTTPS)
    2. แอปต้องกดคำนวณได้จริง ไม่ค้าง ไม่หลุด (Crash)
    3. มีปุ่ม "ลบบัญชีผู้ใช้" (Delete Account) ตามนโยบายบังคับของ Google Play

### 2. เทคนิคการทดสอบขึ้นระบบส่งงานหัวหน้าอย่างรวดเร็ว (ไม่ต้องรอ Google รีวิว)
หากหัวหน้าต้องการทดสอบว่า **"ทีมสามารถ Build และนำแอปขึ้นระบบสโตร์ได้จริงหรือไม่"**:
- **แนะนำให้ปล่อยขึ้นแทร็ก "Internal Testing (การทดสอบภายใน)" บน Google Play Console**:
  - อัปโหลดไฟล์ `.aab` ขึ้นระบบแล้วรอประมวลผลเพียงไม่กี่นาที
  - สามารถส่งลิงก์ดาวน์โหลดผ่าน Google Play Store ให้หัวหน้าและทีมงานกดติดตั้งลงมือถือจริงได้ทันที
  - ไม่ต้องรอทีมงาน Google ตรวจสอบ และไม่ติดเงื่อนไข Closed Testing 20 คน 14 วัน

---

## 📌 สารบัญ
1. [สิ่งที่ต้องเตรียมพร้อมก่อนเริ่ม](#1-สิ่งที่ต้องเตรียมพร้อมก่อนเริ่ม)
2. [ขั้นตอนที่ 1: นำแอปขึ้น Google Play Store (Android)](#ขั้นตอนที่-1-นำแอปขึ้น-google-play-store-android)
3. [ขั้นตอนที่ 2: นำแอปขึ้น Apple App Store (iOS)](#ขั้นตอนที่-2-นำแอปขึ้น-apple-app-store-ios)
4. [ข้อควรระวัง: การป้องกันไม่ให้สโตร์เข้าใจผิดว่าเป็นแอปกู้เงินจริง](#4-ข้อควรระวัง-การป้องกันไม่ให้สโตร์เข้าใจผิดว่าเป็นแอปกู้เงินจริง)
5. [Checklist สรุปก่อนกดส่งขึ้นระบบ](#5-checklist-สรุปก่อนกดส่งขึ้นระบบ)

---

## 1. สิ่งที่ต้องเตรียมพร้อมก่อนเริ่ม

### 1.1 เซิร์ฟเวอร์และฐานข้อมูล (Backend & MySQL)
Reviewer ของ Google (สหรัฐฯ/อินเดีย) จะดาวน์โหลดแอปไปเปิดทดสอบบนเครื่องจริงของพวกเขา จึง**ไม่สามารถเชื่อมต่อ `localhost` หรือ `192.168.1.xx` ได้**
- Backend (Node.js) และฐานข้อมูล MySQL จะต้องถูก Deploy ขึ้น Cloud ที่มี URL เป็น **HTTPS** เช่น Railway, Render, Fly.io, DigitalOcean, หรือ Cloud VPS
- สร้าง **Demo Account** ไว้ 1 บัญชีในระบบ (เช่น `demo@finclub.com` / `pass1234`) เพื่อนำไปกรอกในช่อง "App Access" ให้เจ้าหน้าที่สโตร์ใช้ล็อกอิน

### 1.2 การเปลี่ยน Package Name / Bundle ID
ค่าเริ่มต้นของโปรเจกต์คือ `com.example.fintech` สโตร์จะปฏิเสธการอัปโหลดทันทีหากขึ้นต้นด้วย `com.example`
- ต้องเปลี่ยนเป็นชื่อเฉพาะ เช่น `com.augajom.finclub` หรือ `com.finclub.calculator`

### 1.3 ลิงก์นโยบายความเป็นส่วนตัว (Privacy Policy URL)
- สร้างหน้าเว็บง่าย ๆ (เช่น Google Sites หรือ Notion) ระบุว่าแอป Finclub เป็นเครื่องมือคำนวณ และเก็บข้อมูลอีเมล/รหัสผ่านเพื่อการบันทึกแผนคำนวณเท่านั้น

### 1.4 ระบบขอลบบัญชี (Account Deletion Requirement)
Google Play บังคับว่าแอปที่มีการสมัครสมาชิก ต้องมี:
1. ปุ่มลบบัญชีภายในตัวแอป (ใน Finclub มีปุ่มลบบัญชีในหน้า Profile & Settings และใน Modal ความปลอดภัยแล้ว)
2. ลิงก์หน้าเว็บขอลบบัญชีภายนอก (Account Deletion URL) เพื่อให้ผู้ใช้ขอลบข้อมูลได้แม้จะลบแอปไปแล้ว

---

## ขั้นตอนที่ 1: นำแอปขึ้น Google Play Store (Android)

### ตอนที่ 1.1: สร้าง Keystore และคอมไพล์ Android App Bundle (.aab)

1. **สร้างไฟล์ Keystore ผ่าน Terminal**:
   เปิด PowerShell ในโฟลเดอร์โปรเจกต์ แล้วรัน:
   ```powershell
   keytool -genkey -v -keystore "C:\app\fintech\android\app\finclub-release-key.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias finclub -storetype JKS
   ```

2. **สร้างไฟล์ `android/key.properties`**:
   ```properties
   storePassword=รหัสผ่านที่คุณตั้ง
   keyPassword=รหัสผ่านที่คุณตั้ง
   keyAlias=finclub
   storeFile=finclub-release-key.jks
   ```

3. **คอมไพล์เป็นไฟล์ `.aab`**:
   ```powershell
   flutter build appbundle --release --dart-define=API_URL=https://api.yourdomain.com/api
   ```
   ไฟล์ที่ได้จะอยู่ที่: `build/app/outputs/bundle/release/app-release.aab`

---

### ตอนที่ 1.2: ตั้งค่าบน Google Play Console (หน้าเว็บ)
เข้าสู่ระบบที่: [https://play.google.com/console](https://play.google.com/console)

1. **สร้างแอป (Create App)**:
   - App name: `Finclub - เครื่องมือคำนวณดอกเบี้ยสินเชื่อ`
   - Default language: `Thai - th` (หรือ English)
   - App or game: เลือก `App`
   - Free or paid: เลือก `Free`

2. **ตอบแบบสอบถามนโยบาย (Policy & App Content - สำคัญมาก ‼️)**:
   - **Privacy Policy**: กรอก URL หน้านโยบายความเป็นส่วนตัว
   - **App Access**: เลือก *"All or some functionality is restricted"* ➡️ ใส่ Username/Password ของ Demo Account พร้อมโน้ตวิธีเข้าสู่ระบบ
   - **Financial Features Policy (หัวใจสำคัญ)**:
     - เมื่อถามว่าแอปปล่อยสินเชื่อส่วนบุคคล (Personal Loans) หรือไม่:  
       👉 **ให้ตอบว่า "No" (แอปไม่ได้ปล่อยกู้)** หรือเลือกหมวด **Financial Management / Loan Calculator without lending functionality**  
       *(หากไปตอบ Yes ทาง Google จะขอใบอนุญาตจาก ธปท. ทันที)*
   - **Data safety (ความปลอดภัยข้อมูล)**:
     - ตอบตามจริง: เก็บ Email, Name (เพื่อระบบสมาชิก), Data deletion URL (ใส่ลิงก์หน้าเว็บขอลบบัญชี)
   - **Government Apps**: ตอบ "No"
   - **Target audience**: เลือกกลุ่มอายุ เช่น 18 ขึ้นไป

3. **ตั้งค่าหน้าร้าน (Store Listing)**:
   - **Short description**: เช่น *"เครื่องมือคำนวณดอกเบี้ยและจำลองภาระสินเชื่อเบื้องต้น วางแผนการเงินอย่างโปร่งใส"* (ไม่เกิน 80 ตัวอักษร)
   - **Full description**: อธิบายสูตรคำนวณดอกเบี้ยรายวัน และใส่ข้อความ **Disclaimer** กำกับไว้เสมอ:
     > *"ข้อสงวนสิทธิ์ (Disclaimer): แอปพลิเคชัน Finclub เป็นเพียงเครื่องมือคำนวณและจำลองภาระดอกเบี้ยเบื้องต้นเพื่อการวางแผนทางการเงินเท่านั้น ไม่ได้มีบริการปล่อยสินเชื่อหรือเป็นตัวแทนจัดหาเงินกู้จริงแต่อย่างใด"*
   - **App Icon**: `512 x 512 px` (PNG 32-bit)
   - **Feature Graphic**: `1024 x 500 px` (JPG/PNG)
   - **Phone Screenshots**: ภาพหน้าจออย่างน้อย 4 รูป (แสดงหน้าจอเครื่องคิดเลข ตารางผ่อน และการบันทึกแผน)

4. **การปล่อยทดสอบเพื่อส่งงาน (Internal Testing)**:
   - ไปที่ **Testing** ➡️ **Internal testing** ➡️ กด **Create new release**
   - อัปโหลดไฟล์ `app-release.aab` ➡️ บันทึกและ Release
   - ไปที่แท็บ **Testers** คัดลอกลิงก์ Join on Android ส่งให้หัวหน้าและทีมงานกดดาวน์โหลดผ่าน Play Store ได้ทันที!

---

## ขั้นตอนที่ 2: นำแอปขึ้น Apple App Store (iOS)

### ตอนที่ 2.1: เตรียม Bundle ID และ Certificate
1. เข้าสู่ระบบ [Apple Developer Portal](https://developer.apple.com/account)
2. สร้าง App ID: เช่น `com.augajom.finclub`
3. สร้าง Apple Distribution Certificate และ App Store Provisioning Profile

### ตอนที่ 2.2: สร้าง Record บน App Store Connect
1. เข้าสู่ระบบ [App Store Connect](https://appstoreconnect.apple.com)
2. ไปที่ **My Apps** ➡️ กด `+` ➡️ เลือก **New App**
3. Category: เลือก `Finance` หรือ `Utilities`
4. ใส่ภาพ Screenshots, Description, Privacy Policy URL
5. ในช่อง **App Review Information** ใส่ Demo Account และระบุชัดเจนว่า:
   > *"Finclub is a financial planning and loan interest calculation tool for personal budgeting. It does not provide, broker, or disburse real loans."*

### ตอนที่ 2.3: Build และปล่อยผ่าน TestFlight
1. บน Mac เปิด `ios/Runner.xcworkspace` ด้วย Xcode
2. ไปที่ **Product** ➡️ **Archive** ➡️ กด **Distribute App** เข้าสู่ App Store Connect
3. เปิดแท็บ **TestFlight** เชิญอีเมลหัวหน้าเข้ามาทดสอบติดตั้งบน iPhone ได้ทันที

---

## 4. ข้อควรระวัง: การป้องกันไม่ให้สโตร์เข้าใจผิดว่าเป็นแอปกู้เงินจริง

เนื่องจากระบบตรวจสอบของสโตร์มีทั้งบอท AI และเจ้าหน้าที่ตรวจสอบ (Human Reviewer) ที่อาจตรวจคำศัพท์ในแอป หากพบคำที่สื่อถึงการกู้เงินจริง อาจสั่งระงับและเรียกตรวจใบอนุญาตการเงิน:

| จุดที่ต้องระวัง | ❌ ห้ามใช้ (อาจโดนเข้าใจผิด) | ✅ ปรับแก้แล้วในโค้ด (ถูกต้อง) |
| :--- | :--- | :--- |
| **ชื่อแอป/สโลแกน** | สินเชื่อด่วน อนุมัติไว โอนเงินทันที | เครื่องมือคำนวณและวางแผนสินเชื่อ |
| **ปุ่ม Action ในแอป** | ยื่นขอกู้เงิน / สมัครสินเชื่อ | จำลองผลการประเมินสินเชื่อ / ดูผลลัพธ์จำลอง |
| **ผลลัพธ์ขั้นตอน** | อนุมัติเงินกู้สำเร็จ / เตรียมโอนเงิน | ผลการจำลองการประเมินเบื้องต้น (Simulation Pre-Check) |
| **ข้อความปฏิเสธความรับผิดชอบ** | ไม่มี Disclaimer | มี Disclaimer Card ชัดเจนทุกหน้าสำคัญ |
| **การจัดการบัญชี** | ไม่มีปุ่มลบบัญชี | มีปุ่ม "ลบบัญชีผู้ใช้" (Delete Account) พร้อมคำเตือนยืนยัน |

---

## 5. Checklist สรุปก่อนกดส่งขึ้นระบบ

- [x] ตัวแอปใช้คำศัพท์ประเภท "เครื่องมือคำนวณ / จำลองการประเมิน (Calculator & Simulator)"
- [x] แสดง Legal Disclaimer (ข้อสงวนสิทธิ์ว่าไม่ใช่บริการกู้เงินจริง) ในหน้าคำนวณและข้อมูลผลิตภัณฑ์
- [x] มีปุ่ม "ลบบัญชีผู้ใช้" (Delete Account) ในหน้า Profile และ Security Modal
- [x] Backend รองรับ API `DELETE /api/auth/account` สำหรับลบข้อมูลผู้ใช้ออกจากฐานข้อมูล
- [ ] Backend & MySQL ถูก Deploy ขึ้น Cloud ที่มี HTTPS (เช่น Railway/Render)
- [ ] เปลี่ยน Package Name ใน `android/app/build.gradle.kts` เป็นชื่อเฉพาะของทีม
- [ ] สร้าง Release Keystore และเซ็ตค่าใน `android/key.properties`
- [ ] สร้างหน้าเว็บ Privacy Policy และ Account Deletion ที่เข้าถึงได้สาธารณะ
- [ ] สร้าง Demo Account พร้อมใช้งานสำหรับ Reviewer
- [ ] ใน Google Play Console เลือก **No** สำหรับแบบสอบถาม Personal Loans
- [ ] ส่งงานผ่านแทร็ก **Internal Testing** เพื่อให้หัวหน้าดาวน์โหลดทดสอบผ่าน Play Store จริงได้ทันที
