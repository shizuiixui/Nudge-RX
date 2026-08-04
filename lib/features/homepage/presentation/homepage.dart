import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../inventory/presentation/add_edit_medicine_page.dart';
import '../../inventory/presentation/inventory.dart';
import '../../inventory/models/medication_model.dart';
import '../../inventory/providers/medication_provider.dart';

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

  // Helpers

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

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(firstName),
            _buildCalendarStrip(),
            _buildTabBar(afternoonMeds, eveningMeds),
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
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

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
          Stack(
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
                  Icons.notifications_outlined,
                  size: 20.sp,
                  color: Colors.black87,
                ),
              ),
              Positioned(
                top: 7.h,
                right: 7.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
  ) {
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
                if (afternoonMeds.isNotEmpty) ...[SizedBox(width: 4.w), _dot()],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Evening'),
                if (eveningMeds.isNotEmpty) ...[SizedBox(width: 4.w), _dot()],
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
      itemBuilder: (_, i) => _MedCard(med: meds[i]),
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: true,
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Inventory',
                active: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InventoryPage(),
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditMedicinePage(),
                    ),
                  );
                },
                child: Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: _primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ),
              const _NavItem(
                icon: Icons.bar_chart_outlined,
                label: 'Status',
                active: false,
              ),
              const _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                active: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final MedicationModel med;

  const _MedCard({required this.med});

  static const _primaryBlue = Color(0xFF38C2EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: _primaryBlue,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      med.dosage ?? '',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, size: 18.sp, color: Colors.black45),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            med.formattedTime,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: Colors.black54,
            ),
          ),
          Text(
            med.frequencyDisplay,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Skip',
                  icon: Icons.close_rounded,
                  color: Colors.redAccent,
                  onTap: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ActionButton(
                  label: 'Done',
                  icon: Icons.check_rounded,
                  color: _primaryBlue,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  static const _primaryBlue = Color(0xFF38C2EE);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: active ? _primaryBlue : const Color(0xFFADB5BD),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.sp,
              color: active ? _primaryBlue : const Color(0xFFADB5BD),
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
