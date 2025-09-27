import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final String symbol;
  final double price;
  final double change;
  final int volume;
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.symbol,
    required this.price,
    required this.change,
    required this.volume,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = change >= 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[200],
          child: Text(symbol[0]),
        ),
        title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: onTap,
        subtitle: Text("KL: $volume"),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${price.toStringAsFixed(0)} VND",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "${change.toStringAsFixed(2)}%",
              style: TextStyle(
                color: isUp ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ),
    );
  }
}
