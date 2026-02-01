import 'package:admin/models/user_kyc.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../utility/constants.dart';
import 'provider/kyc_provider.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KycProvider()..getPendingKyc(),
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
              _buildKycList(context),
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
          "KYC Management",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Consumer<KycProvider>(
          builder: (context, provider, _) {
            return IconButton(
              onPressed: () => provider.getPendingKyc(showSnack: true),
              icon: const Icon(Icons.refresh),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<KycProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _buildStatCard(
              context,
              'Pending Review',
              '${provider.totalPending}',
              Icons.hourglass_empty,
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
              child: Icon(icon, color: color, size: 30),
            ),
            const Gap(defaultPadding),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

  Widget _buildKycList(BuildContext context) {
    return Consumer<KycProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.pendingKyc.isEmpty) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "No Pending KYC Applications",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "All KYC applications have been processed",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: provider.pendingKyc.map((kyc) => _buildKycCard(context, kyc, provider)).toList(),
        );
      },
    );
  }

  Widget _buildKycCard(BuildContext context, UserKyc kyc, KycProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Details
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.2),
                child: Text(
                  (kyc.userId?.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kyc.userId?.name ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      kyc.userId?.email ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Phone: ${kyc.userId?.phone ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 30, color: Colors.white24),

          // KYC Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('PAN', kyc.maskedPan),
              ),
              Expanded(
                child: _buildDetailItem('Aadhaar', kyc.maskedAadhaar),
              ),
              Expanded(
                child: _buildDetailItem('Employment', kyc.employmentType ?? 'N/A'),
              ),
              Expanded(
                child: _buildDetailItem('Monthly Income', '₹${kyc.monthlyIncome ?? 0}'),
              ),
            ],
          ),
          const Gap(defaultPadding),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () => _showRejectDialog(context, kyc, provider),
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
              ),
              const Gap(defaultPadding),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _showApproveDialog(context, kyc, provider),
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showApproveDialog(BuildContext context, UserKyc kyc, KycProvider provider) {
    final creditLimitCtrl = TextEditingController(text: '50000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text('Approve KYC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve KYC for ${kyc.userId?.name}?'),
            const Gap(defaultPadding),
            TextField(
              controller: creditLimitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Credit Limit (₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              final limit = double.tryParse(creditLimitCtrl.text) ?? 50000;
              provider.approveKyc(kyc.sId!, limit);
              Navigator.pop(context);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, UserKyc kyc, KycProvider provider) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text('Reject KYC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject KYC for ${kyc.userId?.name}?'),
            const Gap(defaultPadding),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'e.g., Invalid documents',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final reason = reasonCtrl.text.isNotEmpty ? reasonCtrl.text : 'Documents not valid';
              provider.rejectKyc(kyc.sId!, reason);
              Navigator.pop(context);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
