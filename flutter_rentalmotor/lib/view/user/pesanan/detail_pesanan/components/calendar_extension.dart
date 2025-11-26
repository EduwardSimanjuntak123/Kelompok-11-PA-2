import 'package:flutter/material.dart';

class CalendarExtension extends StatelessWidget {
  final List<DateTime> unavailableDates;
  final Map<String, dynamic> booking;

  const CalendarExtension({
    super.key,
    required this.unavailableDates,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    int totalDays = lastDayOfMonth.day;
    int startWeekday = firstDayOfMonth.weekday % 7; // Minggu = 0, Senin = 1 ...
    int totalItems = totalDays + startWeekday;

    // Tambahkan baris ekstra agar grid rapi (42 sel = 6 minggu)
    int remaining = totalItems % 7 == 0 ? 0 : (7 - (totalItems % 7));
    totalItems += remaining;

    List<Widget> dayWidgets = [];

    for (int i = 0; i < totalItems; i++) {
      if (i < startWeekday || i >= startWeekday + totalDays) {
        // Slot kosong di awal/akhir grid
        dayWidgets.add(Container());
      } else {
        int day = i - startWeekday + 1;
        DateTime currentDate = DateTime(now.year, now.month, day);

        bool isUnavailable = unavailableDates.any((date) =>
            date.year == currentDate.year &&
            date.month == currentDate.month &&
            date.day == currentDate.day);

        dayWidgets.add(
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isUnavailable ? Colors.red[100] : Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: isUnavailable ? Colors.red : Colors.black,
                fontWeight: isUnavailable ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: dayWidgets,
        ),
      ],
    );
  }
}
