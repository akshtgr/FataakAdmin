import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import './product_edit_screen.dart';
import 'product_search.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  void initState() {
    super.initState();
    _refreshProducts(context);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    var products = productProvider.products;

    // Sort by added timestamp descending
    products.sort((a, b) => b.timestampAdded.compareTo(a.timestampAdded));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fataak Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(products, productProvider),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProductEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: products.length,
          separatorBuilder: (ctx, i) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            return ProductListItem(product: products[i]);
          },
        ),
      ),
    );
  }
}

class ProductListItem extends StatefulWidget {
  final Product product;

  const ProductListItem({required this.product, super.key});

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  bool _isEditing = false;
  late TextEditingController _price300gController;
  late TextEditingController _price1kgController;

  ProductVariant? get _variant300g {
    try {
      return widget.product.variants.firstWhere(
              (v) => v.label.contains('300 g') || v.variantId.contains('300g')
      );
    } catch (e) {
      return null;
    }
  }

  ProductVariant? get _variant1kg {
    try {
      return widget.product.variants.firstWhere(
              (v) => v.label.contains('1 kg') || v.variantId.contains('1kg')
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

  void _toggleEdit() async {
    if (_isEditing) {
      // SAVE ACTION
      final provider = Provider.of<ProductProvider>(context, listen: false);

      bool changed = false;
      // Update local objects
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
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Changes saved"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // ENTER EDIT MODE
      _updateControllers();
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final v300 = _variant300g;
    final v1kg = _variant1kg;
    final has300g = v300 != null;
    final has1kg = v1kg != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: Colors.white,
      child: Row(
        children: [
          // Title Section
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductEditScreen(product: widget.product),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.product.hinglishName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (widget.product.emoji.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(widget.product.emoji, style: const TextStyle(fontSize: 16)),
                        )
                    ],
                  ),
                  if (widget.product.englishName.isNotEmpty)
                    Text(
                      widget.product.englishName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),

          // 300g Price
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Text("300g", style: TextStyle(fontSize: 10, color: Colors.grey)),
                _isEditing && has300g
                    ? SizedBox(
                  height: 35,
                  child: TextField(
                    controller: _price300gController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
                    : Text(
                  has300g ? "₹${v300.ourPrice.toStringAsFixed(0)}" : "-",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 1kg Price
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Text("1kg", style: TextStyle(fontSize: 10, color: Colors.grey)),
                _isEditing && has1kg
                    ? SizedBox(
                  height: 35,
                  child: TextField(
                    controller: _price1kgController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
                    : Text(
                  has1kg ? "₹${v1kg.ourPrice.toStringAsFixed(0)}" : "-",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Edit/Save Button
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: _isEditing ? Colors.green : Colors.blue,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
    );
  }
}