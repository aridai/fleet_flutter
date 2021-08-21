import 'package:test/test.dart';

void main() {
  group('テスト', () {
    test('テスト', () {
      const actual = 1 + 2;
      const expected = 3;

      expect(actual, equals(expected));
    });

    test('失敗するテスト', () {
      const actual = 1 + 2;
      const expected = 4;

      expect(actual, equals(expected));
    });
  });
}
