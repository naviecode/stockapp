import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/providers/auth_provider.dart';
import 'package:stockapp/providers/portfolio_provider.dart';
import 'package:stockapp/providers/stock_provider.dart';
import 'package:intl/intl.dart';
import '../stock/StockDetailPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  String _searchText = "";


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    // final portfolioProvider = Provider.of<PortfolioProvider>(context);
    // final auth = Provider.of<AuthProvider>(context);
    final vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

    // final balance = auth.user?.balance ?? 0;
    // final totalPortfolio =
    //     portfolioProvider.calculateTotalValueRealtime(stockProvider.stocks);
    // final totalAssets = balance + totalPortfolio;

    stockProvider.listenStocks();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          "📊 Home",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance + Assets
          Consumer2<AuthProvider, PortfolioProvider>(
            builder: (context, auth, portfolio, _) {
                final stockProvider = Provider.of<StockProvider>(context);
                final balance = auth.user?.balance ?? 0;
                final totalPortfolio = portfolio.calculateTotalValueRealtime(stockProvider.stocks);
                final totalAssets = balance + totalPortfolio;

                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBox(theme, "Số dư ví 💰",
                          auth.user != null ? vndFormat.format(balance) : "Đang tải"),
                      _infoBox(theme, "Tài sản 📈", vndFormat.format(totalAssets)),
                    ],
                  ),
                );
              },
            ),
          // Filter + AI Suggest
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
                  tooltip: "Làm mới bộ lọc",
                  onPressed: () {
                    setState(() {
                      _searchText = "";
                    });
                    stockProvider.setFilter(StockListFilter.all);
                    stockProvider.searchStock(""); // reset kết quả search
                  },
                ),
                const SizedBox(width: 8),

                Expanded(
                  flex: 2,
                  child: Consumer<StockProvider>(
                    builder: (context, sp, _) {
                      return DropdownButtonFormField<StockListFilter>(
                        value: sp.currentFilter,
                        dropdownColor: theme.colorScheme.surfaceVariant,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        icon: Icon(Icons.arrow_drop_down,
                            color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        items: const [
                          DropdownMenuItem(
                              value: StockListFilter.all, child: Text("All")),
                          DropdownMenuItem(
                              value: StockListFilter.topGainers,
                              child: Text("Top Gainers")),
                          DropdownMenuItem(
                              value: StockListFilter.topLosers,
                              child: Text("Top Losers")),
                          DropdownMenuItem(
                              value: StockListFilter.topVolume,
                              child: Text("Top Volume")),
                        ],
                        onChanged: (filter) {
                          if (filter != null) sp.setFilter(filter);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "AI Gợi ý: tính năng đang phát triển",
                            style: TextStyle(color: theme.colorScheme.onPrimary),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("AI Gợi ý"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text("Currency",
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Market Cap /24h",
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Price /24h",
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Divider(color: theme.dividerColor, height: 1),

          // Stock List
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, sp, _) {
                final stocks = sp.filteredStockList;
                if (stocks.isEmpty) {
                  return Center(
                    child: Text("Chưa có dữ liệu coin",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5))),
                  );
                }

                return ListView.separated(
                  itemCount: stocks.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: theme.dividerColor, height: 1),
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    final isNegative = stock.changePercent < 0;
                    final changeColor = isNegative
                        ? Colors.redAccent
                        : Colors.greenAccent;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StockDetailPage(stockId: stock.id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            // 🔹 Currency (STT + Image + Name)
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Text(
                                    "#${index + 1}",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                      radius: 14,
                                      backgroundColor: theme.colorScheme.surfaceVariant,
                                      child: stock.localLogoPath.isNotEmpty
                                          ? ClipOval(
                                              child: Image.asset(
                                                stock.localLogoPath,
                                                fit: BoxFit.cover,
                                                width: 28,
                                                height: 28,
                                              ),
                                            )
                                          : Icon(
                                              Icons.business,
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              size: 16,
                                            ),
                                    ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${stock.name}",
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Market Cap (volume)
                            Expanded(
                              flex: 3,
                              child: Text(
                                NumberFormat.compact().format(stock.volume),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),

                            // Price + Change %
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    vndFormat.format(stock.price),
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${stock.changePercent.toStringAsFixed(2)}%",
                                    style: TextStyle(
                                      color: changeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            )),
        const SizedBox(height: 6),
        Text(value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    final theme = Theme.of(context);
    String keyword = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceVariant,
          title: Text("Tìm coin",
              style: TextStyle(color: theme.colorScheme.onSurface)),
          content: TextField(
            autofocus: true,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Nhập tên hoặc ký hiệu coin",
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            onChanged: (value) => keyword = value,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Hủy",
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7)))),
            TextButton(
              onPressed: () {
                Provider.of<StockProvider>(context, listen: false)
                    .searchStock(keyword);
                Navigator.pop(context);
              },
              child: Text("Tìm",
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }
}
