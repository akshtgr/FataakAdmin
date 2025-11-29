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

  // Colors
  static const Color cBackground = Color(0xFF0F2A1D); // App Bar / Background Color
  static const Color cCard = Color(0xFF375534);       // Card / Field Fill Color
  static const Color cTextTint = Color(0xFFE3EED4);   // Text Color

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
    _imageUrlController.addListener(() {
      setState(() {});
    });

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

      // Deep copy variants to ensure editing doesn't affect the original object immediately
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

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: cTextTint, fontSize: 13),
      filled: true,
      fillColor: cCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: cBackground, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
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

  // Requirement 4: Delete Product Logic
  void _deleteProduct() async {
    if (widget.product == null) return; // Should not happen if button is only shown when editing

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cCard,
        title: const Text('Delete Product?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
          style: TextStyle(color: cTextTint),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: cTextTint)),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await Provider.of<ProductProvider>(context, listen: false).deleteProduct(widget.product!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: cCard,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: cBackground, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildVariantCard(int index) {
    final variant = _variants[index];
    return Card(
      color: cCard,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: cBackground, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: variant.label,
              decoration: _buildInputDecoration('Label'),
              style: const TextStyle(color: cTextTint),
              cursorColor: cBackground,
              onChanged: (val) => variant.label = val,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: variant.quantity.toString(),
              decoration: _buildInputDecoration('Qty'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: cTextTint),
              cursorColor: cBackground,
              onChanged: (val) => variant.quantity = int.tryParse(val) ?? 0,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: variant.quantityUnit,
              decoration: _buildInputDecoration('Unit'),
              style: const TextStyle(color: cTextTint),
              cursorColor: cBackground,
              onChanged: (val) => variant.quantityUnit = val,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: variant.marketPrice.toString(),
              decoration: _buildInputDecoration('Market Price'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: cTextTint),
              cursorColor: cBackground,
              onChanged: (val) => variant.marketPrice = double.tryParse(val) ?? 0,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: variant.ourPrice.toString(),
              decoration: _buildInputDecoration('Our Price'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: cTextTint),
              cursorColor: cBackground,
              onChanged: (val) => variant.ourPrice = double.tryParse(val) ?? 0,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Is Default", style: TextStyle(color: Colors.white, fontSize: 13)),
              value: variant.isDefault,
              checkColor: cBackground,
              activeColor: cTextTint,
              side: const BorderSide(color: cTextTint),
              onChanged: (val) {
                setState(() {
                  for (var v in _variants) {
                    v.isDefault = false;
                  }
                  variant.isDefault = val ?? false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  _variants.removeAt(index);
                });
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: cBackground,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header (No Save Button)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Text(
                            widget.product == null ? 'Add Product' : 'Edit Product',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 1. Image Preview
                      Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: cCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cBackground, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _imageUrlController.text.isNotEmpty
                                ? Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.broken_image, color: cTextTint, size: 40));
                              },
                            )
                                : const Center(child: Icon(Icons.image_outlined, color: cTextTint, size: 40)),
                          ),
                        ),
                      ),

                      // 2. Units & Minimums Card
                      _buildSectionCard(
                        title: "Units & Minimums",
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _baseUnitController,
                                  decoration: _buildInputDecoration('Base Unit'),
                                  style: const TextStyle(color: cTextTint),
                                  cursorColor: cBackground,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _minOrderQtyController,
                                  decoration: _buildInputDecoration('Min Qty'),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: cTextTint),
                                  cursorColor: cBackground,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _minOrderUnitController,
                                  decoration: _buildInputDecoration('Min Unit'),
                                  style: const TextStyle(color: cTextTint),
                                  cursorColor: cBackground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // 3. Variant Cards (Side by Side)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Text("Variants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(_variants.length, (index) {
                              return SizedBox(
                                width: (constraints.maxWidth - 12) / 2, // Half width minus spacing
                                child: _buildVariantCard(index),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
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
                        icon: const Icon(Icons.add, color: cBackground),
                        label: const Text("Add Variant", style: TextStyle(color: cBackground, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cTextTint,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Basic Information Card
                      _buildSectionCard(
                        title: "Basic Information",
                        children: [
                          TextFormField(
                            controller: _englishNameController,
                            decoration: _buildInputDecoration('English Name'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emojiController,
                            decoration: _buildInputDecoration('Emoji'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _hinglishNameController,
                            decoration: _buildInputDecoration('Hinglish Name'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _categoryController,
                            decoration: _buildInputDecoration('Category'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _imageUrlController,
                            decoration: _buildInputDecoration('Image URL'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: _buildInputDecoration('Description'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      ),

                      // 5. Metadata Card
                      _buildSectionCard(
                        title: "Metadata",
                        children: [
                          TextFormField(
                            controller: _suitableForController,
                            decoration: _buildInputDecoration('Suitable For (comma separated)'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _tagsController,
                            decoration: _buildInputDecoration('Tags (comma separated)'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _searchKeywordsController,
                            decoration: _buildInputDecoration('Search Keywords'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _healthBenefitsController,
                            decoration: _buildInputDecoration('Health Benefits (one per line)'),
                            style: const TextStyle(color: cTextTint),
                            cursorColor: cBackground,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      ),

                      // 6. Status Card (At Bottom)
                      _buildSectionCard(
                        title: "Status",
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('In Stock', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  value: _inStock,
                                  activeColor: Colors.white,
                                  activeTrackColor: const Color(0xFF6B9071),
                                  onChanged: (val) => setState(() => _inStock = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Is Active', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  value: _isActive,
                                  activeColor: Colors.white,
                                  activeTrackColor: const Color(0xFF6B9071),
                                  onChanged: (val) => setState(() => _isActive = val),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),

                      // Requirement 4: Delete Product Button (Shown only in edit mode)
                      if (widget.product != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _deleteProduct,
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            label: const Text(
                              "Delete Product",
                              style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: cCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Save Overlay Button (Centered, Compact, Lower Position)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.extended(
                    onPressed: _saveForm,
                    backgroundColor: cTextTint,
                    label: const Text(
                      "Save Product",
                      style: TextStyle(color: cBackground, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    icon: const Icon(Icons.save, color: cBackground),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}