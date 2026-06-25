import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class BillPhotoDao {
  final AppDatabase _db;
  const BillPhotoDao(this._db);

  static const _uuid = Uuid();

  Future<List<BillPhoto>> getPhotosForEvent(String eventId) {
    return (_db.select(_db.billPhotos)
          ..where((p) => p.eventId.equals(eventId))
          ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
        .get();
  }

  Future<void> addPhoto(String eventId, String filePath) async {
    await _db.into(_db.billPhotos).insert(BillPhotosCompanion.insert(
      id: _uuid.v4(),
      eventId: eventId,
      filePath: filePath,
      createdAt: DateTime.now().toIso8601String(),
    ));
  }

  Future<void> deletePhoto(String id) {
    return (_db.delete(_db.billPhotos)..where((p) => p.id.equals(id))).go();
  }

  Future<Set<String>> getEventIdsWithPhotos() async {
    final rows = await (_db.selectOnly(_db.billPhotos)
          ..addColumns([_db.billPhotos.eventId]))
        .map((r) => r.read(_db.billPhotos.eventId)!)
        .get();
    return rows.toSet();
  }

  /// Deletes all photos for an event from the DB and returns their file paths
  /// so the caller can delete the actual files from disk.
  Future<List<String>> deletePhotosForEvent(String eventId) async {
    final photos = await getPhotosForEvent(eventId);
    await (_db.delete(_db.billPhotos)
          ..where((p) => p.eventId.equals(eventId)))
        .go();
    return photos.map((p) => p.filePath).toList();
  }
}
