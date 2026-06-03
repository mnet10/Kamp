# Background Morse Sending

Bu eklenti Morse mesajlarını göndermeyi UI'yi bloklamadan sağlayan bir controller içerir.

- `MorseSendController`:
  - `startSending(text)` başlatır, `progressStream` üzerinden ilerleme bildirir.
  - `cancel()` ile gönderim iptal edilebilir.
- `compute` kullanılarak zamanlamalar izolede hesaplanır.
- Fener açma/kapatma ana izolede yapılır (platform kanalları izolede çalışmaz).

Notlar:
- Uzun mesajlarda performans iyileştirmesi için hesaplamalar izolede yapılır.
- İptal edildiğinde fener kapatılmaya çalışılır.
