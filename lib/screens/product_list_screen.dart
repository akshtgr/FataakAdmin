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

  bool _isDragging = false;
  double _dragPosition = 0.0;
  String _currentLetter = "";

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
        sortedList.sort((a, b) => a.hinglishName.toLowerCase().compareTo(b.hinglishName.toLowerCase()));
        break;
      case SortOption.zToA:
        sortedList.sort((a, b) => b.hinglishName.toLowerCase().compareTo(a.hinglishName.toLowerCase()));
        break;
      case SortOption.latest:
        sortedList.sort((a, b) => b.timestampAdded.compareTo(a.timestampAdded));
        break;
    }
    return sortedList;
  }

  String _getSortButtonLabel() {
    switch (_currentSort) {
      case SortOption.priceHighToLow: return 'Price: High to Low';
      case SortOption.priceLowToHigh: return 'Price: Low to High';
      case SortOption.aToZ: return 'A-Z';
      case SortOption.zToA: return 'Z-A';
      case SortOption.latest: return 'Latest Edited';
    }
  }

  void _handleDrag(double localDy, double height, int itemCount, List<Product> sortedProducts) {
    setState(() {
      _isDragging = true;
      _dragPosition = localDy.clamp(0.0, height);

      double percentage = _dragPosition / height;

      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(percentage * maxScroll);
      }

      int index = (percentage * (itemCount - 1)).round();
      if (index >= 0 && index < itemCount) {
        String name = sortedProducts[index].hinglishName;
        if (name.isNotEmpty) {
          _currentLetter = name[0].toUpperCase();
        } else {
          _currentLetter = "#";
        }
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details, double height, int itemCount, List<Product> sortedProducts) {
    _handleDrag(details.localPosition.dy, height, itemCount, sortedProducts);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details, double height, int itemCount, List<Product> sortedProducts) {
    _handleDrag(details.localPosition.dy, height, itemCount, sortedProducts);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final sortedProducts = _getSortedProducts(productProvider.products);

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
                        color: cTextTint
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: cTextTint),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: ProductSearchDelegate(sortedProducts, productProvider),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cCard,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton<SortOption>(
                      initialValue: _currentSort,
                      offset: const Offset(0, 45), // Pushes menu down to avoid overlap
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
                                fontSize: 13
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: cTextTint),
                        ],
                      ),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            _shouldExpandAll ? Icons.unfold_less : Icons.unfold_more,
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
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Scrollbar(
                      // Using native Scrollbar for the visual line
                      controller: _scrollController,
                      thumbVisibility: true,
                      interactive: true,
                      // Thickness and color defined in Theme (main.dart)
                      child: ListView.builder(
                        controller: _scrollController,
                        // Increased horizontal padding to 16 for spacing
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: sortedProducts.length,
                        itemBuilder: (ctx, i) {
                          return ProductListItem(
                            key: ValueKey(sortedProducts[i].id),
                            product: sortedProducts[i],
                            expandTriggerVersion: _expandTriggerVersion,
                            shouldExpand: _shouldExpandAll,
                          );
                        },
                      ),
                    ),
                  ),

                  // Invisible Touch Area for "Bubble Dragging"
                  if (sortedProducts.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onVerticalDragStart: (details) => _onVerticalDragStart(details, constraints.maxHeight, sortedProducts.length, sortedProducts),
                              onVerticalDragUpdate: (details) => _onVerticalDragUpdate(details, constraints.maxHeight, sortedProducts.length, sortedProducts),
                              onVerticalDragEnd: _onVerticalDragEnd,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 30, // Touch target width
                                color: Colors.transparent, // Invisible
                                alignment: Alignment.centerRight,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    // Removed the "Track" Container to fix the "thick line" issue

                                    // Bubble Thumb (Visible only when dragging)
                                    if (_isDragging)
                                      Positioned(
                                        top: _dragPosition - 30,
                                        right: 40,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: cCard,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: cTextTint, width: 1.5),
                                              boxShadow: [
                                                BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))
                                              ]
                                          ),
                                          child: Text(
                                            _currentLetter,
                                            style: const TextStyle(color: cTextTint, fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                ],
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
          backgroundColor: cCard,
          child: const Icon(Icons.add, color: cTextTint),
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
  late TextEditingController _price300gController;
  late TextEditingController _price1kgController;
  int _lastSeenTriggerVersion = -1;

  // Colors
  static const Color cCard = Color(0xFF375534);
  static const Color cTextTint = Color(0xFFE3EED4);
  static const Color cSubText = Color(0xFFB0C4B1);

  ProductVariant? get _variant300g {
    try {
      return widget.product.variants.firstWhere(
            (v) => v.label.toLowerCase().contains('300 g') || v.variantId.contains('300g'),
      );
    } catch (e) {
      return null;
    }
  }

  ProductVariant? get _variant1kg {
    try {
      return widget.product.variants.firstWhere(
            (v) => v.label.toLowerCase().contains('1 kg') || v.variantId.contains('1kg'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _price300gController = TextEditingController();
    _price1kgController = TextEditingController();
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
    _price300gController.text = _variant300g?.ourPrice.toStringAsFixed(0) ?? '';
    _price1kgController.text = _variant1kg?.ourPrice.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _price300gController.dispose();
    _price1kgController.dispose();
    super.dispose();
  }

  void _saveQuickEdits() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    bool changed = false;

    if (_variant300g != null) {
      double? newVal = double.tryParse(_price300gController.text);
      if (newVal != null && newVal != _variant300g!.ourPrice) {
        _variant300g!.ourPrice = newVal;
        changed = true;
      }
    }
    if (_variant1kg != null) {
      double? newVal = double.tryParse(_price1kgController.text);
      if (newVal != null && newVal != _variant1kg!.ourPrice) {
        _variant1kg!.ourPrice = newVal;
        changed = true;
      }
    }

    if (changed) {
      await provider.updateProduct(widget.product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Price updated"), duration: Duration(seconds: 1)),
        );
      }
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final v300 = _variant300g;
    final v1kg = _variant1kg;
    final has300g = v300 != null;
    final has1kg = v1kg != null;

    Widget buildAvatar() {
      if (widget.product.imageUrl.isNotEmpty) {
        return CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(widget.product.imageUrl),
          backgroundColor: Colors.white24,
        );
      } else {
        String initial = widget.product.hinglishName.isNotEmpty
            ? widget.product.hinglishName[0].toUpperCase()
            : '?';
        return CircleAvatar(
          radius: 18,
          backgroundColor: cTextTint,
          child: Text(
            initial,
            style: const TextStyle(color: cCard, fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2), // Reduced vertical spacing
      color: cCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // More circular corners
      ),
      child: Column(
        children: [
          ListTile(
            visualDensity: VisualDensity.compact, // Decreased height
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: buildAvatar(),
            title: Text(
              widget.product.hinglishName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: cTextTint,
              ),
            ),
            subtitle: widget.product.englishName.isNotEmpty
                ? Text(widget.product.englishName, style: const TextStyle(fontSize: 12, color: cSubText))
                : null,
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: cTextTint,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (!_isExpanded) _isEditing = false;
                });
              },
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (!_isExpanded) _isEditing = false;
              });
            },
          ),

          if (_isExpanded)
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 0),
              child: Column(
                children: [
                  const Divider(color: Colors.white12, height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text("300g", style: TextStyle(fontSize: 11, color: cSubText)),
                                const SizedBox(height: 2),
                                _isEditing && has300g
                                    ? SizedBox(
                                  width: 60,
                                  height: 30,
                                  child: TextField(
                                    controller: _price300gController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: cCard, fontSize: 13, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: cTextTint,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                  ),
                                )
                                    : Text(
                                  has300g ? "₹${v300.ourPrice.toStringAsFixed(0)}" : "-",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: cTextTint),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text("1kg", style: TextStyle(fontSize: 11, color: cSubText)),
                                const SizedBox(height: 2),
                                _isEditing && has1kg
                                    ? SizedBox(
                                  width: 60,
                                  height: 30,
                                  child: TextField(
                                    controller: _price1kgController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: cCard, fontSize: 13, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: cTextTint,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                  ),
                                )
                                    : Text(
                                  has1kg ? "₹${v1kg.ourPrice.toStringAsFixed(0)}" : "-",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: cTextTint),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (_isEditing)
                            IconButton(
                              icon: const Icon(Icons.check_circle),
                              color: cTextTint,
                              onPressed: _saveQuickEdits,
                              tooltip: 'Save Price',
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.price_change_outlined),
                              color: cSubText,
                              onPressed: () {
                                setState(() {
                                  _updateControllers();
                                  _isEditing = true;
                                });
                              },
                              tooltip: 'Edit Price',
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_note),
                            color: cSubText,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductEditScreen(product: widget.product),
                                ),
                              );
                            },
                            tooltip: 'Full Edit',
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}