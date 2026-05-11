import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';

// ─── Daily Journal Screen ──────────────────────────────────────────────────────
//
// Shows a calendar where each day that has data is highlighted.
// Tapping a day opens a detail panel showing logged calories and weight.
// Data is read from the 'daily_logs' sub-collection in Firestore.

class DailyJournalScreen extends StatefulWidget {
  const DailyJournalScreen({super.key});

  @override
  State<DailyJournalScreen> createState() => _DailyJournalScreenState();
}

class _DailyJournalScreenState extends State<DailyJournalScreen> {
  // currently displayed month (year + month only — day is always 1)
  late DateTime _displayedMonth;

  // selected day; null = nothing selected
  DateTime? _selectedDay;

  // all log entries keyed by 'YYYY-MM-DD'
  Map<String, Map<String, dynamic>> _logs = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _loadLogs();
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  Future<void> _loadLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final raw = await DatabaseService().getDailyLogs(user.uid);
    final map = <String, Map<String, dynamic>>{};
    for (final entry in raw) {
      final key = entry['date'] as String?;
      if (key != null) map[key] = entry;
    }

    setState(() {
      _logs = map;
      _loading = false;
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic>? _logFor(DateTime day) => _logs[_dateKey(day)];

  // number of days in the displayed month
  int get _daysInMonth =>
      DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

  // weekday index (0=Mon) of the first day of the displayed month
  int get _firstWeekday =>
      DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday - 1;

  // month navigation
  void _prevMonth() => setState(() {
        _displayedMonth =
            DateTime(_displayedMonth.year, _displayedMonth.month - 1);
        _selectedDay = null;
      });

  void _nextMonth() => setState(() {
        _displayedMonth =
            DateTime(_displayedMonth.year, _displayedMonth.month + 1);
        _selectedDay = null;
      });

  bool _isFuture(DateTime day) => day.isAfter(DateTime.now());

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daily Journal',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLogs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── month navigator ───────────────────────────────────
                    _MonthNavigator(
                      month: _displayedMonth,
                      onPrev: _prevMonth,
                      onNext: _nextMonth,
                    ),

                    const SizedBox(height: 12),

                    // ── calendar grid ─────────────────────────────────────
                    _CalendarGrid(
                      displayedMonth: _displayedMonth,
                      daysInMonth: _daysInMonth,
                      firstWeekday: _firstWeekday,
                      selectedDay: _selectedDay,
                      logs: _logs,
                      isFuture: _isFuture,
                      onDayTap: (day) =>
                          setState(() => _selectedDay = day),
                    ),

                    const SizedBox(height: 24),

                    // ── detail panel for selected day ─────────────────────
                    if (_selectedDay != null)
                      _DayDetailPanel(
                        day: _selectedDay!,
                        log: _logFor(_selectedDay!),
                      ),

                    // ── month summary (if no day selected) ────────────────
                    if (_selectedDay == null) _MonthSummary(
                      displayedMonth: _displayedMonth,
                      daysInMonth: _daysInMonth,
                      logs: _logs,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Month Navigator ──────────────────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final isCurrentOrFuture =
        DateTime(month.year, month.month).isAfter(
          DateTime(DateTime.now().year, DateTime.now().month - 1),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          onPressed: onPrev,
          color: Colors.black87,
        ),
        Text(
          '${_months[month.month - 1]} ${month.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 30,
            // grey out the arrow if we're already at/past the current month
            color: isCurrentOrFuture ? Colors.grey.shade300 : Colors.black87,
          ),
          onPressed: isCurrentOrFuture ? null : onNext,
        ),
      ],
    );
  }
}

// ─── Calendar Grid ────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final int daysInMonth;
  final int firstWeekday;
  final DateTime? selectedDay;
  final Map<String, Map<String, dynamic>> logs;
  final bool Function(DateTime) isFuture;
  final void Function(DateTime) onDayTap;

  const _CalendarGrid({
    required this.displayedMonth,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.selectedDay,
    required this.logs,
    required this.isFuture,
    required this.onDayTap,
  });

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    const dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // day-of-week headers
          Row(
            children: dayHeaders.map((h) {
              return Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // day cells
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 0,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              // leading empty cells
              if (index < firstWeekday) return const SizedBox.shrink();

              final dayNum = index - firstWeekday + 1;
              final day = DateTime(
                  displayedMonth.year, displayedMonth.month, dayNum);
              final key = _dateKey(day);
              final log = logs[key];
              final hasData = log != null;
              final future = isFuture(day);

              final now = DateTime.now();
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;

              final isSelected = selectedDay != null &&
                  day.year == selectedDay!.year &&
                  day.month == selectedDay!.month &&
                  day.day == selectedDay!.day;

              // colour logic:
              // selected   → blue fill
              // today      → blue border only
              // has data   → indigo dot indicator below number
              // future     → greyed out
              Color bgColor = Colors.transparent;
              Color textColor = future ? Colors.grey.shade400 : Colors.black87;
              FontWeight fontWeight = FontWeight.normal;

              if (isSelected) {
                bgColor = const Color(0xFF378ADD);
                textColor = Colors.white;
                fontWeight = FontWeight.bold;
              } else if (isToday) {
                bgColor = const Color(0xFF378ADD).withValues(alpha: 0.1);
                textColor = const Color(0xFF378ADD);
                fontWeight = FontWeight.bold;
              }

              return GestureDetector(
                onTap: future ? null : () => onDayTap(day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(
                                color: const Color(0xFF378ADD), width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: fontWeight,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    // small dot if there's a log entry for this day
                    const SizedBox(height: 2),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: hasData && !future
                            ? const Color(0xFF5C6BC0)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Day Detail Panel ─────────────────────────────────────────────────────────

class _DayDetailPanel extends StatelessWidget {
  final DateTime day;
  final Map<String, dynamic>? log;

  const _DayDetailPanel({required this.day, this.log});

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = [
    '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
    'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_weekdays[day.weekday]}, ${_months[day.month - 1]} ${day.day}';
    final calories = (log?['calories'] as num?)?.toInt();
    final weight = (log?['weightLbs'] as num?)?.toDouble();
    final hasAny = calories != null || weight != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // section header
        Text(
          dateLabel,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (!hasAny)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No data logged for this day.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          // stat tiles
          Row(
            children: [
              // calories tile
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFD85A30),
                  label: 'Calories',
                  value: calories != null ? '$calories kcal' : '—',
                ),
              ),
              const SizedBox(width: 12),
              // weight tile
              Expanded(
                child: _StatTile(
                  icon: Icons.monitor_weight_rounded,
                  color: const Color(0xFF378ADD),
                  label: 'Weight',
                  value: weight != null
                      ? '${weight.toStringAsFixed(1)} lbs'
                      : '—',
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Month Summary ────────────────────────────────────────────────────────────
// Shown when no day is selected — avg calories + avg weight for the month.

class _MonthSummary extends StatelessWidget {
  final DateTime displayedMonth;
  final int daysInMonth;
  final Map<String, Map<String, dynamic>> logs;

  const _MonthSummary({
    required this.displayedMonth,
    required this.daysInMonth,
    required this.logs,
  });

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    int calTotal = 0, calCount = 0;
    double wtTotal = 0; int wtCount = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final key = _dateKey(
          DateTime(displayedMonth.year, displayedMonth.month, d));
      final log = logs[key];
      if (log == null) continue;
      final cal = (log['calories'] as num?)?.toInt();
      final wt = (log['weightLbs'] as num?)?.toDouble();
      if (cal != null) { calTotal += cal; calCount++; }
      if (wt != null) { wtTotal += wt; wtCount++; }
    }

    if (calCount == 0 && wtCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Month Average',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (calCount > 0)
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFD85A30),
                  label: 'Avg Calories',
                  value: '${(calTotal / calCount).round()} kcal',
                ),
              ),
            if (calCount > 0 && wtCount > 0) const SizedBox(width: 12),
            if (wtCount > 0)
              Expanded(
                child: _StatTile(
                  icon: Icons.monitor_weight_rounded,
                  color: const Color(0xFF378ADD),
                  label: 'Avg Weight',
                  value: '${(wtTotal / wtCount).toStringAsFixed(1)} lbs',
                ),
              ),
          ],
        ),
      ],
    );
  }
}
