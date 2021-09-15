/// リストに対する拡張
/// (不変操作を提供する。)
extension CollectionEx<T> on List<T> {
  /// リスト末尾に要素を追加する。
  /// (元のリストには手を加えない。)
  List<T> append(T element) {
    final updatedSize = length + 1;
    final lastIndex = updatedSize - 1;

    return List.generate(
      updatedSize,
      (i) => i != lastIndex ? this[i] : element,
    );
  }

  /// 指定インデックスの要素を置換する。
  /// (元のリストには手を加えない。)
  List<T> replace(int index, T element) {
    return List.generate(length, (i) => i == index ? element : this[i]);
  }

  /// 指定要素を末尾に並び替え、他の要素を1つ前に詰めて配置する。
  /// (元のリストには手を加えない。)
  List<T> toTail(int targetIndex) {
    final lastIndex = length - 1;

    return List.generate(length, (i) {
      //  対象よりも前に並んでいるものはそのままの配置にする。
      if (i < targetIndex) return this[i];

      //  更新後の末尾要素を対象の要素とする。
      if (i == lastIndex) return this[targetIndex];

      //  対象要素よりも後ろに並んでいた要素は、
      //  対象要素が抜けて末尾に移動したため、
      //  1つ前に詰めて配置する。
      return this[i + 1];
    });
  }
}
