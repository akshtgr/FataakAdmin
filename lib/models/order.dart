class Order {
  final String id;
  final String customerName;
  final String phone;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String address;
  String status;
  final DateTime timestamp; // ADDED THIS LINE

  Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.items,
    required this.totalPrice,
    required this.address,
    this.status = 'Pending',
    required this.timestamp, // ADDED THIS LINE
  });
}