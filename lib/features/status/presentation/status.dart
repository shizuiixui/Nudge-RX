import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../inventory/models/medication_model.dart';
import '../../inventory/providers/medication_provider.dart';

class StatusPage extends ConsumerStatefulWidget {
  const StatusPage({super.key});

  @override
  ConsumerState<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends ConsumerState<StatusPage>
    with SingleTickerProviderStateMixin {
  static const _bgColor = Color(0xFFEAF6FB);
  static const _primaryBlue = Color(0xFF38C2EE);
  static const _cardColor = Colors.white;

  // Status colours
  static const _takenColor = Color(0xFF4CAF50);
  static const _skippedColor = Color(0xFFEF5350);
  static const _pendingColor = Color(0xFFFFA726);

  int _selectedPeriod = 0; // 0=Daily, 1=Weekly, 2=Monthly
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final medsAsync = ref.watch(medicationsProvider);
    final statusMap = ref.watch(medicationStatusProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: medsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Failed to load medications.\n$e',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
            ),
          ),
          data: (meds) => _buildBody(meds, statusMap),
        ),
      ),
    );
  }

  Widget _buildBody(
    List<MedicationModel> meds,
    Map<String, MedicationStatus> statusMap,
  ) {
    // Categorise
    final taken = meds
        .where((m) => statusMap[m.id ?? m.name] == MedicationStatus.taken)
        .toList();
    final skipped = meds
        .where((m) => statusMap[m.id ?? m.name] == MedicationStatus.skipped)
        .toList();
    final pending = meds
        .where(
          (m) =>
              statusMap[m.id ?? m.name] == null ||
              statusMap[m.id ?? m.name] == MedicationStatus.pending,
        )
        .toList();

    final total = meds.length;
    final gaugePercent = total == 0 ? 0.0 : taken.length / total;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // -- Title
          Text(
            'Status',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 16.h),

          // -- Gauge Card
          _buildGaugeCard(gaugePercent, taken.length, total),

          SizedBox(height: 24.h),

          // -- Summary chips
          _buildSummaryRow(taken.length, skipped.length, pending.length),

          SizedBox(height: 24.h),

          // -- Activity list
          _buildActivitiesContainer(taken, skipped, pending),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildGaugeCard(double percent, int takenCount, int total) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPeriodSelector(),
          SizedBox(height: 24.h),
          _buildGaugeArc(percent: percent),
          SizedBox(height: 8.h),
          Text(
            total == 0
                ? 'No medications today'
                : '$takenCount of $total meds taken',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: List.generate(_periods.length, (i) {
          final selected = i == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _periods[i],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.black87 : Colors.black45,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGaugeArc({required double percent}) {
    return SizedBox(
      width: 160.w,
      height: 90.h,
      child: CustomPaint(
        painter: _GaugePainter(
          percent: percent,
          trackColor: const Color(0xFFE0E0E0),
          fillColor: _primaryBlue,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              '${(percent * 100).round()}%',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(int takenCount, int skippedCount, int pendingCount) {
    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: 'Taken',
            count: takenCount,
            color: _takenColor,
            icon: Icons.check_circle_outline,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _SummaryChip(
            label: 'Skipped',
            count: skippedCount,
            color: _skippedColor,
            icon: Icons.cancel_outlined,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _SummaryChip(
            label: 'Pending',
            count: pendingCount,
            color: _pendingColor,
            icon: Icons.access_time,
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesContainer(
    List<MedicationModel> taken,
    List<MedicationModel> skipped,
    List<MedicationModel> pending,
  ) {
    final allEmpty = taken.isEmpty && skipped.isEmpty && pending.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Activities',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: allEmpty
              ? Center(
                  child: Text(
                    'No activities yet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: Colors.black38,
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (taken.isNotEmpty) ...[
                      _buildSectionLabel('Taken', _takenColor),
                      SizedBox(height: 8.h),
                      ...taken.map(
                        (m) => _MedActivityRow(
                          med: m,
                          status: MedicationStatus.taken,
                          statusColor: _takenColor,
                          statusIcon: Icons.check_circle_outline,
                          statusLabel: 'Taken',
                        ),
                      ),
                    ],
                    if (skipped.isNotEmpty) ...[
                      if (taken.isNotEmpty) SizedBox(height: 16.h),
                      _buildSectionLabel('Skipped', _skippedColor),
                      SizedBox(height: 8.h),
                      ...skipped.map(
                        (m) => _MedActivityRow(
                          med: m,
                          status: MedicationStatus.skipped,
                          statusColor: _skippedColor,
                          statusIcon: Icons.cancel_outlined,
                          statusLabel: 'Skipped',
                        ),
                      ),
                    ],
                    if (pending.isNotEmpty) ...[
                      if (taken.isNotEmpty || skipped.isNotEmpty)
                        SizedBox(height: 16.h),
                      _buildSectionLabel('Pending', _pendingColor),
                      SizedBox(height: 8.h),
                      ...pending.map(
                        (m) => _MedActivityRow(
                          med: m,
                          status: MedicationStatus.pending,
                          statusColor: _pendingColor,
                          statusIcon: Icons.access_time,
                          statusLabel: 'Pending',
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(height: 4.h),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedActivityRow extends StatelessWidget {
  final MedicationModel med;
  final MedicationStatus status;
  final Color statusColor;
  final IconData statusIcon;
  final String statusLabel;

  const _MedActivityRow({
    required this.med,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          // Left icon bubble
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medication, color: statusColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),

          // Name + details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  [
                    if (med.dosage != null && med.dosage!.isNotEmpty)
                      med.dosage!,
                    med.formattedTime,
                  ].join(' · '),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 12.sp, color: statusColor),
                SizedBox(width: 4.w),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final Color fillColor;

  const _GaugePainter({
    required this.percent,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final radius = size.width / 2;
    const strokeWidth = 14.0;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 3.14159, 3.14159, false, trackPaint);
    canvas.drawArc(rect, 3.14159, 3.14159 * percent, false, fillPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.percent != percent ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor;
}
