import 'package:flutter/material.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text("Cart", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
      ),
      body: cart.groups.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, 
                       size: 80, color: Colors.orange.shade300),
                  SizedBox(height: 16),
                  Text("Your cart is empty", 
                       style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            )
          : DragTargetListView(
              padding: EdgeInsets.all(16),
              groups: cart.groups,
            ),
    );
  }
}

class DragTargetListView extends StatelessWidget {
  final EdgeInsets padding;
  final List<CartGroup> groups;

  const DragTargetListView({
    Key? key,
    required this.padding,
    required this.groups,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: groups.length * 2, // Groups + drop zones between them
      itemBuilder: (context, index) {
        if (index.isEven) {
          // Group widget
          final groupIndex = index ~/ 2;
          final group = groups[groupIndex];
          return DraggableGroupWidget(
            key: ValueKey(group.id),
            group: group,
            groupIndex: groupIndex,
            isLastGroup: groupIndex == groups.length - 1,
          );
        } else {
          // Drop zone between groups
          final groupIndex = index ~/ 2;
          return DropZoneBetweenGroups(insertIndex: groupIndex + 1);
        }
      },
    );
  }
}

class DropZoneBetweenGroups extends StatelessWidget {
  final int insertIndex;

  const DropZoneBetweenGroups({
    Key? key,
    required this.insertIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragData>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data.isGroup) {
          // Move entire group
          context.read<CartProvider>().moveGroupToIndex(data.groupId, insertIndex);
        } else if (data.itemId != null) {
          // Create new group with this item
          context.read<CartProvider>().moveItemToNewGroup(
            data.groupId,
            data.itemId!,
            insertIndex,
          );
        }
      },
      onWillAcceptWithDetails: (details) {
        // Accept both groups and items
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: isHovering ? 60 : 20,
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isHovering ? Colors.orange.shade100 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isHovering 
                ? Border.all(color: Colors.orange.shade400, width: 2)
                : null,
          ),
          child: isHovering
              ? Center(
                  child: Text(
                    "Drop here to create new group",
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : SizedBox.shrink(),
        );
      },
    );
  }
}

class DragData {
  final String groupId;
  final String? itemId;
  final bool isGroup;

  DragData({
    required this.groupId,
    this.itemId,
    this.isGroup = false,
  });
}

class DraggableGroupWidget extends StatelessWidget {
  final CartGroup group;
  final int groupIndex;
  final bool isLastGroup;

  const DraggableGroupWidget({
    Key? key,
    required this.group,
    required this.groupIndex,
    required this.isLastGroup,
  }) : super(key: key);

  double get totalPrice {
    return group.items
        .where((item) => item.price != null)
        .fold(0.0, (sum, item) => sum + (item.price! / 100));
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<DragData>(
      data: DragData(groupId: group.id, isGroup: true),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            "Group ${groupIndex + 1} (${group.items.length} items)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildGroupContent(context),
      ),
      child: DragTarget<DragData>(
        onAcceptWithDetails: (details) {
          final data = details.data;
          if (!data.isGroup && data.itemId != null) {
            // Item → Group merge
            context.read<CartProvider>().moveItemToGroup(
              data.groupId,
              group.id,
              data.itemId!,
            );
          } else if (data.isGroup && data.groupId != group.id) {
            // Group → Group merge
            context.read<CartProvider>().mergeGroups(data.groupId, group.id);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty &&
              // Highlight for items OR groups (but don’t highlight when dragging itself)
              (candidateData.first?.groupId != group.id);

          
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isHovering 
                  ? Border.all(color: Colors.orange.shade400, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isHovering 
                      ? Colors.orange.shade300
                      : Colors.orange.shade200,
                  blurRadius: isHovering ? 12 : 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _buildGroupContent(context),
          );
        },
      ),
    );
  }

  Widget _buildGroupContent(BuildContext context) {
    return Column(
      children: [
        // Group Header with Total Price
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Group ${groupIndex + 1}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              Text(
                "Total: \$${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ),
        // Items List
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: group.items.length,
          itemBuilder: (context, itemIndex) {
            final item = group.items[itemIndex];
            return DraggableCartItemWidget(
              key: ValueKey(item.id),
              item: item,
              groupId: group.id,
              itemIndex: itemIndex,
              showDivider: itemIndex < group.items.length - 1,
            );
          },
        ),
        // Show Pharmacies Button
        Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Show pharmacies for this group
              },
              icon: Icon(Icons.local_pharmacy),
              label: Text("Show Pharmacies"),
            ),
          ),
        ),
      ],
    );
  }
}

class DraggableCartItemWidget extends StatelessWidget {
  final CartItem item;
  final String groupId;
  final int itemIndex;
  final bool showDivider;

  const DraggableCartItemWidget({
    Key? key,
    required this.item,
    required this.groupId,
    required this.itemIndex,
    required this.showDivider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<DragData>(
      data: DragData(groupId: groupId, itemId: item.id),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.shade50,
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.medical_services,
                                color: Colors.orange.shade400);
                          },
                        ),
                      )
                    : Icon(Icons.medical_services,
                        color: Colors.orange.shade400),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildItemContent(context),
      ),
      child: _buildItemContent(context),
    );
  }

  Widget _buildItemContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.medical_services,
                                color: Colors.orange.shade400);
                          },
                        ),
                      )
                    : Icon(Icons.medical_services,
                        color: Colors.orange.shade400),
              ),
              SizedBox(width: 16),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.price != null 
                          ? "\$${(item.price! / 100).toStringAsFixed(2)}"
                          : "Price not available",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Remove Button
              IconButton(
                icon: Icon(Icons.close, color: Colors.red.shade400),
                onPressed: () => context
                    .read<CartProvider>()
                    .removeItem(groupId, item.id),
              ),
            ],
          ),
        ),
        // Divider with Split Button
        if (showDivider)
          DividerWithSplitButton(
            groupId: groupId,
            splitIndex: itemIndex + 1,
          ),
      ],
    );
  }
}

class DividerWithSplitButton extends StatelessWidget {
  final String groupId;
  final int splitIndex;

  const DividerWithSplitButton({
    Key? key,
    required this.groupId,
    required this.splitIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Divider Line
          Container(
            height: 1,
            color: Colors.orange.shade200,
          ),
          // Split Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.call_split,
                size: 16,
                color: Colors.orange.shade600,
              ),
              label: Text(
                "Split",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade600,
                ),
              ),
              onPressed: () {
                context.read<CartProvider>().splitGroup(groupId, splitIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}