import 'package:flutter_test/flutter_test.dart';
import 'package:kamp/modules/sos/data/sos_repository.dart';
import 'package:kamp/modules/sos/domain/sos_model.dart';

void main() async {
  group('SosRepository basic', () {
    final repo = SosRepository();

    setUpAll(() async {
      await repo.init();
      await repo.clearAll();
    });

    test('add and get contacts', () async {
      final contact = SosContact(id: 'c1', name: 'Test', phone: '+123');
      await repo.addContact(contact);
      final list = await repo.getContacts();
      expect(list.any((c) => c.id == 'c1'), true);
    });

    test('add and get history', () async {
      final msg = SosMessage(id: 'm1', text: 'Help', latitude: 1.0, longitude: 2.0, timestamp: DateTime.now());
      await repo.addOrReplaceHistory(msg);
      final hist = await repo.getHistory();
      expect(hist.any((h) => h.id == 'm1'), true);
    });
  });
}
