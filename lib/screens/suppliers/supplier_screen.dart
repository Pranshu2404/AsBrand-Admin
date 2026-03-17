import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import '../../utility/constants.dart';
import 'provider/supplier_provider.dart';

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierAdminProvider()
        ..fetchSuppliers()
        ..fetchProducts(),
      child: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  indicatorColor: primaryColor,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: 'Suppliers'),
                    Tab(text: 'Supplier Products'),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              Expanded(
                child: TabBarView(
                  children: [
                    _SuppliersTab(),
                    _ProductsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(defaultPadding, defaultPadding, defaultPadding, 0),
      child: Row(
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
                onPressed: () {
                  provider.fetchSuppliers(showSnack: true);
                  provider.fetchProducts(showSnack: true);
                },
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Suppliers Tab ──
class _SuppliersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierAdminProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              // Stats
              Row(
                children: [
                  _statCard(context, 'Total', '${provider.totalCount}', Icons.storefront, primaryColor),
                  const Gap(defaultPadding),
                  _statCard(context, 'Pending', '${provider.pendingCount}', Icons.hourglass_empty, Colors.orange),
                  const Gap(defaultPadding),
                  _statCard(context, 'Approved', '${provider.approvedCount}', Icons.check_circle, Colors.green),
                ],
              ),
              const Gap(defaultPadding),
              // Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  onChanged: provider.filterSuppliers,
                  decoration: const InputDecoration(
                    hintText: 'Search suppliers...', border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                  ),
                ),
              ),
              const Gap(defaultPadding),
              // Table
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.suppliers.isEmpty)
                _emptyState(Icons.storefront_outlined, 'No Suppliers Found')
              else
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      horizontalMargin: 30,
                      columnSpacing: 80,
                      columns: const [
                        DataColumn(label: Text("Store")),
                        DataColumn(label: Text("Owner")),
                        DataColumn(label: Text("Phone")),
                        DataColumn(label: Text("Location")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: provider.suppliers.map((s) {
                        final isPending = !s.isApproved;
                        return DataRow(cells: [
                          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                            CircleAvatar(
                              backgroundColor: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                              radius: 16,
                              child: Icon(Icons.storefront, size: 16, color: isPending ? Colors.orange : Colors.green),
                            ),
                            const Gap(8),
                            Text(s.storeName ?? 'N/A'),
                          ])),
                          DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.name ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text(s.email ?? '', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                          ])),
                          DataCell(Text(s.phone ?? 'N/A')),
                          DataCell(Text([s.city, s.state].where((e) => e != null && e.isNotEmpty).join(', '))),
                          DataCell(_statusBadge(isPending ? 'Pending' : 'Approved', isPending ? Colors.orange : Colors.green)),
                          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                            _actionBtn('View Docs', Colors.blue, () {
                              _showSupplierDetailsDialog(context, s);
                            }),
                            const Gap(8),
                            if (isPending) ...[
                              _actionBtn('Approve', Colors.green, () {
                                _showConfirmDialog(context, 'Approve Supplier', 'Approve ${s.storeName}?', () => provider.approveSupplier(s.id));
                              }),
                              const Gap(8),
                            ],
                            _actionBtn(isPending ? 'Reject' : 'Revoke', Colors.red, () {
                              _showConfirmDialog(context, isPending ? 'Reject Supplier' : 'Revoke Supplier', 'Are you sure you want to ${isPending ? 'reject' : 'revoke'} ${s.storeName}?', () => provider.rejectSupplier(s.id));
                            }),
                          ])),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              const Gap(defaultPadding),
            ],
          ),
        );
      },
    );
  }
}

// ── Products Tab ──
class _ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierAdminProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              // Stats
              Row(
                children: [
                  _statCard(context, 'Total', '${provider.productTotal}', Icons.inventory_2, primaryColor),
                  const Gap(defaultPadding),
                  _statCard(context, 'Pending', '${provider.productPending}', Icons.hourglass_empty, Colors.orange),
                  const Gap(defaultPadding),
                  _statCard(context, 'Approved', '${provider.productApproved}', Icons.check_circle, Colors.green),
                ],
              ),
              const Gap(defaultPadding),
              // Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  onChanged: provider.filterProducts,
                  decoration: const InputDecoration(
                    hintText: 'Search by product name or store...', border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                  ),
                ),
              ),
              const Gap(defaultPadding),
              // Table
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.products.isEmpty)
                _emptyState(Icons.inventory_2_outlined, 'No Supplier Products Found')
              else
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      horizontalMargin: 30,
                      columnSpacing: 80,
                      columns: const [
                        DataColumn(label: Text("Product")),
                        DataColumn(label: Text("Price")),
                        DataColumn(label: Text("Qty")),
                        DataColumn(label: Text("Category")),
                        DataColumn(label: Text("Supplier")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: provider.products.map((p) {
                        final isPending = !p.isApproved;
                        return DataRow(cells: [
                          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                            if (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(p.imageUrl!, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported)),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                            SizedBox(
                              width: 150,
                              child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          ])),
                          DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (p.offerPrice != null) ...[
                              Text('₹${p.offerPrice!.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.white38, decoration: TextDecoration.lineThrough)),
                            ] else
                              Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ])),
                          DataCell(Text('${p.quantity}')),
                          DataCell(Text(p.categoryName ?? 'N/A')),
                          DataCell(Text(p.supplierStoreName ?? 'N/A', style: const TextStyle(fontSize: 12))),
                          DataCell(_statusBadge(isPending ? 'Pending' : 'Approved', isPending ? Colors.orange : Colors.green)),
                          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                            if (isPending) ...[
                              _actionBtn('Approve', Colors.green, () {
                                _showConfirmDialog(context, 'Approve Product', 'Approve ${p.name}?', () => provider.approveProduct(p.id));
                              }),
                              const Gap(8),
                            ],
                            _actionBtn(isPending ? 'Reject' : 'Remove', Colors.red, () {
                              _showConfirmDialog(context, isPending ? 'Reject Product' : 'Remove Product', 'Are you sure you want to ${isPending ? 'reject' : 'remove'} this product?', () => provider.rejectProduct(p.id));
                            }),
                          ])),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              const Gap(defaultPadding),
            ],
          ),
        );
      },
    );
  }
}

// ── Shared helpers ──

Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(defaultPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _statusBadge(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

Widget _actionBtn(String label, Color color, VoidCallback onTap) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      minimumSize: Size.zero,
      textStyle: const TextStyle(fontSize: 12),
    ),
    child: Text(label, style: const TextStyle(color: Colors.white)),
  );
}

Widget _emptyState(IconData icon, String message) {
  return Container(
    height: 200,
    decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)),
    child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ]),
    ),
  );
}

void _showConfirmDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: bgColor,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(content, style: const TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm();
          },
          child: const Text('Confirm', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void _showSupplierDetailsDialog(BuildContext context, SupplierInfo s) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: bgColor,
      title: const Text('Supplier Verification Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow('Store Name', s.storeName ?? 'N/A'),
            _detailRow('Owner Name', s.name ?? 'N/A'),
            _detailRow('Email', s.email ?? 'N/A'),
            _detailRow('Phone', s.phone ?? 'N/A'),

            const Divider(color: Colors.white24, height: 30),
            const Text('Pickup Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (s.fullAddress != null && s.fullAddress!.isNotEmpty)
              _detailRow('Address', s.fullAddress!),
            if (s.city != null && s.city!.isNotEmpty)
              _detailRow('City', s.city!),
            if (s.state != null && s.state!.isNotEmpty)
              _detailRow('State', s.state!),
            if (s.pincode != null && s.pincode!.isNotEmpty)
              _detailRow('Pincode', s.pincode!),

            const Divider(color: Colors.white24, height: 30),
            const Text('Business Registration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (s.gstin != null && s.gstin!.isNotEmpty) ...[
              _detailRow('GSTIN', s.gstin!),
              Row(
                children: [
                  const Text('GST Status: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  _statusBadge(s.gstVerified ? 'Verified ✓' : 'Unverified', s.gstVerified ? Colors.green : Colors.orange),
                ],
              ),
            ] else if (s.udyamRegistration != null && s.udyamRegistration!.isNotEmpty) ...[
              _detailRow('Udyam No.', s.udyamRegistration!),
              Row(
                children: [
                  const Text('Udyam Status: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  _statusBadge(s.udyamVerified ? 'Verified ✓' : 'Unverified', s.udyamVerified ? Colors.green : Colors.orange),
                ],
              ),
            ] else ...[
              const Text('No GSTIN or Udyam provided.', style: TextStyle(color: Colors.redAccent)),
            ],

            if (s.bankDetails != null && s.bankDetails!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              const Text('Bank Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if ((s.bankDetails!['accountName'] ?? '').toString().isNotEmpty)
                _detailRow('Beneficiary', s.bankDetails!['accountName'].toString()),
              if ((s.bankDetails!['accountNumber'] ?? '').toString().isNotEmpty)
                _detailRow('Account No.', s.bankDetails!['accountNumber'].toString()),
              if ((s.bankDetails!['bankName'] ?? '').toString().isNotEmpty)
                _detailRow('Bank Name', s.bankDetails!['bankName'].toString()),
              if ((s.bankDetails!['ifscCode'] ?? '').toString().isNotEmpty)
                _detailRow('IFSC Code', s.bankDetails!['ifscCode'].toString()),
            ],

            if (s.verificationData != null && s.verificationData!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              const Text('Verification Source Details (RapidAPI)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: s.verificationData!.entries.map((entry) {
                    final key = entry.key.replaceAll('_', ' ').toUpperCase();
                    final value = entry.value?.toString() ?? 'N/A';
                    if (entry.value is Map || entry.value is List) {
                       return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text('$key:', style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        Expanded(
          child: Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );
}
