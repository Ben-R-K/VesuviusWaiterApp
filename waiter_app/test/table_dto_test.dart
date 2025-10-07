import 'package:flutter_test/flutter_test.dart';
import 'package:waiter_app/models/dto.dart';

void main() {
  test('TableDto parses JSON correctly', () {
    final json = {
      'id': '1',
      'name': 'Table 1',
      'occupied': true,
      'customerName': 'Jens',
      'reservationTime': '18:00'
    };
    final table = TableDto.fromJson(json);
    expect(table.id, '1');
    expect(table.name, 'Table 1');
    expect(table.occupied, true);
    expect(table.customerName, 'Jens');
    expect(table.reservationTime, '18:00');
  });
}
