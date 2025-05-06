import 'package:dashbaord/main.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/services/event_notification_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsBottomSheet extends StatefulWidget {
  final Function(bool) onNotificationsToggle;
  final Function(int?) onReminderOffsetChange;

  const NotificationSettingsBottomSheet({
    super.key,
    required this.onNotificationsToggle,
    required this.onReminderOffsetChange,
  });

  @override
  State<NotificationSettingsBottomSheet> createState() =>
      _NotificationSettingsBottomSheetState();
}

class _NotificationSettingsBottomSheetState
    extends State<NotificationSettingsBottomSheet> {
  bool _notificationsEnabled = true;
  int _reminderOffsetMinutes = 10;
  Timetable? timetable;

  Future<void> fetchTimetable() async {
    Timetable? localTimetable = await SharedService().getTimetable();

    if (localTimetable == null) {
      setState(() {
        timetable = null;
      });
      return;
    } else {
      localTimetable.cleanUp();
      setState(() {
        timetable = localTimetable;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    fetchTimetable();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _reminderOffsetMinutes = prefs.getInt('reminderOffsetMinutes') ?? 15;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('reminderOffsetMinutes', _reminderOffsetMinutes);
    clearAllNotifications();
    EventNotificationService.scheduleWeeklyNotifications(timetable: timetable!);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(25),
      shadowColor: Colors.white.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            Text(
              "Notification Settings",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                widget.onNotificationsToggle(value);
                _saveSettings();
              },
            ),
            const Divider(),
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                // child: _notificationsEnabled
                // ?
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Reminder Offset",
                        style: TextStyle(
                          color: _notificationsEnabled
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        "Notify me $_reminderOffsetMinutes minutes before class",
                        style: TextStyle(
                          color: _notificationsEnabled
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey,
                        ),
                      ),
                      trailing: _notificationsEnabled
                          ? DropdownButton<int>(
                              value: _reminderOffsetMinutes,
                              items: [5, 10, 15, 30, 60]
                                  .map((minutes) => DropdownMenuItem<int>(
                                        value: minutes,
                                        child: Text(
                                          "$minutes minutes",
                                          style: TextStyle(
                                            color: _notificationsEnabled
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color
                                                : Colors.grey,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                widget.onReminderOffsetChange(value);
                                setState(() {
                                  _reminderOffsetMinutes = value ?? 15;
                                });
                                _saveSettings();
                              },
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "$_reminderOffsetMinutes minutes",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _notificationsEnabled
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                        : Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: _notificationsEnabled
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                      : Colors.grey,
                                )
                              ],
                            ),
                    ),
                    const Divider(),
                  ],
                )
                // : SizedBox.shrink(),
                ),
            ListTile(
              title: const Text("Clear Pending Notifications"),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  EventNotificationService.clearPendingNotifications(
                      flutterLocalNotificationsPlugin);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
