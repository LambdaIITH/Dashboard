import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/providers/timetable_provider.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:dashbaord/widgets/notif_perm.dart';
import 'package:dashbaord/widgets/timetable/add_lectures_sheet.dart';
import 'package:dashbaord/widgets/timetable/day_view.dart';
import 'package:dashbaord/widgets/timetable/list_view.dart';
import 'package:dashbaord/widgets/timetable/manage_courses_sheet.dart';
import 'package:dashbaord/widgets/timetable/month_view.dart';
import 'package:dashbaord/widgets/timetable/week_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Timetable? timetable;
  final Function(String, String, List<Lecture>, String?, String?)?
      onLectureAdded;
  final Function(Timetable)? onEditTimetable;

  const CalendarScreen({
    super.key,
    required this.timetable,
    required this.onLectureAdded,
    required this.onEditTimetable,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  String selectedViewType = "List";
  List<String> viewTypeList = ["List", "Day", "Week", "Month"];
  DateTime? initialDate = DateTime.now();
  final List<CalendarEventData> _events = [];

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void requestNotifPerms(BuildContext bc) async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      return;
    }

    DateTime now = DateTime.now();
    String? lastDate = await SharedService().getLastPermsRequestDate();

    bool shouldAsk = false;

    if (lastDate != null) {
      DateTime lastDateParsed = DateFormat('dd-MM-yyyy').parse(lastDate.trim());
      Duration difference = now.difference(lastDateParsed);
      if (difference.inDays >= 1) {
        //TODO: change if it is annoying
        shouldAsk = true;
      }
    } else {
      shouldAsk = true;
    }

    if (shouldAsk) {
      _showNotificationPermissionSheet(context);
      SharedService().saveLastPermsRequestDate(
          date: DateFormat("dd-MM-yyyy").format(now).trim());
    }
  }

  void _showNotificationPermissionSheet(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const NotificationPermissionRequestBottomSheet();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestNotifPerms(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsyncValue = ref.watch(timetableProvider);
    
    return CalendarControllerProvider(
      controller: EventController()..addAll(_events),
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Calendar",
          actions: [
            Padding(
              padding: EdgeInsets.all(10),
              child: PopupMenuButton<String>(
                iconColor: context.customColors.customAccentColor,
                onSelected: (value) async {
                  if (value == "refresh") {
                    await ref.read(timetableProvider.notifier).fetchTimetable(context);
                    if (ref.read(timetableProvider).hasError) {
                      showError(msg: "Failed to fetch timetable");
                    }
                  } else if (value == "manageCourses") {
                    _showManageCoursesBottomSheet(context);
                  } else if (value == "shareCode") {
                    _shareSchedule();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: "refresh",
                    child: Row(
                      children: [
                        Icon(Icons.refresh,
                            color: context.customColors.customAccentColor),
                        SizedBox(width: 5),
                        Text("Refresh"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "manageCourses",
                    child: Row(
                      children: [
                        Icon(Icons.settings,
                            color: context.customColors.customAccentColor),
                        SizedBox(width: 5),
                        Text("Manage Courses"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "shareCode",
                    child: Row(
                      children: [
                        Icon(Icons.share,
                            color: context.customColors.customAccentColor),
                        SizedBox(width: 5),
                        Text("Share Timetable"),
                      ],
                    ),
                  ),
                ],
                icon: Icon(Icons.more_vert),
                color: Theme.of(context).cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          ],
        ),
        body: timetableAsyncValue.when(
          data: (timetable) => Column(
            children: [
              const SizedBox(
                height: 2,
              ),
              ToggleButtons(
                isSelected: viewTypeList
                    .map((viewType) => viewType == selectedViewType)
                    .toList(),
                onPressed: (int index) {
                  setState(() {
                    selectedViewType = viewTypeList[index];
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: context.customColors.customAccentColor,
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: MediaQuery.of(context).size.width * 2 / 9,
                ),
                children: viewTypeList.map((String viewType) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      viewType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: viewType == selectedViewType
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _getCurrentView(context, timetable),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error loading timetable')),
        ),
        floatingActionButton: _buildFABs(),
      ),
    );
  }

  Widget _getCurrentView(BuildContext context, Timetable? timetable) {
    switch (selectedViewType) {
      case "List":
        return ListViewScreen(
          context: context,
          timetable: timetable,
        );
      case "Day":
        return DayViewScreen(
            context: context, timetable: timetable, initialDate: initialDate);
      case "Week":
        return WeekViewScreen(
          context: context,
          timetable: timetable,
        );
      case "Month":
        return MonthViewScreen(
          context: context,
          timetable: timetable,
          onDayPressed: (date) {
            setState(() {
              selectedViewType = "Day";
              initialDate = date;
            });
          },
        );
      default:
        return DayViewScreen(
          context: context,
          timetable: timetable,
        );
    }
  }

  void _showAddEventBottomSheet(BuildContext context) {
    final timetable = ref.read(timetableProvider).value;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddLectureBottomSheet(
          timetable: timetable,
          onLectureAdded: (courseCode, courseName, lectures, classRoom, slot, segment) async {
            await ref.read(timetableProvider.notifier).addCourse(
              courseCode: courseCode,
              courseName: courseName,
              lectures: lectures,
              classRoom: classRoom,
              slot: slot,
            );
            widget.onLectureAdded!(
                courseCode, courseName, lectures, classRoom, slot);
          },
        );
        // return const AddEventBottomSheet();
      },
      isScrollControlled: true,
    );
  }

  void _showManageCoursesBottomSheet(BuildContext context) {
    final timetable = ref.read(timetableProvider).value;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ManageCoursesBottomSheet(
          timetable: timetable,
          onEditTimetable: (editedTimetable) async {
            await ref.read(timetableProvider.notifier).updateTimetable(editedTimetable);
            widget.onEditTimetable!(editedTimetable);
          },
        );
      },
      isScrollControlled: true,
    );
  }

  Widget _buildFABs() {
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        onPressed: () {
          _showAddEventBottomSheet(context);
        },
        backgroundColor: context.customColors.customAccentColor,
        child: Icon(
          CupertinoIcons.add,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  void _shareSchedule() async {
    final timetable = ref.read(timetableProvider).value;
    if (timetable == null) {
      showError(msg: "No timetable to share");
      return;
    }
    
    final courseDetails = timetable.courses.entries.map((entry) {
      final code = entry.key;
      final name = entry.value['title'];
      return '$code: $name';
    }).join('\n');

    try {
      final response = await ApiServices().shareTimetable();

      if (response['status'] == 200) {
        final code = response['code'];

        String shareableLink =
            'https://dashboard.iith.dev/share/timetable/$code';

        String shareMessage = '''
      I have registered for these courses:
$courseDetails

Click the link to add these courses to your timetable:
$shareableLink
    ''';

        if (kIsWeb) {
          await Clipboard.setData(ClipboardData(text: shareMessage));
          showError(
              msg:
                  "Succefully copied to clipboard. You can paste and share it easily!");
        } else {
          ShareResult result = await Share.share(shareMessage);
          if (result.status != ShareResultStatus.success) {
            await Clipboard.setData(ClipboardData(text: shareMessage));
            showError(
                msg:
                    "Succefully copied to clipboard. You can paste and share it easily!");
          }
        }
      } else {
        showError(msg: "Failed to share timetable");
      }
    } catch (e) {
      showError(msg: "Failed to share timetable");
    }
  }
}
