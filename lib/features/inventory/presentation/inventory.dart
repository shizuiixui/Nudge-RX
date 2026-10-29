import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/medication_model.dart';
import '../providers/medication_provider.dart';
import 'widgets/inventory_widget_helpers.dart';

class InventoryItem {
  final String id;
  final String name;
  final String dosageInfo;
  final bool isLowStock;
  final bool isCompleted;
  final IconData iconData;
  final Color iconColor;
  final String? imagePath;
  final MedicationModel? medication;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.dosageInfo,
    this.isLowStock = false,
    this.isCompleted = false,
    this.iconData = Icons.medication_rounded,
    this.iconColor = const Color(0xFF38C2EE),
    this.imagePath,
    this.medication,
  });
}

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  static const _bgColor = Color(0xFFEAF6FB);

  bool _showActive = true; // true = Active tab, false = Completed tab
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

    for (int i = 0; i < userMeds.length; i++) {
      final med = userMeds[i];
      final medId = med.id ?? med.name;
      final isTaken = statusMap[medId] == MedicationStatus.taken;
      items.add(
        InventoryItem(
          id: medId,
          name: med.name,
          dosageInfo: med.dosage ?? '',
          isCompleted: isTaken,
          isLowStock: false,
          iconData: i % 2 == 0
              ? Icons.medication_rounded
              : Icons.vaccines_rounded,
          iconColor: i % 2 == 0
              ? const Color(0xFF38C2EE)
              : const Color(0xFF8E44AD),
          imagePath: med.categoryAssetPath,
          medication: med,
        ),
      );
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
              InventorySearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              SizedBox(height: 18.h),
              InventorySegmentToggle(
                showActive: _showActive,
                onToggle: (val) {
                  setState(() {
                    _showActive = val;
                  });
                },
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: displayItems.isEmpty
                    ? InventoryEmptyState(showActive: _showActive)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayItems.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return InventoryCard(item: displayItems[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
