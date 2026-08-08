import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/medication_model.dart';
import '../providers/medication_provider.dart';

class InventoryItem {
  final String id;
  final String name;
  final String dosageInfo;
  final int takenCount;
  final int totalCount;
  final bool isLowStock;
  final bool isCompleted;
  final IconData iconData;
  final Color iconColor;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.dosageInfo,
    required this.takenCount,
    required this.totalCount,
    this.isLowStock = false,
    this.isCompleted = false,
    this.iconData = Icons.medication_rounded,
    this.iconColor = const Color(0xFF38C2EE),
  });
}

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  static const _primaryBlue = Color(0xFF38C2EE);
  static const _bgColor = Color(0xFFEAF6FB);

  bool _showActive = true; // true = Active tab, false = Completed tab
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<InventoryItem> _sampleItems = const [
    InventoryItem(
      id: '1',
      name: 'Bewell-C',
      dosageInfo: '500 mg, 1 capsule',
      takenCount: 16,
      totalCount: 30,
      iconData: Icons.medication_liquid_rounded,
      iconColor: Color(0xFF38C2EE),
    ),
    InventoryItem(
      id: '2',
      name: 'Biogesic',
      dosageInfo: '500 mg, 1 capsule',
      takenCount: 1,
      totalCount: 3,
      iconData: Icons.vaccines_rounded,
      iconColor: Color(0xFF8E44AD),
    ),
    InventoryItem(
      id: '3',
      name: 'Centrum Advance',
      dosageInfo: '500 mg, 1 capsule',
      takenCount: 25,
      totalCount: 30,
      isLowStock: true,
      iconData: Icons.vaccines_rounded,
      iconColor: Color(0xFF27AE60),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> _getDisplayItems(
    List<MedicationModel> userMeds,
    Map<String, MedicationStatus> statusMap,
  ) {
    List<InventoryItem> items = [];

    if (userMeds.isNotEmpty) {
      for (int i = 0; i < userMeds.length; i++) {
        final med = userMeds[i];
        final medId = med.id ?? med.name;
        final isTaken = statusMap[medId] == MedicationStatus.taken;
        items.add(
          InventoryItem(
            id: medId,
            name: med.name,
            dosageInfo: med.dosage ?? '500 mg, 1 capsule',
            takenCount: (i * 7 + 12) % 30,
            totalCount: 30,
            isCompleted: isTaken,
            isLowStock: i == 2 && !isTaken,
            iconData: i % 2 == 0
                ? Icons.medication_rounded
                : Icons.vaccines_rounded,
            iconColor: i % 2 == 0
                ? const Color(0xFF38C2EE)
                : const Color(0xFF8E44AD),
          ),
        );
      }
    } else {
      items = List.from(_sampleItems);
    }

    items = items.where((item) => item.isCompleted == !_showActive).toList();

    if (_searchQuery.isNotEmpty) {
      items = items
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.dosageInfo.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final medsAsync = ref.watch(medicationsProvider);
    final userMeds = medsAsync.valueOrNull ?? [];
    final statusMap = ref.watch(medicationStatusProvider);
    final displayItems = _getDisplayItems(userMeds, statusMap);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              // Title
              Text(
                'Inventory',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              _buildSearchBar(),
              SizedBox(height: 18.h),
              _buildSegmentToggle(),
              SizedBox(height: 20.h),
              Expanded(
                child: displayItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayItems.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return _buildInventoryCard(displayItems[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: const Color(0xFFADB5BD),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 10.w),
            child: Icon(
              Icons.search_rounded,
              color: Colors.black45,
              size: 22.sp,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 44.w),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSegmentToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showActive = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48.h,
              decoration: BoxDecoration(
                color: _showActive ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: _showActive ? _primaryBlue : const Color(0xFFCED4DA),
                  width: 1,
                ),
                boxShadow: _showActive
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _showActive ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showActive = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48.h,
              decoration: BoxDecoration(
                color: !_showActive ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: !_showActive ? _primaryBlue : const Color(0xFFCED4DA),
                  width: 1,
                ),
                boxShadow: !_showActive
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  'Completed',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: !_showActive ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final double progressRatio = item.totalCount > 0
        ? (item.takenCount / item.totalCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.iconData, color: item.iconColor, size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.dosageInfo,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                if (item.isLowStock) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'Low Stock',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFB800),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 44.w,
            height: 44.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 42.w,
                  height: 42.w,
                  child: CircularProgressIndicator(
                    value: progressRatio,
                    strokeWidth: 3.5.w,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _primaryBlue,
                    ),
                  ),
                ),
                Text(
                  '${item.takenCount}/${item.totalCount}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.black45,
              size: 20.sp,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56.sp,
            color: const Color(0xFFB0DCF0),
          ),
          SizedBox(height: 12.h),
          Text(
            _showActive ? 'No active medications' : 'No completed medications',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: const Color(0xFF6C757D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
