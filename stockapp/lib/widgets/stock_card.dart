import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockCard extends StatelessWidget {
  final String symbol;
  final double price;
  final double change;
  final int volume;
  final VoidCallback? onTap;
  final double width; // chiều ngang cố định

  const StockCard({
    super.key,
    required this.symbol,
    required this.price,
    required this.change,
    required this.volume,
    this.onTap,
    this.width = 140, // có thể tăng chiều ngang để vừa avatar + text
  });

  @override
  Widget build(BuildContext context) {
    final isUp = change >= 0;
    final vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND'); // VND
    return SizedBox(
      width: width,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Avatar + Symbol
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[200],
                      child: Text(symbol[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        symbol,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 🔹 Volume
                Text(
                  "KL: $volume",
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                // 🔹 Price + Change
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        vndFormat.format(price),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      "${change.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: isUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
