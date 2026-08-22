import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens & Layout
import '../../inventory/presentation/inventory.dart';
import '../../inventory/presentation/add_edit_medicine_page.dart';
import '../../inventory/presentation/scan_prescription_page.dart';
import '../../profile/presentation/profile.dart';
import '/core/widgets/bottom_nav_bar.dart';

// Models & Providers
import '../../inventory/models/medication_model.dart';
import '../../inventory/providers/medication_provider.dart';
import '../../inventory/providers/notifications_provider.dart';
import 'notification_page.dart';

// Local Widgets
import 'widgets/medication_card.dart';

final firstNameProvider = Provider<String>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  final rawName = (user?.userMetadata?['full_name'] as String? ?? '').trim();
  if (rawName.isEmpty) return 'User';
  return rawName.split(' ').first;
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDay;
  late DateTime _weekStart;

  int _currentIndex = 0;

  static const _primaryBlue = Color(0xFF38C2EE);
  static const _bgColor = Color(0xFFEAF6FB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = DateTime.now();
    _weekStart = _mondayOf(_selectedDay);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Date Helpers
  DateTime _mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  String _monthLabel(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _dayName(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }

  String _dateLabel(DateTime d) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = ref.watch(firstNameProvider);
    final morningMeds = ref.watch(morningMedsProvider);
    final afternoonMeds = ref.watch(afternoonMedsProvider);
    final eveningMeds = ref.watch(eveningMedsProvider);
    final statusMap = ref.watch(medicationStatusProvider);

    return Scaffold(
      backgroundColor: _bgColor,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(
            firstName,
            morningMeds,
            afternoonMeds,
            eveningMeds,
            statusMap,
          ), // Index 0
          const InventoryPage(), // Index 1
          const ProfilePage(), // Index 2
        ],
      ),

      // Nav Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            _showAddOptions(context);
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // ── Add-medicine bottom sheet ──────────────────────────────────────
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFEAF6FB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Option 1 – Scan
              ListTile(
                leading: Icon(
                  Icons.document_scanner_rounded,
                  color: _primaryBlue,
                  size: 28.sp,
                ),
                title: Text(
                  'Scan Prescription',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Let AI extract the details for you',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _scanPrescription(context);
                },
              ),

              const Divider(),

              // Option 2 – Manual
              ListTile(
                leading: Icon(
                  Icons.edit_note_rounded,
                  color: _primaryBlue,
                  size: 28.sp,
                ),
                title: Text(
                  'Enter Manually',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Type in the medication details yourself',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditMedicinePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder – replace with your actual scan logic
  void _scanPrescription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanPrescriptionPage()),
    );
  }

  Widget _buildHomeContent(
    String firstName,
    List<MedicationModel> morningMeds,
    List<MedicationModel> afternoonMeds,
    List<MedicationModel> eveningMeds,
    Map<String, MedicationStatus> statusMap,
  ) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(firstName),
          _buildCalendarStrip(),
          _buildTabBar(afternoonMeds, eveningMeds, statusMap),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedList(morningMeds),
                _buildMedList(afternoonMeds),
                _buildMedList(eveningMeds),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action Button
  Widget _buildTopBar(String firstName) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateLabel(_selectedDay),
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
                        style: const TextStyle(color: Color(0xFF38C2EE)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
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
  Widget _buildCalendarStrip() {
    return Container(
      color: _bgColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickMonth,
            child: Row(
              children: [
                Text(
                  _monthLabel(_selectedDay),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((day) {
              final isSelected =
                  day.day == _selectedDay.day &&
                  day.month == _selectedDay.month &&
                  day.year == _selectedDay.year;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _primaryBlue.withValues(alpha: 0.35),
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
                        _dayName(day),
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

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked;
        _weekStart = _mondayOf(picked);
      });
    }
  }

  Widget _buildTabBar(
    List<MedicationModel> afternoonMeds,
    List<MedicationModel> eveningMeds,
    Map<String, MedicationStatus> statusMap,
  ) {
    bool hasPending(List<MedicationModel> meds) => meds.any(
          (m) => statusMap[m.id ?? m.name] != MedicationStatus.taken,
        );

    return Container(
      color: _bgColor,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelPadding: EdgeInsets.zero,
        indicatorColor: _primaryBlue,
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
        labelColor: _primaryBlue,
        unselectedLabelColor: const Color(0xFF6C757D),
        tabs: [
          const Tab(text: 'Morning'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Afternoon'),
                if (afternoonMeds.isNotEmpty && hasPending(afternoonMeds)) ...[SizedBox(width: 4.w), _dot()],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Evening'),
                if (eveningMeds.isNotEmpty && hasPending(eveningMeds)) ...[SizedBox(width: 4.w), _dot()],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
    width: 6.w,
    height: 6.w,
    decoration: const BoxDecoration(
      color: Colors.redAccent,
      shape: BoxShape.circle,
    ),
  );

  Widget _buildMedList(List<MedicationModel> meds) {
    if (meds.isEmpty) return _buildEmptyState();
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: meds.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => MedicationCard(med: meds[i]),
    );
  }

  Widget _buildEmptyState() {
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
}
