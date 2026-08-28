import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../inventory/models/medication_model.dart';
import '../../../inventory/providers/medication_provider.dart';
import '../../../inventory/providers/notifications_provider.dart';
import '../notification_page.dart';
import 'medication_card.dart';

const Color kPrimaryBlue = Color(0xFF38C2EE);
const Color kBgColor = Color(0xFFEAF6FB);

// Top Bar — greeting text, date label, and notification bell

Widget buildTopBar({
  required BuildContext context,
  required WidgetRef ref,
  required String firstName,
  required String dateLabel,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: const Color(0xFF6C757D),
                ),
              ),
              SizedBox(height: 2.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(text: 'Hi, '),
                    TextSpan(
                      text: '$firstName!',
                      style: const TextStyle(color: kPrimaryBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Notification bell with unread indicator
        GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NotificationPage()));
          },
          child: Stack(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications,
                  size: 20.sp,
                  color: Colors.black87,
                ),
              ),
              if (ref.watch(hasUnreadNotificationsProvider))
                Positioned(
                  top: 2.h,
                  right: 2.w,
                  child: Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Calendar Strip

Widget buildCalendarStrip({
  required DateTime selectedDay,
  required List<DateTime> weekDays,
  required String monthLabel,
  required String Function(DateTime) dayName,
  required VoidCallback onPickMonth,
  required ValueChanged<DateTime> onDaySelected,
}) {
  return Container(
    color: kBgColor,
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month label + dropdown arrow
        GestureDetector(
          onTap: onPickMonth,
          child: Row(
            children: [
              Text(
                monthLabel,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18.sp,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),

        // Day chips row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((day) {
            final isSelected =
                day.day == selectedDay.day &&
                day.month == selectedDay.month &&
                day.year == selectedDay.year;
            return GestureDetector(
              onTap: () => onDaySelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: kPrimaryBlue.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName(day),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.sp,
                        color: isSelected
                            ? Colors.white70
                            : const Color(0xFF6C757D),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${day.day}'.padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    ),
  );
}

// Medication Tab Bar — Morning / Afternoon / Evening tabs with pending-dot badges

Widget buildMedicationTabBar({
  required TabController tabController,
  required List<MedicationModel> morningMeds,
  required List<MedicationModel> afternoonMeds,
  required List<MedicationModel> eveningMeds,
  required Map<String, MedicationStatus> statusMap,
  required Set<int> visitedTabs,
}) {
  bool hasPending(List<MedicationModel> meds) =>
      meds.any((m) => statusMap[m.id ?? m.name] != MedicationStatus.taken);

  return Container(
    color: kBgColor,
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: TabBar(
      controller: tabController,
      isScrollable: false,
      labelPadding: EdgeInsets.zero,
      indicatorColor: kPrimaryBlue,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
      labelColor: kPrimaryBlue,
      unselectedLabelColor: const Color(0xFF6C757D),
      tabs: [
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Morning'),
              if (morningMeds.isNotEmpty &&
                  hasPending(morningMeds) &&
                  !visitedTabs.contains(0)) ...[
                SizedBox(width: 4.w),
                _pendingDot(),
              ],
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Afternoon'),
              if (afternoonMeds.isNotEmpty &&
                  hasPending(afternoonMeds) &&
                  !visitedTabs.contains(1)) ...[
                SizedBox(width: 4.w),
                _pendingDot(),
              ],
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Evening'),
              if (eveningMeds.isNotEmpty &&
                  hasPending(eveningMeds) &&
                  !visitedTabs.contains(2)) ...[
                SizedBox(width: 4.w),
                _pendingDot(),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

// Pending Red Dot
Widget _pendingDot() => Container(
  width: 6.w,
  height: 6.w,
  decoration: const BoxDecoration(
    color: Colors.redAccent,
    shape: BoxShape.circle,
  ),
);

// Medication List
Widget buildMedList(List<MedicationModel> meds) {
  if (meds.isEmpty) return buildEmptyState();
  return ListView.separated(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    itemCount: meds.length,
    separatorBuilder: (_, _) => SizedBox(height: 12.h),
    itemBuilder: (_, i) => MedicationCard(med: meds[i]),
  );
}

// Empty State
Widget buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.medication_outlined,
          size: 56.sp,
          color: const Color(0xFFB0DCF0),
        ),
        SizedBox(height: 12.h),
        Text(
          'No medications to take',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: const Color(0xFF6C757D),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Add medications from your inventory',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11.sp,
            color: const Color(0xFFADB5BD),
          ),
        ),
      ],
    ),
  );
}
