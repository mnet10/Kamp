# Morse Module

Bu modül Mors kodlarıyla ilgili altyapıyı sağlar: kodlama, deşifre ve
fener ile gönderme için temel servis.

Mevcut fonksiyonlar:
- Metin -> Mors (encode)
- Mors -> Metin (decode)
- Mors -> Zamanlama (timings)
- Flashlight üzerinden gönderme (basit, bloklayan implemantasyon)

Kullanım:
- `MorsePage` UI bileşeni test amaçlıdır.
- Gerçek çalışma sırasında `sendViaFlash` uzun sürebilir; UI'da
  arka plan görevleri veya izolasyon kullanılmalıdır.
