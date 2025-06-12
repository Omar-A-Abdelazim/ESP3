/**
 @file SmartHelmet_with_DS18B20.ino
 @brief Smart Helmet for Air Purification and Worker Safety with MPU6050
 @detail Measures pollution (MQ-2 for Natural Gas), temperature (DS18B20), motion (MPU6050), controls a fan, and alerts with a buzzer

 * Connections:
 * MPU-6050     ESP32-WROOM-32U
 * VCC      -   3.3V
 * GND      -   GND
 * SDA      -   GPIO 21 (SDA)
 * SCL      -   GPIO 22 (SCL)
 * 
 * MQ-2         ESP32-WROOM-32U
 * Analog Pin   -   GPIO 34
 * 
 * DS18B20      ESP32-WROOM-32U
 * Data Pin     -   GPIO 14
 * VCC          -   3.3V or 5V
 * GND          -   GND (with 4.7kΩ pull-up to VCC)
 * 
 * Fan          ESP32-WROOM-32U
 * Pin          -   GPIO 27
 *   
 * Buzzer       ESP32-WROOM-32U
 * Positive Pin -   GPIO 26
 * Negative Pin -   GND
 **/

#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <MQSensor.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// تعريف حساس MPU-6050
Adafruit_MPU6050 mpu;

// تعريف حساس MQ-2 (GPIO 34)
MQSensor mq2(34, 4.7);

// تعريف حساس DS18B20 (GPIO 14)
#define ONE_WIRE_BUS 14
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// تعريف الـ Pin بتاع المروحة (GPIO 27)
#define FAN_PIN 27

// تعريف الـ Pin بتاع البازر (GPIO 26)
#define BUZZER_PIN 26

// الحد الأقصى لسرعة الدوران (للتوازن)
const float GYRO_THRESHOLD = 100.0; // 100 درجة/ثانية

// الحد الأقصى لزاوية الميل
const float TILT_THRESHOLD = 45.0; // 45 درجة

// الحد الأقصى لدرجة الحرارة (من DS18B20 - لتشغيل المروحة)
const float TEMP_THRESHOLD = 33.0; // 30°C
const float TEMP_HYSTERESIS = 2.0; // فرق 2°C للـ Hysteresis

// الحد الأقصى لنسبة التلوث (لتشغيل المروحة)
const float POLLUTION_THRESHOLD = 20.0; // 20%
const float POLLUTION_HYSTERESIS = 4.0; // فرق 4% للـ Hysteresis

// الحد الأدنى للتسارع لكشف السقوط الحر
const float FREE_FALL_THRESHOLD = 1.0; // 1 m/s²

// المدة الزمنية المطلوبة لتأكيد الميل الخطر (بالميللي ثانية)
const unsigned long TILT_DURATION_THRESHOLD = 1000; // 1 ثانية

// المدة الزمنية لتجاهل الإيماءات السريعة (بالميللي ثانية)
const unsigned long GYRO_DURATION_THRESHOLD = 500; // 0.5 ثانية

// المدة الزمنية لتأكيد السقوط الحر (بالميللي ثانية)
const unsigned long FREE_FALL_DURATION_THRESHOLD = 300; // 0.3 ثانية

// المدة الزمنية بين كل عرض في Serial Monitor (بالميللي ثانية)
const unsigned long SERIAL_PRINT_INTERVAL = 1000; // 1 ثانية

// متغيرات لتتبع الزمن
unsigned long tiltStartTime = 0; // وقت بداية الميل
unsigned long gyroStartTime = 0; // وقت بداية الحركة السريعة
unsigned long freeFallStartTime = 0; // وقت بداية السقوط الحر
unsigned long lastPrintTime = 0; // وقت آخر عرض في Serial Monitor
bool tiltInProgress = false; // هل الميل مستمر؟
bool gyroInProgress = false; // هل الحركة السريعة مستمرة؟
bool freeFallInProgress = false; // هل السقوط الحر مستمر؟

// متغير لتخزين قيمة R0
float r0;

// متغير لتتبع حالة المروحة
bool fanRunning = false;

// متغيرات لتتبع سبب تشغيل المروحة
bool fanOnDueToTemp = false; // هل المروحة شغالة بسبب الحرارة?
bool fanOnDueToPollution = false; // هل المروحة شغالة بسبب التلوث?

void setup() {
  // بدء الاتصال التسلسلي
  Serial.begin(115200);
  Serial.println("Initializing Smart Helmet...");

  // تهيئة الـ Pin بتاع المروحة والبازر كمخرج
  pinMode(FAN_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(FAN_PIN, LOW); // المروحة متوقفة
  digitalWrite(BUZZER_PIN, LOW); // البازر متوقف

  // بدء حساس MPU-6050
  if (!mpu.begin()) {
    Serial.println("MPU-6050 was not found. Please check wiring/power.");
    while (1);
  }
  mpu.setGyroRange(MPU6050_RANGE_500_DEG); // نطاق الجيروسكوب ±500 درجة/ثانية
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G); // نطاق التسارع ±8g
  Serial.println("MPU-6050 initialized.");

  // بدء حساس DS18B20
  sensors.begin();
  Serial.println("DS18B20 initialized.");

  // معايرة حساس MQ-2
  Serial.println("------------------------------------------------");
  Serial.println("Calibrating R0... Keep the sensor in clean air!");
  Serial.println("Waiting 30 seconds for MQ-2 to warm up...");
  delay(30000); // انتظر 30 ثانية عشان الحساس يسخن
  r0 = mq2.calculateR0(100);
  Serial.print("R0 = ");
  Serial.println(r0);
  // تحقق من قيمة R0
  float initialRS = mq2.readRS();
  float initialRSR0 = initialRS / r0;
  if (initialRSR0 > 1.5 || initialRSR0 < 0.5) {
    Serial.println("تحذير: قيمة R0 غير طبيعية! RS/R0 في الهواء النظيف المفروض تكون قريبة من 1.");
    Serial.print("Initial RS = "); Serial.println(initialRS);
    Serial.print("Initial RS/R0 = "); Serial.println(initialRSR0);
  }
  Serial.println("------------------------------------------------");

  // رسالة بداية
  Serial.println("بدء اختبار الخوذة الذكية...");
  delay(2000);
}

void loop() {
  // قراءة البيانات من حساس MPU-6050
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  // سرعة الدوران في المحورين X وY (بالدرجة/ثانية)
  float gyroX = g.gyro.x * 180.0 / PI; // تحويل من Radian إلى درجة
  float gyroY = g.gyro.y * 180.0 / PI;

  // التسارع في المحاور الثلاثة (m/s²)
  float ax = a.acceleration.x;
  float ay = a.acceleration.y;
  float az = a.acceleration.z;

  // حساب زوايا الميل (Roll وPitch)
  float roll = atan2(ay, az) * 180.0 / PI;
  float pitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180.0 / PI;

  // درجة حرارة البيئة (من الـ MPU-6050)
  float envTemperature = temp.temperature;

  // قراءة البيانات من حساس MQ-2
  int rawValue = analogRead(34); // القراءة الخام من GPIO 34
  float voltage = mq2.readVoltage();

  // التحقق من القيمة الخام لتجنب القسمة على صفر
  float rs;
  if (rawValue <= 1) { // لو القراءة الخام صفر أو 1 (جهد منخفض جدًا)
    rs = 10000.0; // قيمة كبيرة لـ RS (تعكس تركيز غاز عالي جدًا)
  } else {
    rs = mq2.readRS();
    if (rs < 0 || isnan(rs)) { // لو RS سالب أو غير صالح
      rs = 10000.0;
    }
  }

  float rs_r0 = rs / r0;
  if (rs_r0 < 0 || isnan(rs_r0)) { // لو RS/R0 غير صالح
    rs_r0 = 0.01; // قيمة صغيرة تعكس تركيز غاز عالي
  }

  float ppm;
  if (rawValue <= 1) { // لو القراءة الخام منخفضة جدًا، نعتبرها تركيز غاز عالي جدًا
    ppm = 2000.0; // الحد الأقصى لـ PPM
  } else {
    ppm = mq2.readPPM(200.0, -0.2); // الثوابت لتقليل القراءات في الهواء النظيف
    if (ppm < 0 || isnan(ppm)) { // لو PPM غير صالح
      ppm = 2000.0;
    }
  }

  float pp;
  const float MAX_PPM = 2000.0; // حد أقصى 2000 PPM للميثان
  if (ppm >= MAX_PPM) {
    pp = 100;
  } else {
    pp = (ppm / MAX_PPM) * 100.0; // تحويل PPM إلى نسبة مئوية
  }
  String airQuality = classifyAirQuality(ppm);

  // تحذير في حالة مشكلة في المعايرة
  String calibrationWarning = "";
  if (rs_r0 > 1.5 || rs_r0 < 0.5) {
    calibrationWarning = "تحذير: RS/R0 غير طبيعي! أعد المعايرة في هواء نظيف.";
  }

  // قراءة البيانات من حساس DS18B20
  sensors.requestTemperatures();
  float tempDeg = sensors.getTempCByIndex(0); // درجة الحرارة بالدرجات المئوية
  float tempFar = sensors.toFahrenheit(tempDeg); // درجة الحرارة بالفهرنهايت
  if (tempDeg == -127.00) { // قيمة خطأ من DS18B20
    Serial.println("خطأ في قراءة DS18B20! تأكد من التوصيلات.");
    tempDeg = 0.0; // قيمة افتراضية في حالة الخطأ
    tempFar = 32.0;
  }

  // التحكم في المروحة باستخدام Hysteresis لكل شرط على حدة
  bool fanState = false;

  // التحقق من شرط درجة الحرارة
  if (tempDeg > -50.0) { // التأكد إن القراءة صالحة (DS18B20 تعمل من -55°C)
    if (fanOnDueToTemp) {
      // لو المروحة شغالة بسبب الحرارة، ما تتطفيش إلا لو الحرارة نزلت أقل من (TEMP_THRESHOLD - TEMP_HYSTERESIS)
      if (tempDeg < (TEMP_THRESHOLD - TEMP_HYSTERESIS)) {
        fanOnDueToTemp = false;
      }
    } else {
      // لو المروحة متوقفة بسبب الحرارة، ما تشتغلش إلا لو الحرارة زادت عن TEMP_THRESHOLD
      if (tempDeg > TEMP_THRESHOLD) {
        fanOnDueToTemp = true;
      }
    }
  }

  // التحقق من شرط التلوث
  if (fanOnDueToPollution) {
    // لو المروحة شغالة بسبب التلوث، ما تتطفيش إلا لو التلوث نزل أقل من (POLLUTION_THRESHOLD - POLLUTION_HYSTERESIS)
    if (pp < (POLLUTION_THRESHOLD - POLLUTION_HYSTERESIS)) {
      fanOnDueToPollution = false;
    }
  } else {
    // لو المروحة متوقفة بسبب التلوث، ما تشتغلش إلا لو التلوث زاد عن POLLUTION_THRESHOLD
    if (pp > POLLUTION_THRESHOLD) {
      fanOnDueToPollution = true;
    }
  }

  // تشغيل المروحة لو أي شرط من الشرطين متحقق
  if (fanOnDueToTemp || fanOnDueToPollution) {
    digitalWrite(FAN_PIN, HIGH);
    fanRunning = true;
    fanState = true;
  } else {
    digitalWrite(FAN_PIN, LOW);
    fanRunning = false;
    fanState = false;
  }

  // التحكم في البازر (تنبيه)
  bool alarmState = false;
  int buzzerPattern = 0; // 0: متوقف, 1: سريع (سقوط), 2: بطيء (ميل), 4: سريع جدًا (سقوط حر)

  // التحقق من السقوط الحر
  float totalAcceleration = sqrt(ax * ax + ay * ay + az * az);
  if (totalAcceleration < FREE_FALL_THRESHOLD) {
    if (!freeFallInProgress) {
      freeFallStartTime = millis();
      freeFallInProgress = true;
    } else {
      unsigned long freeFallDuration = millis() - freeFallStartTime;
      if (freeFallDuration >= FREE_FALL_DURATION_THRESHOLD) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(30);
        digitalWrite(BUZZER_PIN, LOW);
        delay(30);
        alarmState = true;
        buzzerPattern = 4;
      }
    }
  } else {
    freeFallInProgress = false;
  }

  // التحقق من سرعة الدوران (اكتشاف السقوط بالدوران)
  if (abs(gyroX) > GYRO_THRESHOLD || abs(gyroY) > GYRO_THRESHOLD) {
    if (!gyroInProgress) {
      gyroStartTime = millis();
      gyroInProgress = true;
    }
  } else {
    if (gyroInProgress) {
      unsigned long gyroDuration = millis() - gyroStartTime;
      if (gyroDuration >= GYRO_DURATION_THRESHOLD) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(50);
        digitalWrite(BUZZER_PIN, LOW);
        delay(50);
        alarmState = true;
        buzzerPattern = 1;
      }
      gyroInProgress = false;
    }
  }

  // التحقق من زاوية الميل (اكتشاف الميل الخطر)
  if (abs(roll) > TILT_THRESHOLD || abs(pitch) > TILT_THRESHOLD) {
    if (!tiltInProgress) {
      tiltStartTime = millis();
      tiltInProgress = true;
    } else {
      unsigned long tiltDuration = millis() - tiltStartTime;
      if (tiltDuration >= TILT_DURATION_THRESHOLD) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(200);
        digitalWrite(BUZZER_PIN, LOW);
        delay(200);
        alarmState = true;
        buzzerPattern = 2;
      }
    }
  } else {
    tiltInProgress = false;
  }

  // إيقاف البازر لو مفيش خطر
  if (!alarmState) {
    digitalWrite(BUZZER_PIN, LOW);
  }

  // عرض القراءات كل 1 ثانية
  unsigned long currentTime = millis();
  if (currentTime - lastPrintTime >= SERIAL_PRINT_INTERVAL) {
    Serial.println("------------------------------------------------");
    Serial.print("القراءة الخام (Raw Analog Value): "); Serial.println(rawValue);
    Serial.print("سرعة الدوران (X - Roll): "); Serial.print(gyroX); Serial.println(" درجة/ثانية");
    Serial.print("سرعة الدوران (Y - Pitch): "); Serial.print(gyroY); Serial.println(" درجة/ثانية");
    Serial.print("التسارع الكلي: "); Serial.print(totalAcceleration); Serial.println(" m/s²");
    Serial.print("زاوية الميل (Roll): "); Serial.print(roll); Serial.println(" درجة");
    Serial.print("زاوية الميل (Pitch): "); Serial.print(pitch); Serial.println(" درجة");
    Serial.print("درجة حرارة البيئة (MPU6050): "); Serial.print(envTemperature); Serial.println(" °C");
    Serial.print("الجهد (V): "); Serial.println(voltage);
    Serial.print("RS: "); Serial.println(rs);
    Serial.print("RS/R0: "); Serial.println(rs_r0);
    Serial.print("PPM (Methane): "); Serial.println(ppm);
    Serial.print("نسبة التلوث (pp%): "); Serial.print(pp); Serial.println(" %");
    Serial.print("جودة الهواء: "); Serial.println(airQuality);
    Serial.print("درجة الحرارة (DS18B20): "); Serial.print(tempDeg); Serial.print("°C  "); Serial.print(tempFar); Serial.println("°F");
    Serial.print("حالة المروحة: "); Serial.println(fanState ? "شغالة" : "متوقفة");
    Serial.print("حالة التنبيه (Buzzer): "); 
    if (!alarmState) Serial.println("متوقف");
    else if (buzzerPattern == 1) Serial.println("شغال - سقوط محتمل (دوران)");
    else if (buzzerPattern == 2) Serial.println("شغال - ميل خطر");
    else Serial.println("شغال - سقوط حر");
    if (calibrationWarning != "") {
      Serial.println(calibrationWarning);
    }
    Serial.println("------------------------------------------------");

    lastPrintTime = currentTime; // تحديث وقت آخر عرض
  }

  delay(100); // تحديث الكود كل 0.1 ثانية
}

// دالة لحساب جودة الهواء بناءً على PPM (للميثان)
String classifyAirQuality(float ppm) {
  if (ppm < 400) return "Excellent";
  else if (ppm < 800) return "Good";
  else if (ppm < 1200) return "Moderate";
  else if (ppm < 1600) return "Unhealthy";
  else if (ppm < 2000) return "Very Unhealthy";
  else return "Hazardous";
}