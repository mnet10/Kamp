# SOS Module - Persistence & Permissions

Eklentiler:
- Hive tabanlı basit repository (`modules/sos/data/sos_repository.dart`) eklendi.
  - Contacts ve History box'ları Map olarak saklanır (mvp amaçlı, TypeAdapter yok).
- `PermissionService` eklendi (`modules/sos/domain/permission_service.dart`) — permission_handler
  sarmalayıcısıdır.

Değişiklikler:
- `SosService` artık isteğe bağlı olarak `SosRepository` ve `PermissionService` alabilir.
  - Eğer repository verilirse veriler Hive üzerinde saklanır.
  - Eğer permissionService verilirse lokasyon izni otomatik olarak istenir/kontrol edilir.

Notlar:
- pubspec.yaml'da `permission_handler` eklendi; native platformlarda gerekli manifest/plist
  izin açıklamalarını ekleyin.
- `SosRepository.init()` Hive'i başlatır; uygulama başında çağırmak isteyebilirsiniz (ör. main.dart içinde).

Kısa kullanım:

```dart
final repo = SosRepository();
await repo.init();
final perm = PermissionService();
final service = SosService(repository: repo, permissionService: perm);
```

Daha sonra `SosPage(service: service)` ile UI'ya inject edebilirsiniz.
