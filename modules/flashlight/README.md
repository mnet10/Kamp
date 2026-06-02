# Flashlight Module

Bu modül akıllı fener (flashlight) fonksiyonlarını içerir.

Özellikler
- Fener açma/kapatma
- SOS modu (yakıp söndürme)

Kullanım
1. `FlashlightPage` widget'ını uygulama navigasyonuna ekleyin:

```dart
GoRouter(
  routes: [
    GoRoute(path: '/flashlight', builder: (ctx, state) => const FlashlightPage()),
  ],
);
```

2. Fener servisinin testi veya mock'u için `FlashlightService` sınıfını geçebilirsiniz:

```dart
FlashlightPage(service: MockFlashlightService());
```

Not: Cihaz üzerinde çalıştırırken `torch_light` paketinin izinleri gereklidir.
