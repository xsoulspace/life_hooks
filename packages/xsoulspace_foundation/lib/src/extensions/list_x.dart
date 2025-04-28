/// Extension methods for [List] to provide additional functionality.
///
/// This extension adds useful methods for manipulating lists, enhancing their
/// capabilities for various use cases.
///
/// @ai Use this extension to simplify operations on lists in your code.
extension XSListX<E> on List<E> {
  /// Reorders the list by moving an item from one index to another.
  ///
  /// [oldIndex] The current index of the item to move.
  /// [newIndex] The new index to move the item to.
  ///
  /// @ai Use this method to rearrange items in a list without creating a new
  /// list.
  void reorder(final int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      // removing the item at oldIndex will shorten the list by 1.
      // ignore: parameter_assignments
      newIndex -= 1;
    }
    final element = removeAt(oldIndex);
    insert(newIndex, element);
  }

  /// Returns an unmodifiable view of the list.
  ///
  /// @ai Use this method to create a list that cannot be modified.
  List<E> get unmodifiable => List.unmodifiable(this);
}
