import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  final List<Map<String, dynamic>> portfolio = const [
    {"symbol": "VNM", "quantity": 50, "avgPrice": 72000.0},
    {"symbol": "FPT", "quantity": 30, "avgPrice": 91000.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portfolio"),
        backgroundColor: Colors.green[300],
      ),
      body: ListView.builder(
        itemCount: portfolio.length,
        itemBuilder: (context, index) {
          final item = portfolio[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[200],
                child: Text(item["symbol"][0]),
              ),
              title: Text(item["symbol"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Số lượng: ${item["quantity"]}"),
              trailing: Text(
                "Avg: ${item["avgPrice"].toStringAsFixed(0)} VND",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }
}
