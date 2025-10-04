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

  // Use a map to hold all form data
  final Map<String, dynamic> _formData = {
    'name': '',
    'image_url': '',
    'market_price': 0.0,
    'our_price': 0.0,
    'price_unit': 'per kg', // New
    'unit': 'kg',
    'stock': 0,
    'stock_unit': 'kg', // New
    'stock_label': 'left', // New
    'in_stock': true,
    'category': 'vegetable',
    'is_featured': false,
    'tags': 'fresh',
  };

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // If editing, populate form data from the existing product
      _formData['name'] = widget.product!.name;
      _formData['image_url'] = widget.product!.imageUrl;
      _formData['market_price'] = widget.product!.marketPrice;
      _formData['our_price'] = widget.product!.ourPrice;
      _formData['price_unit'] = widget.product!.priceUnit; // New
      _formData['unit'] = widget.product!.unit;
      _formData['stock'] = widget.product!.stock;
      _formData['stock_unit'] = widget.product!.stockUnit; // New
      _formData['stock_label'] = widget.product!.stockLabel; // New
      _formData['in_stock'] = widget.product!.inStock;
      _formData['category'] = widget.product!.category;
      _formData['is_featured'] = widget.product!.isFeatured;
      _formData['tags'] = widget.product!.tags.join(', ');
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final productProvider =
      Provider.of<ProductProvider>(context, listen: false);

      final product = Product(
        id: widget.product?.id ?? DateTime.now().toString(),
        name: _formData['name'],
        imageUrl: _formData['image_url'],
        marketPrice: _formData['market_price'],
        ourPrice: _formData['our_price'],
        priceUnit: _formData['price_unit'], // New
        unit: _formData['unit'],
        stock: _formData['stock'],
        stockUnit: _formData['stock_unit'], // New
        stockLabel: _formData['stock_label'], // New
        inStock: _formData['in_stock'],
        category: _formData['category'],
        isFeatured: _formData['is_featured'],
        tags:
        (_formData['tags'] as String).split(',').map((s) => s.trim()).toList(),
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        productProvider.addProduct(product);
      } else {
        productProvider.updateProduct(product);
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
                initialValue: _formData['name'],
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _formData['name'] = value!,
              ),
              TextFormField(
                initialValue: _formData['image_url'],
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an image URL' : null,
                onSaved: (value) => _formData['image_url'] = value!,
              ),
              TextFormField(
                initialValue: _formData['market_price'].toString(),
                decoration: const InputDecoration(labelText: 'Market Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) =>
                _formData['market_price'] = double.parse(value!),
              ),
              TextFormField(
                initialValue: _formData['our_price'].toString(),
                decoration: const InputDecoration(labelText: 'Our Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) =>
                _formData['our_price'] = double.parse(value!),
              ),
              TextFormField( // NEW
                initialValue: _formData['price_unit'],
                decoration: const InputDecoration(labelText: 'Price Unit (e.g., per kg)'),
                onSaved: (value) => _formData['price_unit'] = value!,
              ),
              TextFormField(
                initialValue: _formData['unit'],
                decoration:
                const InputDecoration(labelText: 'Display Unit (e.g., 1 piece)'),
                onSaved: (value) => _formData['unit'] = value!,
              ),
              TextFormField(
                initialValue: _formData['stock'].toString(),
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter the stock' : null,
                onSaved: (value) => _formData['stock'] = int.parse(value!),
              ),
              TextFormField( // NEW
                initialValue: _formData['stock_unit'],
                decoration: const InputDecoration(labelText: 'Stock Unit (e.g., pieces)'),
                onSaved: (value) => _formData['stock_unit'] = value!,
              ),
              TextFormField( // NEW
                initialValue: _formData['stock_label'],
                decoration: const InputDecoration(labelText: 'Stock Label (e.g., left)'),
                onSaved: (value) => _formData['stock_label'] = value!,
              ),
              TextFormField(
                initialValue: _formData['category'],
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a category' : null,
                onSaved: (value) => _formData['category'] = value!,
              ),
              TextFormField(
                initialValue: _formData['tags'],
                decoration:
                const InputDecoration(labelText: 'Tags (comma-separated)'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter at least one tag' : null,
                onSaved: (value) => _formData['tags'] = value!,
              ),
              SwitchListTile(
                title: const Text('In Stock'),
                value: _formData['in_stock'],
                onChanged: (value) {
                  setState(() {
                    _formData['in_stock'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Is Featured'),
                value: _formData['is_featured'],
                onChanged: (value) {
                  setState(() {
                    _formData['is_featured'] = value;
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