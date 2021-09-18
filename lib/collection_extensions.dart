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

  /// 指定要素を指定位置に並び替える。
  /// (元のリストには手を加えない。)
  List<T> reorder(int fromIndex, int toIndex) {
    //  下に移動する場合
    if (fromIndex < toIndex) {
      return List.generate(length, (i) {
        //  対象の移動前よりも前に並んでいるものはそのままの配置にする。
        if (i < fromIndex) return this[i];

        //  対象の移動前後に挟まれるものは1つ前に詰めて配置する。
        if (fromIndex <= i && i < toIndex) return this[i + 1];

        //  対象の移動後よりも後に並んでいるものはそのままの配置にする。
        if (toIndex < i) return this[i];

        return this[fromIndex];
      });
    }

    //  上に移動する場合
    if (fromIndex > toIndex) {
      return List.generate(length, (i) {
        //  対象の移動後よりも前に並んでいるものはそのままの配置にする。
        if (i < toIndex) return this[i];

        //  対象の移動前後に挟まれるものは1つ後ろにずらして配置する。
        if (toIndex < i && i <= fromIndex) return this[i - 1];

        //  対象の移動前よりも後ろに並んでいるものはそのままの配置にする。
        if (fromIndex < i) return this[i];

        return this[fromIndex];
      });
    }

    //  並び替えを行わない場合
    return List.of(this);
  }
}
