# 👁️ EyeCare Mac

**macOS menü çubuğunda çalışan göz dinlendirme uygulaması**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📖 Hakkında

EyeCare Mac, **20-20-20 kuralına** dayalı bir göz sağlığı uygulamasıdır:

> **Her 20 dakikada bir, 20 saniye boyunca 6 metre (20 feet) uzağa bakın.**

Uygulama tamamen macOS menü çubuğunda (System Tray) çalışır ve Dock'ta görünmez. Çalışma sürenizi takip eder ve mola zamanı geldiğinde güzel bir tam ekran mola penceresi açar.

---

## ✨ Özellikler

- 🕐 **Özelleştirilebilir çalışma süresi** — Dakika ve saniye olarak ayarlanabilir
- 👁️ **Tam ekran mola penceresi** — Animasyonlu geri sayım ile göz dinlendirme hatırlatıcısı
- 🖥️ **Menü çubuğu entegrasyonu** — Dock'ta yer kaplamaz, system tray'de yaşar
- ⏱️ **Canlı geri sayım** — Menü çubuğunda kalan süre anlık gösterilir
- ⚙️ **Ayarlar ekranı** — Çalışma süresi (min + sec), mola süresi, sayaç görünürlüğü
- 🔄 **Otomatik döngü** — Mola sonrası otomatik yeniden başlatma
- ⏯️ **Basit kontroller** — Başlat, Durdur, Ayarlar, Çıkış
- 🔊 **Ses bildirimi** — Mola başında ve sonunda ses çalar
- 🚀 **Bilgisayar açılışında otomatik başlatma** — Login Items desteği
- 🌍 **Çoklu dil desteği** — Türkçe ve İngilizce (easy_localization)
- 🛑 **Mola penceresinden durdurma** — Timer'ı mola ekranından komple durdurabilme

---

## 🖼️ Ekran Görüntüleri

### Menü Çubuğu (Çalışırken)
```
 👁️ ⏱ 18:45
┌─────────────────────┐
│  ⏹️ Stop             │
│  ─────────────────── │
│  ⚙️ Settings         │
│  ─────────────────── │
│  ❌ Exit             │
└─────────────────────┘
```

### Mola Ekranı
```
┌─────────────────────────────────┐
│                                 │
│         👁️ (animasyonlu)        │
│                                 │
│     Time for an Eye Break!      │
│   Look at something 20 feet     │
│     (6 meters) away             │
│                                 │
│          00:15                  │
│     ███████████████░░░░░        │
│                                 │
│  [🛑 Stop Timer]  [⏭ Skip]     │
│                                 │
└─────────────────────────────────┘
```

### Ayarlar Ekranı
```
┌─────────────────────────────────┐
│  ✕  ⚙️ Settings                 │
│                                 │
│  💼 Work Duration               │
│     ⊖ 1 min ⊕   ⊖ 0 sec ⊕    │
│                                 │
│  👁️ Break Duration              │
│     ⊖ 20 sec ⊕                 │
│                                 │
│  🕐 Show Counter        [ON]   │
│  🚀 Launch at Login     [OFF]  │
│                                 │
│     [ Save & Close ]            │
└─────────────────────────────────┘
```

---

## 🏗️ Mimari

Proje **Clean Architecture** prensiplerine göre yapılandırılmıştır:

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── injection_container.dart     # Dependency Injection (GetIt)
│
├── core/                        # Çekirdek katman
│   ├── constants/
│   │   └── app_constants.dart   # Sabitler (süreler, metinler)
│   ├── error/
│   │   └── failures.dart        # Hata sınıfları
│   ├── localization/
│   │   ├── locale_keys.dart     # Çeviri anahtarları
│   │   └── localization_service.dart  # Çeviri servisi
│   └── services/
│       ├── auto_launch_service.dart   # macOS Login Items yönetimi
│       └── window_service.dart        # Pencere gösterme/gizleme
│
├── domain/                      # İş mantığı katmanı
│   ├── entities/
│   │   └── timer_session.dart   # Timer oturumu entity
│   ├── repositories/
│   │   ├── notification_repository.dart  # Bildirim arayüzü
│   │   └── timer_repository.dart         # Timer arayüzü
│   └── usecases/
│       ├── send_break_notification.dart  # Bildirim gönderme
│       ├── start_timer.dart              # Timer başlatma
│       └── stop_timer.dart               # Timer durdurma
│
├── data/                        # Veri katmanı
│   └── repositories/
│       ├── notification_repository_impl.dart  # Bildirim implementasyonu
│       └── timer_repository_impl.dart         # Stream.periodic timer
│
└── presentation/                # Sunum katmanı
    ├── bloc/
    │   ├── eye_care_bloc.dart   # Ana BLoC
    │   ├── eye_care_event.dart  # BLoC olayları
    │   └── eye_care_state.dart  # BLoC durumları
    ├── screens/
    │   ├── break_screen.dart    # Tam ekran mola penceresi
    │   └── settings_screen.dart # Ayarlar ekranı
    └── tray/
        └── tray_manager_service.dart  # System Tray yönetimi
```

### Mimari Diyagramı

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ TrayManager  │  │ BreakScreen  │  │ SettingsScreen   │  │
│  │   Service    │  │              │  │                  │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
│         │                 │                    │            │
│         ▼                 ▼                    ▼            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  EyeCareBloc                        │   │
│  │                (flutter_bloc)                       │   │
│  └──────────────────────┬──────────────────────────────┘   │
└─────────────────────────┼──────────────────────────────────┘
                          │
┌─────────────────────────┼──────────────────────────────────┐
│                  DOMAIN  │                                  │
│  ┌────────────────┐  ┌───┴───────────┐                     │
│  │ TimerSession   │  │   UseCases    │                     │
│  │   (Entity)     │  │               │                     │
│  └────────────────┘  └───────┬───────┘                     │
│                              │                              │
│  ┌───────────────────────────┴────────────────────────┐    │
│  │              Repository Interfaces                  │    │
│  │  NotificationRepository  │  TimerRepository         │    │
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┴────────────────────────────────┐
│                         DATA                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Repository Implementations                │    │
│  │  NotificationRepositoryImpl  │  TimerRepositoryImpl  │    │
│  │     (osascript)              │   (Stream.periodic)   │    │
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                     CORE SERVICES                            │
│  WindowService  │  AutoLaunchService  │  LocalizationService │
└──────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Teknolojiler

| Paket | Versiyon | Açıklama |
|-------|----------|----------|
| `flutter_bloc` | ^9.1.1 | State management |
| `get_it` | ^9.2.0 | Dependency injection |
| `tray_manager` | ^0.5.2 | macOS system tray |
| `window_manager` | ^0.4.3 | Pencere yönetimi (mola/ayar ekranları) |
| `shared_preferences` | ^2.5.4 | Ayarların kalıcı saklanması |
| `easy_localization` | ^3.0.8 | Çoklu dil desteği (TR/EN) |
| `equatable` | ^2.0.8 | Value equality |

---

## 📋 Gereksinimler

- **macOS** 10.15 (Catalina) veya üzeri
- **Flutter** 3.x
- **Dart** 3.11.0 veya üzeri
- **Xcode** 14.0 veya üzeri

---

## 🚀 Kurulum

### 1. Repoyu klonlayın
```bash
git clone https://github.com/mfurkanyuceal/eyecare_mac.git
cd eyecare_mac
```

### 2. Bağımlılıkları yükleyin
```bash
flutter pub get
```

### 3. macOS için derleyin
```bash
flutter build macos
```

### 4. Uygulamayı çalıştırın
```bash
flutter run -d macos
```

Veya derlenmiş uygulamayı açın:
```bash
open build/macos/Build/Products/Release/eyecare_mac.app
```

---

## 📖 Kullanım

1. **Uygulamayı başlatın** — Menü çubuğunda göz ikonu görünecek
2. **İkona tıklayın** — Bağlam menüsü açılır
3. **"Start"** — Geri sayım başlar, menü çubuğunda süre görünür
4. **Çalışın** — Menü çubuğunda `⏱ 19:45` gibi kalan süre anlık güncellenir
5. **Mola zamanı** — Süre dolduğunda tam ekran mola penceresi açılır
6. **Mola verin** — 20 saniye (veya ayarladığınız süre) boyunca uzaklara bakın
7. **Otomatik devam** — Mola sonunda ses çalar ve yeni döngü başlar
8. **"Stop"** — Timer'ı istediğiniz zaman menüden veya mola penceresinden durdurun
9. **"Settings"** — Çalışma/mola sürelerini, sayaç görünürlüğünü ve otomatik başlatmayı ayarlayın
10. **"Exit"** — Uygulamayı kapatın

### ⚙️ Ayarlar

| Ayar | Açıklama | Varsayılan |
|------|----------|------------|
| Work Duration (min) | Çalışma süresi — dakika | 20 min |
| Work Duration (sec) | Çalışma süresi — ek saniye (10'ar adım) | 0 sec |
| Break Duration | Mola süresi | 20 sec |
| Show Counter | Menü çubuğunda geri sayımı göster/gizle | Açık |
| Launch at Login | Bilgisayar açılışında otomatik başlat | Kapalı |

---

## 🧪 Test

```bash
# Unit testleri çalıştır
flutter test

# Belirli bir test dosyasını çalıştır
flutter test test/widget_test.dart
```

---

## 🤝 Katkıda Bulunma

1. Bu repoyu fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 👤 Geliştirici

**Muhammed Furkan Yüceal**

- GitHub: [@mfurkanyuceal](https://github.com/mfurkanyuceal)

---

## 🙏 Teşekkürler

- [20-20-20 Rule](https://www.aao.org/eye-health/tips-prevention/computer-usage) — American Academy of Ophthalmology
- [Flutter](https://flutter.dev) — UI toolkit
- [tray_manager](https://pub.dev/packages/tray_manager) — System tray paketi
- [window_manager](https://pub.dev/packages/window_manager) — Pencere yönetimi paketi

---

<p align="center">
  Gözlerinize iyi bakın! 👁️✨
</p>
