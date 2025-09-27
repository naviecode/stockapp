import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final f = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green[300],
      ),
      body: Builder(
        builder: (context) {
          if (auth.loading || portfolioProvider.loading || transactionProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auth.user == null) {
            return const Center(child: Text("Chưa đăng nhập"));
          }

          final user = auth.user!;
          final portfolio = portfolioProvider.portfolio;
          final transactions = transactionProvider.transactions;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );

                    if (pickedFile != null) {
                      final File imageFile = File(pickedFile.path);

                      final dir = await getApplicationDocumentsDirectory();
                      final fileName = path.basename(pickedFile.path);
                      final localFile = await imageFile.copy('${dir.path}/$fileName');

                      await auth.updatePhotoUrl(localFile.path);
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? FileImage(File(user.photoUrl!)) // load từ local file
                        : null,
                    child: user.photoUrl == null || user.photoUrl!.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                 // userName + nút update
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.name ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController(text: user.name);
                            return AlertDialog(
                              title: const Text('Cập nhật tên hiển thị'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Nhập tên mới',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, controller.text),
                                  child: const Text('Cập nhật'),
                                ),
                              ],
                            );
                          },
                        );

                        if (newName != null && newName.isNotEmpty) {
                          await auth.updateName(newName);
                        }
                      },
                    ),
                  ],
                ),

                Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Text(
                  'Ngày tạo: ${user.createdAt != null ? DateFormat('dd/MM/yyyy').format(user.createdAt!) : '-'}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                    title: const Text('Số dư ví ảo'),
                    subtitle: Text("${f.format(user.balance)} VND",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.pie_chart, color: Colors.blue),
                    title: const Text('Tổng giá trị danh mục'),
                    subtitle: Text(
                      portfolio != null
                          ? "${f.format(portfolio.totalValue)} VND"
                          : "-",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.show_chart, color: Colors.orange),
                    title: const Text('Số lượng giao dịch đã thực hiện'),
                    subtitle: Text(
                      transactions != null ? "${transactions.length}" : "0",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.layers, color: Colors.purple),
                    title: const Text('Số loại cổ phiếu đang nắm giữ'),
                    subtitle: Text(
                      portfolio != null ? "${portfolio.stocks.length}" : "0",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Đăng xuất"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(horizontal: 16.0)
                  ),
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
