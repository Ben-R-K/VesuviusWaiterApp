import 'package:flutter_test/flutter_test.dart';
import 'package:waiter_app/models/dto.dart';

void main() {
  test('TableDto fromJson/toJson', () {
    final json = {'id': 1, 'name': 'Table 1', 'occupied': true};
    final t = TableDto.fromJson(json);
    expect(t.id, 1);
    expect(t.name, 'Table 1');
    expect(t.occupied, true);
    expect(t.toJson()['name'], 'Table 1');
  });
}
