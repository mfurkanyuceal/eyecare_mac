# 👁️ EyeCare Mac

**macOS menü çubuğunda çalışan göz dinlendirme uygulaması**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📖 Hakkında

EyeCare Mac, **20-20-20 kuralına** dayalı bir göz sağlığı uygulamasıdır:

> **Her 20 dakikada bir, 20 saniye boyunca 6 metre (20 feet) uzağa bakın.**

Uygulama tamamen macOS menü çubuğunda (System Tray) çalışır ve Dock'ta görünmez. Çalışma sürenizi takip eder ve mola zamanı geldiğinde size native macOS bildirimi gönderir.

---

## ✨ Özellikler

- 🕐 **20 dakikalık çalışma döngüsü** - Otomatik geri sayım
- 👁️ **20 saniyelik mola hatırlatıcısı** - Native macOS bildirimleri
- 🖥️ **Menü çubuğu entegrasyonu** - Dock'ta yer kaplamaz
- 🔄 **Otomatik döngü** - Mola sonrası otomatik yeniden başlatma
- ⏯️ **Basit kontroller** - Başlat, Durdur, Çıkış

---

## 🖼️ Ekran Görüntüleri

### Menü Çubuğu
```
┌─────────────────────────────────┐
│  👁️ ▼                          │
├─────────────────────────────────┤
│  💼 Çalışıyor: 18:45            │
│  ─────────────────────          │
│  ⏹️ Durdur                      │
│  ─────────────────────          │
│  ❌ Çıkış                       │
└─────────────────────────────────┘
```

### Bildirim
```
┌─────────────────────────────────┐
│  Göz Molası Zamanı! 👁️          │
│  20 saniye boyunca 6 metre      │
│  uzağa bakın.                   │
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
│   └── error/
│       └── failures.dart        # Hata sınıfları
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
│       ├── notification_repository_impl.dart  # osascript ile bildirim
│       └── timer_repository_impl.dart         # Stream.periodic timer
│
└── presentation/                # Sunum katmanı
    ├── bloc/
    │   ├── eye_care_bloc.dart   # Ana BLoC
    │   ├── eye_care_event.dart  # BLoC olayları
    │   └── eye_care_state.dart  # BLoC durumları
    └── tray/
        └── tray_manager_service.dart  # System Tray yönetimi
```

### Mimari Diyagramı

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION                           │
│  ┌─────────────────┐      ┌─────────────────────────────┐  │
│  │  TrayManager    │◄────►│       EyeCareBloc           │  │
│  │    Service      │      │  (flutter_bloc)             │  │
│  └─────────────────┘      └──────────────┬──────────────┘  │
└──────────────────────────────────────────┼─────────────────┘
                                           │
┌──────────────────────────────────────────┼─────────────────┐
│                       DOMAIN             │                  │
│  ┌────────────────┐  ┌───────────────┐  │                  │
│  │ TimerSession   │  │   UseCases    │◄─┘                  │
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
```

---

## 🛠️ Teknolojiler

| Paket | Versiyon | Açıklama |
|-------|----------|----------|
| `flutter_bloc` | ^9.1.1 | State management |
| `get_it` | ^9.2.0 | Dependency injection |
| `tray_manager` | ^0.5.2 | macOS system tray |
| `equatable` | ^2.0.7 | Value equality |

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

1. **Uygulamayı başlatın** - Menü çubuğunda göz ikonu görünecek
2. **İkona tıklayın** - Bağlam menüsü açılır
3. **"Başlat"** - 20 dakikalık geri sayım başlar
4. **Çalışın** - Menüden kalan süreyi takip edebilirsiniz
5. **Mola zamanı** - 20 dakika sonunda bildirim alırsınız
6. **Mola verin** - 20 saniye uzaklara bakın
7. **Otomatik devam** - Mola sonunda yeni döngü başlar
8. **"Durdur"** - Timer'ı istediğiniz zaman durdurun
9. **"Çıkış"** - Uygulamayı kapatın

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

- [20-20-20 Rule](https://www.aao.org/eye-health/tips-prevention/computer-usage) - American Academy of Ophthalmology
- [Flutter](https://flutter.dev) - UI toolkit
- [tray_manager](https://pub.dev/packages/tray_manager) - System tray paketi

---

<p align="center">
  Gözlerinize iyi bakın! 👁️✨
</p>
