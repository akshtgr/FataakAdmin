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
  late String _name;
  late double _marketPrice;
  late double _ourPrice;
  late int _stock;
  late bool _inStock;
  late String _unit;
  late String _category;
  late String _tags;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _marketPrice = widget.product?.marketPrice ?? 0.0;
    _ourPrice = widget.product?.ourPrice ?? 0.0;
    _stock = widget.product?.stock ?? 0;
    _inStock = widget.product?.inStock ?? true;
    _unit = widget.product?.unit ?? 'kg';
    _category = widget.product?.category ?? 'vegetable';
    _tags = widget.product?.tags.join(', ') ?? 'fresh';
    _imageUrl = widget.product?.imageUrl ?? '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final productProvider =
      Provider.of<ProductProvider>(context, listen: false);

      if (widget.product == null) {
        // Add new product
        productProvider.addProduct(
          Product(
            id: DateTime.now().toString(),
            name: _name,
            marketPrice: _marketPrice,
            ourPrice: _ourPrice,
            stock: _stock,
            inStock: _inStock,
            unit: _unit,
            category: _category,
            tags: _tags.split(',').map((s) => s.trim()).toList(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            imageUrl: _imageUrl,
          ),
        );
      } else {
        // Update existing product
        productProvider.updateProduct(
          Product(
            id: widget.product!.id,
            name: _name,
            marketPrice: _marketPrice,
            ourPrice: _ourPrice,
            stock: _stock,
            inStock: _inStock,
            unit: _unit,
            category: _category,
            tags: _tags.split(',').map((s) => s.trim()).toList(),
            createdAt: widget.product!.createdAt,
            updatedAt: DateTime.now(),
            imageUrl: _imageUrl,
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _marketPrice.toString(),
                decoration: const InputDecoration(labelText: 'Market Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => _marketPrice = double.parse(value!),
              ),
              TextFormField(
                initialValue: _ourPrice.toString(),
                decoration: const InputDecoration(labelText: 'Our Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => _ourPrice = double.parse(value!),
              ),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter the stock' : null,
                onSaved: (value) => _stock = int.parse(value!),
              ),
              TextFormField(
                initialValue: _unit,
                decoration: const InputDecoration(labelText: 'Unit (e.g., kg, piece)'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a unit' : null,
                onSaved: (value) => _unit = value!,
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a category' : null,
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _tags,
                decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter at least one tag' : null,
                onSaved: (value) => _tags = value!,
              ),
              TextFormField(
                initialValue: _imageUrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an image URL' : null,
                onSaved: (value) => _imageUrl = value!,
              ),
              SwitchListTile(
                title: const Text('In Stock'),
                value: _inStock,
                onChanged: (value) {
                  setState(() {
                    _inStock = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}