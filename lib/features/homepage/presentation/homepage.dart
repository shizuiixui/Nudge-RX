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

// Homepage widgets
import 'widgets/homepage_widgets.dart';

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
  final Set<int> _visitedTabs = {0};

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _selectedDay = DateTime.now();
    _weekStart = _mondayOf(_selectedDay);
  }

  void _handleTabSelection() {
    if (!_visitedTabs.contains(_tabController.index)) {
      setState(() {
        _visitedTabs.add(_tabController.index);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
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
        _visitedTabs.clear();
        _visitedTabs.add(_tabController.index);
      });
    }
  }

  // Navigation Bar Helpers

  /// Opens the "Add Medicine" bottom sheet with Scan / Manual options
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBgColor,
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
                  color: kPrimaryBlue,
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
                  color: kPrimaryBlue,
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

  /// Navigates to the prescription scanner camera page.
  void _scanPrescription(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScanPrescriptionPage()));
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final firstName = ref.watch(firstNameProvider);
    final morningMeds = ref.watch(morningMedsProvider);
    final afternoonMeds = ref.watch(afternoonMedsProvider);
    final eveningMeds = ref.watch(eveningMedsProvider);
    final statusMap = ref.watch(medicationStatusProvider);

    return Scaffold(
      backgroundColor: kBgColor,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Index 0 — Home tab content
          _buildHomeContent(
            firstName,
            morningMeds,
            afternoonMeds,
            eveningMeds,
            statusMap,
          ),
          // Index 1 — Add Medicine
          const SizedBox.shrink(),
          // Index 2 — Inventory
          const InventoryPage(),
          // Index 3 — Profile
          const ProfilePage(),
        ],
      ),

      // Bottom navigation bar
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

  // Top Bar
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
          buildTopBar(
            context: context,
            ref: ref,
            firstName: firstName,
            dateLabel: _dateLabel(_selectedDay),
          ),
          buildCalendarStrip(
            selectedDay: _selectedDay,
            weekDays: _weekDays,
            monthLabel: _monthLabel(_selectedDay),
            dayName: _dayName,
            onPickMonth: _pickMonth,
            onDaySelected: (day) => setState(() {
              _selectedDay = day;
              _visitedTabs.clear();
              _visitedTabs.add(_tabController.index);
            }),
          ),
          buildMedicationTabBar(
            tabController: _tabController,
            morningMeds: morningMeds,
            afternoonMeds: afternoonMeds,
            eveningMeds: eveningMeds,
            statusMap: statusMap,
            visitedTabs: _visitedTabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildMedList(morningMeds),
                buildMedList(afternoonMeds),
                buildMedList(eveningMeds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
