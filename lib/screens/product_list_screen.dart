import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import './product_edit_screen.dart';
import 'product_search.dart';

enum SortOption {
  priceHighToLow,
  priceLowToHigh,
  aToZ,
  zToA,
  latest,
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  SortOption _currentSort = SortOption.aToZ;

  int _expandTriggerVersion = 0;
  bool _shouldExpandAll = false;

  // Theme Colors
  static const Color cBackground = Color(0xFF0F2A1D);
  static const Color cCard = Color(0xFF375534);
  static const Color cTextTint = Color(0xFFE3EED4);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProducts(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleExpandAll() {
    setState(() {
      _shouldExpandAll = !_shouldExpandAll;
      _expandTriggerVersion++;
    });
  }

  double _getPrice(Product p) {
    if (p.variants.isEmpty) return 0.0;
    return p.variants[0].ourPrice;
  }

  List<Product> _getSortedProducts(List<Product> products) {
    List<Product> sortedList = List.from(products);

    switch (_currentSort) {
      case SortOption.priceHighToLow:
        sortedList.sort((a, b) => _getPrice(b).compareTo(_getPrice(a)));
        break;
      case SortOption.priceLowToHigh:
        sortedList.sort((a, b) => _getPrice(a).compareTo(_getPrice(b)));
        break;
      case SortOption.aToZ:
        sortedList
            .sort((a, b) => a.hinglishName.toLowerCase().compareTo(b.hinglishName.toLowerCase()));
        break;
      case SortOption.zToA:
        sortedList
            .sort((a, b) => b.hinglishName.toLowerCase().compareTo(a.hinglishName.toLowerCase()));
        break;
      case SortOption.latest:
        sortedList.sort((a, b) => b.timestampAdded.compareTo(a.timestampAdded));
        break;
    }
    return sortedList;
  }

  String _getSortButtonLabel() {
    switch (_currentSort) {
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.aToZ:
        return 'A-Z';
      case SortOption.zToA:
        return 'Z-A';
      case SortOption.latest:
        return 'Latest Edited';
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final allSortedProducts = _getSortedProducts(productProvider.products);

    // Requirement 3: Separate Active and Inactive/Out-of-Stock products
    final activeProducts =
    allSortedProducts.where((p) => p.isActive && p.inStock).toList();
    final inactiveProducts =
    allSortedProducts.where((p) => !p.isActive || !p.inStock).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: cBackground,
        body: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fataak Admin',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: cTextTint),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: cTextTint),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate:
                        ProductSearchDelegate(allSortedProducts, productProvider),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Controls Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sort Button
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cCard,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton<SortOption>(
                      initialValue: _currentSort,
                      offset: const Offset(
                          0, 45), // Pushes menu down to avoid overlap
                      onSelected: (SortOption item) {
                        setState(() {
                          _currentSort = item;
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.sort, size: 18, color: cTextTint),
                          const SizedBox(width: 8),
                          Text(
                            _getSortButtonLabel(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cTextTint,
                                fontSize: 13),
                          ),
                          const Icon(Icons.arrow_drop_down, color: cTextTint),
                        ],
                      ),
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOption>>[
                        const PopupMenuItem<SortOption>(
                          value: SortOption.priceHighToLow,
                          child: Text('Price: High to Low'),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.priceLowToHigh,
                          child: Text('Price: Low to High'),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.aToZ,
                          child: Text('Alphabetically A-Z'),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.zToA,
                          child: Text('Alphabetically Z-A'),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.latest,
                          child: Text('Latest Edited'),
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Button
                  InkWell(
                    onTap: _toggleExpandAll,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _shouldExpandAll ? "Collapse" : "Expand All",
                            style: const TextStyle(
                              color: cTextTint,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _shouldExpandAll
                                ? Icons.unfold_less
                                : Icons.unfold_more,
                            size: 18,
                            color: cTextTint,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Product List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  interactive: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    // Logic to combine active list, optional header, and inactive list
                    itemCount: activeProducts.length +
                        (inactiveProducts.isEmpty
                            ? 0
                            : 1 + inactiveProducts.length),
                    itemBuilder: (ctx, i) {
                      // 1. Render Active Products
                      if (i < activeProducts.length) {
                        return ProductListItem(
                          key: ValueKey(activeProducts[i].id),
                          product: activeProducts[i],
                          expandTriggerVersion: _expandTriggerVersion,
                          shouldExpand: _shouldExpandAll,
                        );
                      }

                      // 2. Render Header for Inactive Products
                      if (i == activeProducts.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: Colors.white24),
                              SizedBox(height: 8),
                              Text(
                                "Out of Stock / Inactive Products",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 3. Render Inactive Products
                      final inactiveIndex = i - activeProducts.length - 1;
                      return ProductListItem(
                        key: ValueKey(inactiveProducts[inactiveIndex].id),
                        product: inactiveProducts[inactiveIndex],
                        expandTriggerVersion: _expandTriggerVersion,
                        shouldExpand: _shouldExpandAll,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProductEditScreen(),
              ),
            );
          },
          backgroundColor: cTextTint,
          child: const Icon(Icons.add, color: cBackground),
        ),
      ),
    );
  }
}

class ProductListItem extends StatefulWidget {
  final Product product;
  final int expandTriggerVersion;
  final bool shouldExpand;

  const ProductListItem({
    required this.product,
    required this.expandTriggerVersion,
    required this.shouldExpand,
    super.key,
  });

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  bool _isExpanded = false;
  bool _isEditing = false;
  late TextEditingController _price1Controller;
  late TextEditingController _price2Controller;
  int _lastSeenTriggerVersion = -1;

  // Colors
  static const Color cCard = Color(0xFF375534);
  static const Color cTextTint = Color(0xFFE3EED4);
  static const Color cSubText = Color(0xFFB0C4B1);

  // Dynamic variants
  ProductVariant? get _variant1 =>
      widget.product.variants.isNotEmpty ? widget.product.variants[0] : null;
  ProductVariant? get _variant2 =>
      widget.product.variants.length > 1 ? widget.product.variants[1] : null;

  @override
  void initState() {
    super.initState();
    _price1Controller = TextEditingController();
    _price2Controller = TextEditingController();
    _updateControllers();
    _handleExpandTrigger();
  }

  @override
  void didUpdateWidget(ProductListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product != oldWidget.product) {
      _updateControllers();
    }
    _handleExpandTrigger();
  }

  void _handleExpandTrigger() {
    if (widget.expandTriggerVersion != _lastSeenTriggerVersion) {
      setState(() {
        _isExpanded = widget.shouldExpand;
        _lastSeenTriggerVersion = widget.expandTriggerVersion;
        if (!_isExpanded) _isEditing = false;
      });
    }
  }

  void _updateControllers() {
    _price1Controller.text = _variant1?.ourPrice.toStringAsFixed(0) ?? '';
    _price2Controller.text = _variant2?.ourPrice.toStringAsFixed(0) ?? '';
  }

  // --- Logic to Reset/Cancel Edits ---
  void _cancelEdits() {
    setState(() {
      _updateControllers(); // Reset text to original values
      _isEditing = false;
    });
    FocusScope.of(context).unfocus(); // Hide Cursor
  }

  @override
  void dispose() {
    _price1Controller.dispose();
    _price2Controller.dispose();
    super.dispose();
  }

  void _saveQuickEdits() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    bool changed = false;

    if (_variant1 != null) {
      double? newVal = double.tryParse(_price1Controller.text);
      if (newVal != null && newVal != _variant1!.ourPrice) {
        _variant1!.ourPrice = newVal;
        changed = true;
      }
    }
    if (_variant2 != null) {
      double? newVal = double.tryParse(_price2Controller.text);
      if (newVal != null && newVal != _variant2!.ourPrice) {
        _variant2!.ourPrice = newVal;
        changed = true;
      }
    }

    if (changed) {
      await provider.updateProduct(widget.product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Price updated"), duration: Duration(seconds: 1)),
        );
      }
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final v1 = _variant1;
    final v2 = _variant2;
    final hasV1 = v1 != null;
    final hasV2 = v2 != null;

    Widget buildAvatar() {
      if (widget.product.imageUrl.isNotEmpty) {
        return CircleAvatar(
          radius: 25, // Increased size
          backgroundImage: NetworkImage(widget.product.imageUrl),
          backgroundColor: Colors.white24,
        );
      } else {
        String initial = widget.product.hinglishName.isNotEmpty
            ? widget.product.hinglishName[0].toUpperCase()
            : '?';
        return CircleAvatar(
          radius: 25, // Increased size
          backgroundColor: cTextTint,
          child: Text(
            initial,
            style: const TextStyle(color: cCard, fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    // Helper method for requirement 1: Cursor to end on tap
    void moveCursorToEnd(TextEditingController controller) {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      color: cCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ListTile(
            visualDensity: VisualDensity.compact,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: buildAvatar(),
            title: Text(
              widget.product.hinglishName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18, // Increased size
                color: cTextTint,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Edit Pencil (Requirement 2: Toggle Behavior)
                IconButton(
                  icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.edit,
                      color: cSubText),
                  onPressed: () {
                    setState(() {
                      // Toggle expansion logic
                      if (_isExpanded) {
                        // If already expanded, collapse it
                        _isExpanded = false;
                        _isEditing = false;
                      } else {
                        // If collapsed, expand and enable editing
                        _isExpanded = true;
                        _isEditing = true;
                        _updateControllers();
                      }
                    });
                  },
                  tooltip: _isExpanded ? 'Collapse' : 'Quick Edit',
                ),
                // Full Edit Arrow
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: cTextTint),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductEditScreen(product: widget.product),
                      ),
                    );
                  },
                  tooltip: 'Edit Product Details',
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (!_isExpanded) _isEditing = false;
              });
            },
          ),
          if (_isExpanded)
            TapRegion(
              onTapOutside: (event) {
                if (_isEditing) {
                  // Requirement 1: Only clicks outside disable it.
                  // TapRegion handles clicks *outside* this container.
                  // Interacting inside (dragging cursor) won't trigger this.
                  _cancelEdits();
                }
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 12, top: 0),
                child: Column(
                  children: [
                    const Divider(color: Colors.white12, height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Variant 1 Column
                              Column(
                                children: [
                                  Text(hasV1 ? v1.label : "Var 1",
                                      style: const TextStyle(
                                          fontSize: 11, color: cSubText)),
                                  const SizedBox(height: 2),
                                  _isEditing && hasV1
                                      ? SizedBox(
                                    width: 60,
                                    height: 30,
                                    child: TextField(
                                      controller: _price1Controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: cCard,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                      // Requirement 1: Cursor to end on tap
                                      onTap: () => moveCursorToEnd(
                                          _price1Controller),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: cTextTint,
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 0),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  )
                                      : Text(
                                    hasV1
                                        ? "₹${v1.ourPrice.toStringAsFixed(0)}"
                                        : "-",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: cTextTint),
                                  ),
                                ],
                              ),
                              // Variant 2 Column
                              Column(
                                children: [
                                  Text(hasV2 ? v2.label : "Var 2",
                                      style: const TextStyle(
                                          fontSize: 11, color: cSubText)),
                                  const SizedBox(height: 2),
                                  _isEditing && hasV2
                                      ? SizedBox(
                                    width: 60,
                                    height: 30,
                                    child: TextField(
                                      controller: _price2Controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: cCard,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                      // Requirement 1: Cursor to end on tap
                                      onTap: () => moveCursorToEnd(
                                          _price2Controller),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: cTextTint,
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 0),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  )
                                      : Text(
                                    hasV2
                                        ? "₹${v2.ourPrice.toStringAsFixed(0)}"
                                        : "-",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: cTextTint),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            if (_isEditing) ...[
                              // Cancel Button (Cross)
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: Colors.redAccent,
                                onPressed: _cancelEdits,
                                tooltip: 'Cancel',
                              ),
                              // Save Button (Check)
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                color: cTextTint,
                                onPressed: _saveQuickEdits,
                                tooltip: 'Save Price',
                              ),
                            ]
                          ],
                        )
                      ],
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