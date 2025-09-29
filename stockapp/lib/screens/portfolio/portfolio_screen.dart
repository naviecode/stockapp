import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/providers/auth_provider.dart';
import '../../providers/portfolio_provider.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _searchText = "";
  String _filterType = "Tất cả";

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid;
    context.read<PortfolioProvider>().listenPortfolio(userId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    final theme = Theme.of(context);

    if (provider.loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    final portfolio = provider.portfolio;

    // Apply filter
    final stocks = (portfolio?.stocks ?? []).where((item) {
      final matchSearch =
          item.stockId.toLowerCase().contains(_searchText.toLowerCase());
      bool matchFilter = true;
      if (_filterType == "SL > 100") {
        matchFilter = item.quantity > 100;
      } else if (_filterType == "Giá > 1tr") {
        matchFilter = item.avgPrice > 1000000;
      }
      return matchSearch && matchFilter;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Portfolio",
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Tìm theo mã coin...",
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor),
                      prefixIcon:
                          Icon(Icons.search, color: theme.hintColor),
                      filled: true,
                      fillColor: theme.cardColor.withOpacity(0.9),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchText = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  dropdownColor: theme.cardColor,
                  value: _filterType,
                  style: theme.textTheme.bodyMedium,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: "Tất cả", child: Text("Tất cả")),
                    DropdownMenuItem(value: "SL > 100", child: Text("SL > 100")),
                    DropdownMenuItem(value: "Giá > 1tr", child: Text("Giá > 1tr")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _filterType = value);
                    }
                  },
                ),
              ],
            ),
          ),

          // Danh sách
          Expanded(
            child: (stocks.isEmpty)
                ? Center(
                    child: Text(
                      "Không tìm thấy coin phù hợp",
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: stocks.length,
                    itemBuilder: (context, index) {
                      final item = stocks[index];
                      final stockPrice = item.avgPrice;

                      return Card(
                        color: theme.cardColor,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.dividerColor),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            child: Image.asset(
                              item.localLogoPath ,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  item.stockId[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            item.stockId,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Số lượng: ${item.quantity}",
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Text(
                            "Giá trung bình mua: ${vndFormat.format(stockPrice)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
