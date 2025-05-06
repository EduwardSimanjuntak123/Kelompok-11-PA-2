import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarExtension extends StatelessWidget {
  final List<DateTime> unavailableDates;
  final Map<String, dynamic> booking;

  const CalendarExtension({
    Key? key,
    required this.unavailableDates,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        availableGestures: AvailableGestures.none,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, _) {
            final dayPure = DateTime(day.year, day.month, day.day);

            // Cek apakah tanggal berada dalam rentang booking
            final startDate = DateTime.parse(booking['start_date']);
            final endDate = DateTime.parse(booking['end_date']);

            // Normalisasi untuk membandingkan tanggal tanpa waktu
            final normalizedStartDate =
                DateTime(startDate.year, startDate.month, startDate.day);
            final normalizedEndDate =
                DateTime(endDate.year, endDate.month, endDate.day);

            // Menandai tanggal yang dibooking dengan warna oranye
            if (!dayPure.isBefore(normalizedStartDate) &&
                !dayPure.isAfter(normalizedEndDate)) {
              return _buildCalendarCircle(day.day,
                  Colors.orange[200]!); // Tanggal yang dipesan oleh pengguna
            }

            // Cek apakah tanggal tersebut sudah dipesan orang lain
            if (unavailableDates.contains(dayPure)) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return null; // Jika tidak ada penandaan
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCircle(int day, Color color) {
    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
