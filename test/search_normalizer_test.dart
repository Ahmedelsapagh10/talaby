import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/utils/search_normalizer.dart';

void main() {
  group('SearchNormalizer', () {
    test('normalizes whitespace, case and Arabic diacritics', () {
      expect(SearchNormalizer.normalize('  RED   Shirt '), 'red shirt');
      expect(SearchNormalizer.normalize('قَمِيص'), 'قميص');
      expect(SearchNormalizer.normalize('إلى الآن'), 'الي الان');
    });

    test('creates prefixes for the full phrase and each word', () {
      final prefixes = SearchNormalizer.prefixes('Red Shirt');

      expect(prefixes, containsAll(['re', 'red', 'red sh', 'sh', 'shirt']));
      expect(prefixes, isNot(contains('r')));
    });

    test('does not index one-character values', () {
      expect(SearchNormalizer.prefixes('a'), isEmpty);
    });

    test('matches prefixes from any product name word', () {
      expect(SearchNormalizer.matchesPrefix('Fresh Cola', 'cola'), isTrue);
      expect(SearchNormalizer.matchesPrefix('Fresh Cola', 'col'), isTrue);
      expect(SearchNormalizer.matchesPrefix('Fresh Cola', 'ola'), isFalse);
    });

    test('normalizes phone formatting without losing country prefix', () {
      expect(SearchNormalizer.normalizePhone('010 123-4567'), '0101234567');
      expect(SearchNormalizer.normalizePhone('+20 (10) 123'), '+2010123');
    });
  });
}
