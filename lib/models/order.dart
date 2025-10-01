class Order {
  final String id;
  final String customerName;
  final String phone; // Add this line
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String address;
  String status;

  Order({
    required this.id,
    required this.customerName,
    required this.phone, // Add this line
    required this.items,
    required this.totalPrice,
    required this.address,
    this.status = 'Pending',
  });
}