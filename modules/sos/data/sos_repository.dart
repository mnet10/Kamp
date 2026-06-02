import 'package:hive_flutter/hive_flutter.dart';
import '../domain/sos_model.dart';

/// Simple Hive-backed repository for SOS contacts and history.
/// Stores JSON maps to avoid generated TypeAdapters for the MVP.
class SosRepository {
  static const _contactsBox = 'sos_contacts';
  static const _historyBox = 'sos_history';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<Map>(_contactsBox);
    await Hive.openBox<Map>(_historyBox);
    _initialized = true;
  }

  Future<List<SosContact>> getContacts() async {
    await init();
    final box = Hive.box<Map>(_contactsBox);
    return box.values.map((m) => SosContact.fromJson(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> addContact(SosContact contact) async {
    await init();
    final box = Hive.box<Map>(_contactsBox);
    await box.put(contact.id, contact.toJson());
  }

  Future<void> removeContact(String id) async {
    await init();
    final box = Hive.box<Map>(_contactsBox);
    await box.delete(id);
  }

  Future<List<SosMessage>> getHistory() async {
    await init();
    final box = Hive.box<Map>(_historyBox);
    return box.values.map((m) => SosMessage.fromJson(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> addOrReplaceHistory(SosMessage msg) async {
    await init();
    final box = Hive.box<Map>(_historyBox);
    await box.put(msg.id, msg.toJson());
  }

  Future<void> clearAll() async {
    await init();
    await Hive.box<Map>(_contactsBox).clear();
    await Hive.box<Map>(_historyBox).clear();
  }
}
