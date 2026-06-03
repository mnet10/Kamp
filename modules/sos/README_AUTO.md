# SOS Auto

SosAutoService, SOS tetiklendiğinde otomatik olarak Morse/fener gönderimini başlatmak için kullanılır.
- Varsayılan olarak kapalıdır (ayarlar üzerinden açılmalıdır).
- sendflash-bg ile geliştirilen MorseSendController ile entegredir.

Gereksinimler:
- SosService (olay yayınlayan servis)
- MorseSendController

Kullanım örneği:

final auto = SosAutoService(sosService: sosService, morseController: morseController);
auto.enabled = true; // kullanıcı ayarı
auto.start();

