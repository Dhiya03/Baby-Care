import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final List<DateTime>? availableDates;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.availableDates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing,
            vertical: AppConstants.spacing / 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous date button
              IconButton(
                onPressed: () => _changeDate(-1),
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous day',
              ),

              // Current date display (tappable)
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDatePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacing / 2,
                      horizontal: AppConstants.spacing,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateHelper.getRelativeDateString(selectedDate),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          DateFormat('EEEE, MMM d, y').format(selectedDate),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Next date button
              IconButton(
                onPressed: DateHelper.isToday(selectedDate)
                    ? null
                    : () => _changeDate(1),
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next day',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeDate(int days) {
    final newDate = selectedDate.add(Duration(days: days));

    // Don't allow future dates
    if (newDate.isAfter(DateTime.now())) return;

    onDateChanged(newDate);
  }

  void _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select date to view history',
      selectableDayPredicate: (DateTime date) {
        // If available dates are provided, only allow those dates
        if (availableDates != null) {
          return availableDates!.any(
            (availableDate) =>
                DateHelper.getDateOnly(availableDate) ==
                DateHelper.getDateOnly(date),
          );
        }
        return true;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}

// Alternative compact date selector for smaller spaces
class CompactDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final bool showWeekSelector;

  const CompactDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.showWeekSelector = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: showWeekSelector
          ? _buildWeekSelector(context)
          : _buildDaySelector(context),
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    final dates = _getWeekDates();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isSelected =
            DateHelper.getDateOnly(date) ==
            DateHelper.getDateOnly(selectedDate);
        final isToday = DateHelper.isToday(date);

        return GestureDetector(
          onTap: () => onDateChanged(date),
          child: Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isToday
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: Theme.of(context).primaryColor, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekSelector(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _changeWeek(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            _getWeekString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: () => _changeWeek(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  List<DateTime> _getWeekDates() {
    final startOfWeek = DateHelper.getStartOfWeek(selectedDate);
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getWeekString() {
    final startOfWeek = DateHelper.getStartOfWeek(selectedDate);
    final endOfWeek = DateHelper.getEndOfWeek(selectedDate);

    if (startOfWeek.month == endOfWeek.month) {
      return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('d, y').format(endOfWeek)}';
    } else {
      return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, y').format(endOfWeek)}';
    }
  }

  void _changeWeek(int weeks) {
    final newDate = selectedDate.add(Duration(days: weeks * 7));

    // Don't allow future dates
    if (newDate.isAfter(DateTime.now())) return;

    onDateChanged(newDate);
  }
}
