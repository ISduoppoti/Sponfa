import 'package:flutter/material.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/features/auth/cart/view/cart_view.dart';

class CartProvider with ChangeNotifier {
  final List<CartGroup> _groups = [];

  List<CartGroup> get groups => _groups;

  void showCartPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: 1200,
          height: 800,
          child: CartPage(), // reuse
        ),
      ),
    );
  }

  void addItem(CartItem item) {
    if (_groups.isEmpty) {
      _groups.add(CartGroup(id: UniqueKey().toString(), items: [item]));
    } else {
      _groups.first.items.add(item); // Add to first group by default
    }
    notifyListeners();
  }

  void splitGroup(String groupId, int splitIndex) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    
    // Don't split if there aren't enough items
    if (splitIndex >= group.items.length || splitIndex <= 0) return;

    final newGroupItems = group.items.sublist(splitIndex);
    group.items = group.items.sublist(0, splitIndex);

    _groups.insert(
      groupIndex + 1,
      CartGroup(id: UniqueKey().toString(), items: newGroupItems),
    );

    notifyListeners();
  }

  void removeItem(String groupId, String itemId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    group.items.removeWhere((i) => i.id == itemId);

    if (group.items.isEmpty) {
      _groups.remove(group);
    }

    notifyListeners();
  }

  void reorderGroups(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final group = _groups.removeAt(oldIndex);
    _groups.insert(newIndex, group);
    
    notifyListeners();
  }

  void reorderItemsInGroup(String groupId, int oldIndex, int newIndex) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = group.items.removeAt(oldIndex);
    group.items.insert(newIndex, item);
    
    notifyListeners();
  }

  void moveItemToGroup(String fromGroupId, String toGroupId, String itemId) {
    // Don't move to the same group
    if (fromGroupId == toGroupId) return;
    
    final fromGroup = _groups.firstWhere((g) => g.id == fromGroupId);
    final toGroup = _groups.firstWhere((g) => g.id == toGroupId);
    
    final item = fromGroup.items.firstWhere((i) => i.id == itemId);
    fromGroup.items.removeWhere((i) => i.id == itemId);
    toGroup.items.add(item);
    
    // Remove empty groups
    if (fromGroup.items.isEmpty) {
      _groups.remove(fromGroup);
    }
    
    notifyListeners();
  }

  void moveItemToNewGroup(String fromGroupId, String itemId, int insertIndex) {
    final fromGroup = _groups.firstWhere((g) => g.id == fromGroupId);
    final item = fromGroup.items.firstWhere((i) => i.id == itemId);
    
    fromGroup.items.removeWhere((i) => i.id == itemId);
    
    // Create new group with the item
    final newGroup = CartGroup(
      id: UniqueKey().toString(),
      items: [item],
    );
    
    _groups.insert(insertIndex, newGroup);
    
    // Remove empty groups
    if (fromGroup.items.isEmpty) {
      _groups.remove(fromGroup);
    }
    
    notifyListeners();
  }

  void moveGroupToIndex(String groupId, int newIndex) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;
    
    final group = _groups.removeAt(groupIndex);
    
    // Adjust index if we removed an item before the target position
    if (groupIndex < newIndex) {
      newIndex -= 1;
    }
    
    _groups.insert(newIndex, group);
    notifyListeners();
  }

  void mergeGroups(String firstGroupId, String secondGroupId) {
    final firstGroup = _groups.firstWhere((g) => g.id == firstGroupId);
    final secondGroup = _groups.firstWhere((g) => g.id == secondGroupId);
    
    firstGroup.items.addAll(secondGroup.items);
    _groups.remove(secondGroup);
    
    notifyListeners();
  }

  double getTotalPrice() {
    double total = 0.0;
    for (final group in _groups) {
      for (final item in group.items) {
        if (item.price != null) {
          total += item.price! / 100;
        }
      }
    }
    return total;
  }

  int getTotalItems() {
    return _groups.fold(0, (sum, group) => sum + group.items.length);
  }
}