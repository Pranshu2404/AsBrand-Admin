import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../utility/constants.dart';
import 'provider/supplier_provider.dart';

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierAdminProvider()..fetchSuppliers(),
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
              _buildSuppliersList(context),
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
          "Supplier Management",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Consumer<SupplierAdminProvider>(
          builder: (context, provider, _) {
            return IconButton(
              onPressed: () => provider.fetchSuppliers(showSnack: true),
              icon: const Icon(Icons.refresh),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<SupplierAdminProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _buildStatCard(context, 'Total', '${provider.totalCount}',
                Icons.storefront, primaryColor),
            const Gap(defaultPadding),
            _buildStatCard(context, 'Pending', '${provider.pendingCount}',
                Icons.hourglass_empty, Colors.orange),
            const Gap(defaultPadding),
            _buildStatCard(context, 'Approved', '${provider.approvedCount}',
                Icons.check_circle, Colors.green),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
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
                Text(title,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
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
    return Consumer<SupplierAdminProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            onChanged: provider.filterSuppliers,
            decoration: const InputDecoration(
              hintText: 'Search by name, store, email, phone...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white54),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuppliersList(BuildContext context) {
    return Consumer<SupplierAdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.suppliers.isEmpty) {
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
                  Icon(Icons.storefront_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No Suppliers Found",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: const [
                DataColumn(label: Text("Store Name")),
                DataColumn(label: Text("Owner")),
                DataColumn(label: Text("Phone")),
                DataColumn(label: Text("Location")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Actions")),
              ],
              rows: provider.suppliers
                  .map((s) => _buildDataRow(s, provider))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(SupplierInfo supplier, SupplierAdminProvider provider) {
    final isPending = !supplier.isApproved;

    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: isPending
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                radius: 16,
                child: Icon(Icons.storefront,
                    size: 16,
                    color: isPending ? Colors.orange : Colors.green),
              ),
              const Gap(8),
              Text(supplier.storeName ?? 'N/A'),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(supplier.name ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(supplier.email ?? '',
                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          ),
        ),
        DataCell(Text(supplier.phone ?? 'N/A')),
        DataCell(Text(
          [supplier.city, supplier.state]
              .where((e) => e != null && e.isNotEmpty)
              .join(', '),
        )),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPending
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isPending ? 'Pending' : 'Approved',
              style: TextStyle(
                color: isPending ? Colors.orange : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          isPending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => provider.approveSupplier(supplier.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Approve',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const Gap(8),
                    ElevatedButton(
                      onPressed: () => provider.rejectSupplier(supplier.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              : const Text('✓ Active',
                  style: TextStyle(color: Colors.green, fontSize: 12)),
        ),
      ],
    );
  }
}
