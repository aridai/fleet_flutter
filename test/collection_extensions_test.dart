import 'package:fleet_flutter/collection_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('コレクション操作のテスト', () {
    group('末尾追加のテスト', () {
      test('末尾に要素が追加された新しいリストが生成されるはず', () {
        //  元のリスト
        const sourceList = ['要素0', '要素1', '要素2'];

        //  末尾追加を行う。
        const newElement = '追加された要素';
        final resultList = sourceList.append(newElement);

        //  要素数が増えているはず。
        expect(resultList.length, equals(4));

        //  末尾要素が追加された要素であるはず。
        expect(resultList[resultList.length - 1], newElement);

        //  末尾以外の要素は引き継がれているはず。
        expect(resultList[0], equals('要素0'));
        expect(resultList[1], equals('要素1'));
        expect(resultList[2], equals('要素2'));

        //  元のリストは変わらないはず。
        expect(sourceList.length, equals(3));
        expect(sourceList[0], equals('要素0'));
        expect(sourceList[1], equals('要素1'));
        expect(sourceList[2], equals('要素2'));
      });
    });

    group('要素置換のテスト', () {
      test('指定要素のみが更新された新しいリストが生成されるはず', () {
        //  元のリスト
        const sourceList = ['要素A', '要素B', '要素C'];

        //  要素を更新する。
        final resultList = sourceList.replace(1, '更新要素B');

        //  要素数は変わらないはず。
        expect(resultList.length, equals(3));

        //  対象のインデックスの要素が更新されているはず。
        expect(resultList[1], equals('更新要素B'));

        //  その他の要素は変わらないはず。
        expect(resultList[0], equals('要素A'));
        expect(resultList[2], equals('要素C'));

        //  元のリストは変わらないはず。
        expect(sourceList.length, equals(3));
        expect(sourceList[0], equals('要素A'));
        expect(sourceList[1], equals('要素B'));
        expect(sourceList[2], equals('要素C'));
      });
    });

    group('末尾移動のテスト', () {
      test('先頭要素を末尾に移動するケース', () {
        //  元のリスト
        const sourceList = ['要素A', '要素B', '要素C', '要素D'];

        //  先頭要素を末尾に移動する。
        final resultList = sourceList.toTail(0);

        //  要素数は変わらないはず。
        expect(resultList.length, equals(4));

        //  末尾に先頭要素が移動しているはず。
        expect(resultList[3], equals('要素A'));

        //  その他の要素が1つ前に詰めて配置されているはず。
        expect(resultList[0], equals('要素B'));
        expect(resultList[1], equals('要素C'));
        expect(resultList[2], equals('要素D'));
      });

      test('元から末尾にあった要素を末尾に移動するケース', () {
        //  元のリスト
        const sourceList = ['要素A', '要素B', '要素C', '要素D'];

        //  末尾要素を末尾に移動する。
        final resultList = sourceList.toTail(3);

        //  要素数は変わらないはず。
        expect(resultList.length, equals(4));

        //  末尾に末尾要素があるはず。
        expect(resultList[3], equals('要素D'));

        //  その他の要素は元の位置に配置されているはず。
        expect(resultList[0], equals('要素A'));
        expect(resultList[1], equals('要素B'));
        expect(resultList[2], equals('要素C'));
      });

      test('真ん中にある要素を末尾に移動するケース', () {
        //  元のリスト
        const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

        //  真ん中 (index = 2) の要素を末尾に移動する。
        final resultList = sourceList.toTail(2);

        //  要素数は変わらないはず。
        expect(resultList.length, equals(5));

        //  末尾に対象要素があるはず。
        expect(resultList[4], equals('要素C'));

        //  対象要素よりも前にあった要素は並びが変わらないはず。
        expect(resultList[0], equals('要素A'));
        expect(resultList[1], equals('要素B'));

        //  対象要素よりも後ろにあった要素は1つ前に詰めて配置されているはず。
        expect(resultList[2], equals('要素D'));
        expect(resultList[3], equals('要素E'));
      });
    });

    group('並び替えのテスト', () {
      group('上から下に移動するケース', () {
        test('先頭から真ん中に移動するケース', () {
          //  元のリスト
          const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

          //  先頭から真ん中に移動させる。
          final resultList = sourceList.reorder(0, 2);

          //  要素数は変わらないはず。
          expect(resultList.length, equals(5));

          //  対象が正しく移動しているはず。
          expect(resultList[2], equals('要素A'));

          //  他の要素も正しく更新されているはず。
          expect(resultList[0], equals('要素B'));
          expect(resultList[1], equals('要素C'));
          expect(resultList[3], equals('要素D'));
          expect(resultList[4], equals('要素E'));
        });

        test('先頭から末尾に移動するケース', () {
          //  元のリスト
          const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

          //  先頭から末尾に移動させる。
          final resultList = sourceList.reorder(0, 4);

          //  要素数は変わらないはず。
          expect(resultList.length, equals(5));

          //  対象が正しく移動しているはず。
          expect(resultList[4], equals('要素A'));

          //  他の要素も正しく更新されているはず。
          expect(resultList[0], equals('要素B'));
          expect(resultList[1], equals('要素C'));
          expect(resultList[2], equals('要素D'));
          expect(resultList[3], equals('要素E'));
        });

        test('真ん中から末尾に移動するケース', () {
          //  元のリスト
          const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

          //  真ん中から末尾に移動させる。
          final resultList = sourceList.reorder(2, 4);

          //  要素数は変わらないはず。
          expect(resultList.length, equals(5));

          //  対象が正しく移動しているはず。
          expect(resultList[4], equals('要素C'));

          //  他の要素も正しく更新されているはず。
          expect(resultList[0], equals('要素A'));
          expect(resultList[1], equals('要素B'));
          expect(resultList[2], equals('要素D'));
          expect(resultList[3], equals('要素E'));
        });
      });

      group('下からに移動するケース', () {
        test('末尾から真ん中に移動するケース', () {
          //  元のリスト
          const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

          //  末尾から真ん中に移動させる。
          final resultList = sourceList.reorder(4, 2);

          //  要素数は変わらないはず。
          expect(resultList.length, equals(5));

          //  対象が正しく移動しているはず。
          expect(resultList[2], equals('要素E'));

          //  他の要素も正しく更新されているはず。
          expect(resultList[0], equals('要素A'));
          expect(resultList[1], equals('要素B'));
          expect(resultList[3], equals('要素C'));
          expect(resultList[4], equals('要素D'));
        });

        test('末尾から先頭に移動するケース', () {
          //  元のリスト
          const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

          //  末尾から先頭に移動させる。
          final resultList = sourceList.reorder(4, 0);

          //  要素数は変わらないはず。
          expect(resultList.length, equals(5));

          //  対象が正しく移動しているはず。
          expect(resultList[0], equals('要素E'));

          //  他の要素も正しく更新されているはず。
          expect(resultList[1], equals('要素A'));
          expect(resultList[2], equals('要素B'));
          expect(resultList[3], equals('要素C'));
          expect(resultList[4], equals('要素D'));
        });

        test('真ん中から先頭に移動するケース', () {
          //  元のリスト
          const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

          //  真ん中から先頭に移動させる。
          final resultList = sourceList.reorder(2, 0);

          //  要素数は変わらないはず。
          expect(resultList.length, equals(5));

          //  対象が正しく移動しているはず。
          expect(resultList[0], equals('要素C'));

          //  他の要素も正しく更新されているはず。
          expect(resultList[1], equals('要素A'));
          expect(resultList[2], equals('要素B'));
          expect(resultList[3], equals('要素D'));
          expect(resultList[4], equals('要素E'));
        });
      });
    });

    group('移動先が同じケース', () {
      test('先頭から先頭に移動するケース', () {
        //  元のリスト
        const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

        //  先頭から先頭に移動させる。
        final resultList = sourceList.reorder(0, 0);

        //  要素数は変わらないはず。
        expect(resultList.length, equals(5));

        //  何も起こらないはず。
        expect(resultList[0], equals('要素A'));
        expect(resultList[1], equals('要素B'));
        expect(resultList[2], equals('要素C'));
        expect(resultList[3], equals('要素D'));
        expect(resultList[4], equals('要素E'));
      });

      test('真ん中から真ん中に移動するケース', () {
        //  元のリスト
        const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

        //  真ん中から真ん中に移動させる。
        final resultList = sourceList.reorder(2, 2);

        //  要素数は変わらないはず。
        expect(resultList.length, equals(5));

        //  何も起こらないはず。
        expect(resultList[0], equals('要素A'));
        expect(resultList[1], equals('要素B'));
        expect(resultList[2], equals('要素C'));
        expect(resultList[3], equals('要素D'));
        expect(resultList[4], equals('要素E'));
      });

      test('末尾から末尾に移動するケース', () {
        //  元のリスト
        const sourceList = ['要素A', '要素B', '要素C', '要素D', '要素E'];

        //  末尾から末尾に移動させる。
        final resultList = sourceList.reorder(4, 4);

        //  要素数は変わらないはず。
        expect(resultList.length, equals(5));

        //  何も起こらないはず。
        expect(resultList[0], equals('要素A'));
        expect(resultList[1], equals('要素B'));
        expect(resultList[2], equals('要素C'));
        expect(resultList[3], equals('要素D'));
        expect(resultList[4], equals('要素E'));
      });
    });
  });
}
