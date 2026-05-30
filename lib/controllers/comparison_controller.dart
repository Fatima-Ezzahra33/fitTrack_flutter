/// FitTrack : Comparison Controller
///
/// Provider-based controller managing progress comparison state.
/// Handles saving images to persistent storage, inserting/fetching
/// comparisons from SQLite, and cleaning up deleted entries.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/comparison_model.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

class ComparisonController extends ChangeNotifier {
  final DatabaseService _dbService;
  final PreferencesService _prefsService;

  ComparisonController({
    required DatabaseService dbService,
    required PreferencesService prefsService,
  })  : _dbService = dbService,
        _prefsService = prefsService;

  // ── State ─────────────────────────────────────────────────────────
  List<ProgressComparison> _comparisons = [];
  bool _isLoading = false;

  // ── Getters ───────────────────────────────────────────────────────
  List<ProgressComparison> get comparisons => List.unmodifiable(_comparisons);
  bool get isLoading => _isLoading;

  // ════════════════════════════════════════════════════════════════════
  // LOAD COMPARISONS
  // ════════════════════════════════════════════════════════════════════

  /// Load all comparisons for the current user from SQLite.
  Future<void> loadComparisons() async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _comparisons = await _dbService.getComparisonsByUser(userId);
    } catch (e) {
      debugPrint('Failed to load comparisons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // SAVE COMPARISON
  // ════════════════════════════════════════════════════════════════════

  /// Persist a new comparison entry.
  ///
  /// Copies the [beforeImage] and [afterImage] files to the app's
  /// permanent documents directory so they survive app restarts.
  /// Then inserts a row into SQLite and refreshes the local list.
  Future<bool> saveComparison({
    required File beforeImage,
    required File afterImage,
    String? note,
  }) async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return false;

    try {
      // 1. Persist images to the app documents directory.
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory(p.join(appDir.path, 'progress_images'));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String beforeExt = p.extension(beforeImage.path);
      final String afterExt = p.extension(afterImage.path);

      final String beforeFileName = 'before_$timestamp$beforeExt';
      final String afterFileName = 'after_$timestamp$afterExt';

      final File persistedBefore = await beforeImage.copy(
        p.join(imageDir.path, beforeFileName),
      );
      final File persistedAfter = await afterImage.copy(
        p.join(imageDir.path, afterFileName),
      );

      // 2. Create the model and insert into SQLite.
      final ProgressComparison comparison = ProgressComparison(
        userId: userId,
        beforeImagePath: persistedBefore.path,
        afterImagePath: persistedAfter.path,
        note: note,
        createdAt: DateTime.now().toIso8601String(),
      );

      final int id = await _dbService.insertComparison(comparison);

      // 3. Add to local list (with the generated id).
      _comparisons.insert(0, comparison.copyWith(id: id));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to save comparison: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // DELETE COMPARISON
  // ════════════════════════════════════════════════════════════════════

  /// Delete a comparison by [id], removing DB row and persisted files.
  Future<bool> deleteComparison(int id) async {
    final int? userId = _prefsService.getCurrentUserId();
    if (userId == null) return false;

    try {
      // Find the entry to get file paths before deleting.
      final ProgressComparison? entry = _comparisons
          .cast<ProgressComparison?>()
          .firstWhere((c) => c!.id == id, orElse: () => null);

      await _dbService.deleteComparison(id, userId);

      // Remove files from disk.
      if (entry != null) {
        final File beforeFile = File(entry.beforeImagePath);
        final File afterFile = File(entry.afterImagePath);
        if (await beforeFile.exists()) await beforeFile.delete();
        if (await afterFile.exists()) await afterFile.delete();
      }

      _comparisons.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to delete comparison: $e');
      return false;
    }
  }
}
