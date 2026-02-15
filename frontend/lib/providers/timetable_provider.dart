import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for timetable state management
final timetableProvider = StateNotifierProvider<TimetableNotifier, AsyncValue<Timetable?>>((ref) {
  return TimetableNotifier();
});

/// Notifier class for managing timetable state
class TimetableNotifier extends StateNotifier<AsyncValue<Timetable?>> {
  TimetableNotifier() : super(const AsyncValue.loading());

  /// Fetch timetable from API or local storage
  Future<void> fetchTimetable(BuildContext context, {bool isGuest = false}) async {
    try {
      state = const AsyncValue.loading();
      
      Timetable? localTimetable = await SharedService().getTimetable();
      Timetable? response;
      
      if (!isGuest) {
        response = await ApiServices().getTimetable(context);
      }

      if (response == null) {
        if (localTimetable == null) {
          state = AsyncValue.data(Timetable(courses: {}, slots: []));
          return;
        } else {
          localTimetable.cleanUp();
          state = AsyncValue.data(localTimetable);
          return;
        }
      } else {
        response.cleanUp();
        state = AsyncValue.data(response);
        await SharedService().saveTimetable(response);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add a course to the timetable
  Future<void> addCourse({
    required String courseCode,
    required String courseName,
    required List<Lecture> lectures,
    String? classRoom,
    String? slot,
  }) async {
    final currentTimetable = state.value;
    if (currentTimetable == null) return;

    try {
      final updatedTimetable = currentTimetable.addCourse(
        courseCode,
        courseName,
        lectures,
        classRoom: classRoom,
        slot: slot,
      );
      
      state = AsyncValue.data(updatedTimetable);
      
      // Save to backend and local storage
      final res = await ApiServices().postTimetable(updatedTimetable);
      if (res['status'] == 200) {
        await SharedService().saveTimetable(updatedTimetable);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update the entire timetable
  Future<void> updateTimetable(Timetable timetable) async {
    try {
      state = AsyncValue.data(timetable);
      
      // Save to backend and local storage
      final res = await ApiServices().postTimetable(timetable);
      if (res['status'] == 200) {
        await SharedService().saveTimetable(timetable);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Set timetable directly (useful for shared timetables)
  void setTimetable(Timetable? timetable) {
    state = AsyncValue.data(timetable);
  }

  /// Clear timetable
  void clearTimetable() {
    state = AsyncValue.data(Timetable(courses: {}, slots: []));
  }
}
