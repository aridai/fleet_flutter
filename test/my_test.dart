import 'package:test/test.dart';

void main() {
  group('テスト', () {
    test('テスト', () {
      const actual = 1 + 2;
      const expected = 3;

      expect(actual, equals(expected));
    });
  });
}
