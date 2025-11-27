import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({this.product, super.key});

  @override
  ProductEditScreenState createState() => ProductEditScreenState();
}

class ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _englishNameController = TextEditingController();
  final _hinglishNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _baseUnitController = TextEditingController();
  final _minOrderQtyController = TextEditingController();
  final _minOrderUnitController = TextEditingController();
  final _tagsController = TextEditingController();
  final _searchKeywordsController = TextEditingController();
  final _healthBenefitsController = TextEditingController();
  final _emojiController = TextEditingController();
  final _suitableForController = TextEditingController();

  bool _inStock = true;
  bool _isActive = true;

  List<ProductVariant> _variants = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _englishNameController.text = widget.product!.englishName;
      _hinglishNameController.text = widget.product!.hinglishName;
      _categoryController.text = widget.product!.category;
      _imageUrlController.text = widget.product!.imageUrl;
      _descriptionController.text = widget.product!.description;
      _baseUnitController.text = widget.product!.baseUnit;
      _minOrderQtyController.text = widget.product!.minOrderQty.toString();
      _minOrderUnitController.text = widget.product!.minOrderUnit;
      _tagsController.text = widget.product!.tags.join(', ');
      _searchKeywordsController.text = widget.product!.searchKeywords.join(', ');
      _healthBenefitsController.text = widget.product!.healthBenefits.join('\n');
      _emojiController.text = widget.product!.emoji;
      _suitableForController.text = widget.product!.suitableFor.join(', ');
      _inStock = widget.product!.inStock;
      _isActive = widget.product!.isActive;

      _variants = widget.product!.variants.map((v) => ProductVariant(
          variantId: v.variantId,
          label: v.label,
          quantity: v.quantity,
          quantityUnit: v.quantityUnit,
          marketPrice: v.marketPrice,
          ourPrice: v.ourPrice,
          discountPercent: v.discountPercent,
          isDefault: v.isDefault,
          pricingRule: v.pricingRule
      )).toList();
    } else {
      _variants = [
        ProductVariant(variantId: '', label: '300 g', quantity: 300, quantityUnit: 'g', marketPrice: 0, ourPrice: 0, isDefault: true),
        ProductVariant(variantId: '', label: '1 kg', quantity: 1000, quantityUnit: 'g', marketPrice: 0, ourPrice: 0, isDefault: false),
      ];
    }
  }

  @override
  void dispose() {
    _englishNameController.dispose();
    _hinglishNameController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _baseUnitController.dispose();
    _minOrderQtyController.dispose();
    _minOrderUnitController.dispose();
    _tagsController.dispose();
    _searchKeywordsController.dispose();
    _healthBenefitsController.dispose();
    _emojiController.dispose();
    _suitableForController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      List<String> splitComma(String text) {
        return text.isEmpty
            ? []
            : text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }

      final product = Product(
        id: widget.product?.id ?? '',
        englishName: _englishNameController.text,
        hinglishName: _hinglishNameController.text,
        category: _categoryController.text,
        imageUrl: _imageUrlController.text,
        inStock: _inStock,
        isActive: _isActive,
        baseUnit: _baseUnitController.text,
        minOrderQty: int.tryParse(_minOrderQtyController.text) ?? 0,
        minOrderUnit: _minOrderUnitController.text,
        description: _descriptionController.text,
        variants: _variants,
        healthBenefits: _healthBenefitsController.text.isEmpty
            ? []
            : _healthBenefitsController.text.split('\n').where((s) => s.isNotEmpty).toList(),
        tags: splitComma(_tagsController.text),
        searchKeywords: splitComma(_searchKeywordsController.text),
        suitableFor: splitComma(_suitableForController.text),
        emoji: _emojiController.text,
        timestampAdded: widget.product?.timestampAdded ?? DateTime.now(),
      );

      if (widget.product == null) {
        productProvider.addProduct(product);
      } else {
        productProvider.updateProduct(product);
      }
      Navigator.of(context).pop();
    }
  }

  Widget _buildVariantEditor(int index) {
    final variant = _variants[index];
    return Card(
      color: const Color(0xFF375534),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: variant.label,
                    decoration: const InputDecoration(labelText: 'Label'),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => variant.label = val,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: variant.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => variant.quantity = int.tryParse(val) ?? 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: variant.quantityUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => variant.quantityUnit = val,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: variant.marketPrice.toString(),
                    decoration: const InputDecoration(labelText: 'Market Price'),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => variant.marketPrice = double.tryParse(val) ?? 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: variant.ourPrice.toString(),
                    decoration: const InputDecoration(labelText: 'Our Price'),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => variant.ourPrice = double.tryParse(val) ?? 0,
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              title: const Text("Is Default", style: TextStyle(color: Colors.white)),
              value: variant.isDefault,
              checkColor: Colors.black,
              activeColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              onChanged: (val) {
                setState(() {
                  for (var v in _variants) {
                    v.isDefault = false;
                  }
                  variant.isDefault = val ?? false;
                });
              },
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _variants.removeAt(index);
                });
              },
              child: const Text("Remove Variant", style: TextStyle(color: Colors.redAccent)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // App Bar Removed
        body: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    widget.product == null ? 'Add Product' : 'Edit Product',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: _saveForm,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Basic Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _englishNameController,
                              decoration: const InputDecoration(labelText: 'English Name'),
                              style: const TextStyle(color: Colors.black),
                              validator: (val) => val!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: _emojiController,
                              decoration: const InputDecoration(labelText: 'Emoji'),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _hinglishNameController,
                        decoration: const InputDecoration(labelText: 'Hinglish Name'),
                        style: const TextStyle(color: Colors.black),
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Category'),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(labelText: 'Image URL'),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                        style: const TextStyle(color: Colors.black),
                      ),

                      const SizedBox(height: 20),
                      const Text("Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('In Stock', style: TextStyle(color: Colors.white)),
                              value: _inStock,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF6B9071),
                              onChanged: (val) => setState(() => _inStock = val),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Is Active', style: TextStyle(color: Colors.white)),
                              value: _isActive,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF6B9071),
                              onChanged: (val) => setState(() => _isActive = val),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text("Units & Minimums", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _baseUnitController,
                              decoration: const InputDecoration(labelText: 'Base Unit'),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _minOrderQtyController,
                              decoration: const InputDecoration(labelText: 'Min Qty'),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _minOrderUnitController,
                              decoration: const InputDecoration(labelText: 'Min Unit'),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text("Variants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ...List.generate(_variants.length, (index) => _buildVariantEditor(index)),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _variants.add(ProductVariant(
                                variantId: '${DateTime.now().millisecondsSinceEpoch}',
                                label: 'New',
                                quantity: 100,
                                quantityUnit: 'g',
                                marketPrice: 0,
                                ourPrice: 0
                            ));
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Variant"),
                      ),

                      const SizedBox(height: 20),
                      const Text("Metadata", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _suitableForController,
                        decoration: const InputDecoration(labelText: 'Suitable For (comma separated)'),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _searchKeywordsController,
                        decoration: const InputDecoration(labelText: 'Search Keywords'),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _healthBenefitsController,
                        decoration: const InputDecoration(labelText: 'Health Benefits (one per line)'),
                        maxLines: 4,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}