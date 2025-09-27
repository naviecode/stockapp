
import 'package:flutter/material.dart';import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Builder(
        builder: (context) {
          // 1. Nếu đang loading
          if (auth.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Nếu chưa đăng nhập
          if (auth.user == null) {
            return const Center(child: Text("Chưa đăng nhập"));
          }

          // 3. Nếu đã có user
          final user = auth.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.photoUrl!),
                  )
                else
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                const SizedBox(height: 12),
                Text(user.name ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                    title: const Text('Số dư ví ảo'),
                    subtitle: Text(
                      "${user.balance.toStringAsFixed(0)} VND",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle),
                  label: const Text("Nạp 10.000 (demo)"),
                  onPressed: () async {
                    await auth.fs.incrementBalance(user.uid, 10000);
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Đăng xuất"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

