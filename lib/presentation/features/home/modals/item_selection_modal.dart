import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';

/// Modal for selecting items from inventory to add to cart.
///
/// Features:
/// - Search bar at top
/// - Scrollable product list with:
///   - Product name
///   - Current stock
///   - Price
///   - "+" button to add to cart
/// - Cart summary at bottom (sticky)
/// - "Checkout" button
class ItemSelectionModal extends StatefulWidget {
  const ItemSelectionModal({super.key});

  @override
  State<ItemSelectionModal> createState() => _ItemSelectionModalState();
}

class _ItemSelectionModalState extends State<ItemSelectionModal> {
  final _searchController = TextEditingController();
  final _cartItems = <String, int>{}; // productId -> quantity

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(String productId) {
    setState(() {
      _cartItems[productId] = (_cartItems[productId] ?? 0) + 1;
    });
  }

  void _checkout() {
    // TODO: Handle checkout logic
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final cartTotal = _cartItems.values.fold(0, (sum, qty) => sum + qty);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Items',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: PhosphorIcon(PhosphorIconsRegular.x),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Product list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _mockProducts.length,
              itemBuilder: (context, index) {
                final product = _mockProducts[index];
                return _ProductTile(
                  product: product,
                  onAdd: () => _addToCart(product['id'] as String),
                );
              },
            ),
          ),

          // Cart summary and checkout button
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items in cart',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '$cartTotal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.primary(
                    label: 'Checkout',
                    onPressed: cartTotal > 0 ? _checkout : null,
                    expanded: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual product tile.
class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onAdd,
  });

  final Map<String, dynamic> product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final stock = product['stock'] as int;
    final isLowStock = stock < 10;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      'Stock: $stock',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isLowStock
                            ? scheme.error
                            : scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (isLowStock) ...[
                      const SizedBox(width: 4),
                      PhosphorIcon(
                        PhosphorIconsRegular.warning,
                        size: 14,
                        color: scheme.error,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '\$${product['price']}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: PhosphorIcon(
              PhosphorIconsRegular.plus,
              color: scheme.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// Mock products data
final _mockProducts = [
  {'id': '1', 'name': 'Espresso', 'stock': 50, 'price': '3.50'},
  {'id': '2', 'name': 'Cappuccino', 'stock': 5, 'price': '4.50'},
  {'id': '3', 'name': 'Latte', 'stock': 30, 'price': '4.00'},
  {'id': '4', 'name': 'Croissant', 'stock': 8, 'price': '3.00'},
  {'id': '5', 'name': 'Muffin', 'stock': 15, 'price': '2.50'},
];
