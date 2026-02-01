import 'package:admin/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../utility/constants.dart';
import 'provider/users_provider.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersProvider()..getAllUsers(),
      child: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: defaultPadding),
              _buildStatsRow(context),
              const Gap(defaultPadding),
              _buildSearchBar(context),
              const Gap(defaultPadding),
              _buildUsersList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          "Users Management",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Consumer<UsersProvider>(
          builder: (context, provider, _) {
            return IconButton(
              onPressed: () => provider.getAllUsers(showSnack: true),
              icon: const Icon(Icons.refresh),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _buildStatCard(
              context,
              'Total Users',
              '${provider.totalUsers}',
              Icons.people,
              primaryColor,
            ),
            const Gap(defaultPadding),
            _buildStatCard(
              context,
              'Customers',
              '${provider.customerCount}',
              Icons.person,
              Colors.blue,
            ),
            const Gap(defaultPadding),
            _buildStatCard(
              context,
              'Admins',
              '${provider.adminCount}',
              Icons.admin_panel_settings,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Gap(defaultPadding),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            onChanged: provider.filterUsers,
            decoration: const InputDecoration(
              hintText: 'Search by name, email, or phone...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white54),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.users.isEmpty) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Users Found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DataTable(
            columnSpacing: defaultPadding,
            columns: const [
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Email")),
              DataColumn(label: Text("Phone")),
              DataColumn(label: Text("Role")),
              DataColumn(label: Text("Joined")),
            ],
            rows: provider.users.map((user) => _buildDataRow(user)).toList(),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(AppUser user) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.2),
                radius: 16,
                child: Text(
                  (user.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(8),
              Text(user.name ?? 'N/A'),
            ],
          ),
        ),
        DataCell(Text(user.email ?? 'N/A')),
        DataCell(Text(user.phone ?? 'N/A')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.isAdmin
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              user.isAdmin ? 'Admin' : 'Customer',
              style: TextStyle(
                color: user.isAdmin ? Colors.orange : Colors.blue,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(_formatDate(user.createdAt))),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
