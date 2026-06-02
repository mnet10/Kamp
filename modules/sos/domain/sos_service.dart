import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'sos_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/sos_repository.dart';
import 'permission_service.dart';

/// A lightweight SOS service with dependency injection-friendly design.
///
/// - [locationProvider] can be injected for testing (defaults to Geolocator.getCurrentPosition)
/// - [smsLauncher] can be injected for testing (defaults to launching sms: URIs)
class SosService {
  final Future<Position> Function()? locationProvider;
  final Future<void> Function(String url)? smsLauncher;
  final SosRepository? repository;
  final PermissionService? permissionService;

  final List<SosContact> _contactsMemory = [];
  final List<SosMessage> _historyMemory = [];

  SosService({this.locationProvider, this.smsLauncher, this.repository, this.permissionService});

  Future<List<SosContact>> getContacts() async {
    if (repository != null) return await repository!.getContacts();
    return List.unmodifiable(_contactsMemory);
  }

  Future<List<SosMessage>> getHistory() async {
    if (repository != null) return await repository!.getHistory();
    return List.unmodifiable(_historyMemory);
  }

  Future<void> addContact(SosContact contact) async {
    if (repository != null) {
      await repository!.addContact(contact);
    } else {
      _contactsMemory.add(contact);
    }
  }

  Future<void> removeContact(String id) async {
    if (repository != null) {
      await repository!.removeContact(id);
    } else {
      _contactsMemory.removeWhere((c) => c.id == id);
    }
  }

  Future<Position?> _getLocationSafe() async {
    try {
      if (permissionService != null) {
        final ok = await permissionService!.isLocationGranted();
        if (!ok) {
          final granted = await permissionService!.requestLocation();
          if (!granted) return null;
        }
      }

      if (locationProvider != null) return await locationProvider!();
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      return null;
    }
  }

  String _formatMessage(String base, double? lat, double? lng) {
    final buffer = StringBuffer();
    buffer.writeln(base);
    if (lat != null && lng != null) {
      buffer.writeln();
      buffer.writeln('Konum: https://maps.google.com/?q=$lat,$lng');
    } else {
      buffer.writeln();
      buffer.writeln('Konum: Bilinmiyor');
    }
    buffer.writeln();
    buffer.writeln('--- AcousticVision V5 - Otomatik SOS');
    return buffer.toString();
  }

  Future<SosMessage> createAndSendSos({required String text, bool includeLocation = true, List<SosContact>? recipients}) async {
    final id = const Uuid().v4();
    double? lat;
    double? lng;
    if (includeLocation) {
      final pos = await _getLocationSafe();
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
      }
    }

    var msg = SosMessage(id: id, text: text, latitude: lat, longitude: lng, timestamp: DateTime.now(), status: SosStatus.sending);

    // persist initial sending state
    if (repository != null) await repository!.addOrReplaceHistory(msg);
    else _historyMemory.add(msg);

    final body = Uri.encodeComponent(_formatMessage(text, lat, lng));

    final phones = (recipients ?? (await getContacts())).map((c) => c.phone).where((p) => p.isNotEmpty).toList();
    if (phones.isEmpty) {
      // nothing to do, mark failed
      msg = SosMessage(id: msg.id, text: msg.text, latitude: lat, longitude: lng, timestamp: msg.timestamp, status: SosStatus.failed);
      if (repository != null) await repository!.addOrReplaceHistory(msg);
      else _replaceHistory(msg);
      return msg;
    }

    final smsLauncherImpl = smsLauncher ?? _defaultSmsLauncher;
    // Build url for multiple recipients: sms:<num1>,<num2>?body=<text>
    final recipientPart = phones.join(',');
    final url = 'sms:$recipientPart?body=$body';

    try {
      await smsLauncherImpl(url);
      msg = SosMessage(id: msg.id, text: msg.text, latitude: lat, longitude: lng, timestamp: msg.timestamp, status: SosStatus.sent);
      if (repository != null) await repository!.addOrReplaceHistory(msg);
      else _replaceHistory(msg);
      return msg;
    } catch (e) {
      msg = SosMessage(id: msg.id, text: msg.text, latitude: lat, longitude: lng, timestamp: msg.timestamp, status: SosStatus.failed);
      if (repository != null) await repository!.addOrReplaceHistory(msg);
      else _replaceHistory(msg);
      return msg;
    }
  }

  Future<void> _defaultSmsLauncher(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      throw Exception('Cannot launch SMS app');
    }
    await launchUrl(uri);
  }

  void _replaceHistory(SosMessage msg) {
    final idx = _historyMemory.indexWhere((m) => m.id == msg.id);
    if (idx >= 0) _historyMemory[idx] = msg;
  }
}
