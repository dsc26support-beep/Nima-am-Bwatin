import 'package:flutter_test/flutter_test.dart';
import 'package:nima_am_bwatin/services/scheduling_service.dart';

void main() {
  group('generateEvenlySpacedTimes', () {
    test('a single time defaults to 8am', () {
      final times = SchedulingService.generateEvenlySpacedTimes(1);
      expect(times, hasLength(1));
      expect(times.first.hour, 8);
    });

    test('two times span the 7am-9pm window', () {
      final times = SchedulingService.generateEvenlySpacedTimes(2);
      expect(times, hasLength(2));
      expect(times.first.hour, 7);
      expect(times.last.hour, 21);
    });

    test('three times are evenly spread and increasing', () {
      final times = SchedulingService.generateEvenlySpacedTimes(3);
      expect(times, hasLength(3));
      final minutes = times.map((t) => t.hour * 60 + t.minute).toList();
      expect(minutes[0] < minutes[1] && minutes[1] < minutes[2], isTrue);
    });
  });

  group('generateEveryXHoursTimes', () {
    test('every 8 hours from 6am produces 3 times', () {
      final times = SchedulingService.generateEveryXHoursTimes(8);
      expect(times, hasLength(3));
      expect(times.map((t) => t.hour).toList(), [6, 14, 22]);
    });

    test('every 12 hours produces 2 times', () {
      final times = SchedulingService.generateEveryXHoursTimes(12);
      expect(times, hasLength(2));
      expect(times.map((t) => t.hour).toList(), [6, 18]);
    });
  });
}
