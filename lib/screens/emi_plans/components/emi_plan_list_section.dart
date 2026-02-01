import 'package:admin/models/emi_plan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../provider/emi_plan_provider.dart';
import 'add_emi_plan_form.dart';

class EmiPlanListSection extends StatelessWidget {
  const EmiPlanListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EmiPlanProvider>(
      builder: (context, provider, _) {
        final plans = provider.emiPlans;

        if (plans.isEmpty) {
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
                  Icon(Icons.credit_card_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No EMI Plans Found",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add your first EMI plan to enable BNPL",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
              DataColumn(label: Text("Plan Name")),
              DataColumn(label: Text("Tenure")),
              DataColumn(label: Text("Interest")),
              DataColumn(label: Text("Processing Fee")),
              DataColumn(label: Text("Min Amount")),
              DataColumn(label: Text("Status")),
              DataColumn(label: Text("Actions")),
            ],
            rows: plans.map((plan) => _buildDataRow(context, plan, provider)).toList(),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(BuildContext context, EmiPlan plan, EmiPlanProvider provider) {
    return DataRow(
      cells: [
        DataCell(Text(plan.name ?? 'N/A')),
        DataCell(Text('${plan.tenure ?? 0} months')),
        DataCell(Text('${plan.interestRate ?? 0}%')),
        DataCell(Text('₹${plan.processingFee ?? 0}')),
        DataCell(Text('₹${plan.minOrderAmount ?? 0}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: plan.isActive == true
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              plan.isActive == true ? 'Active' : 'Inactive',
              style: TextStyle(
                color: plan.isActive == true ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () {
                  showAddEmiPlanForm(context, plan);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  _showDeleteConfirmation(context, plan, provider);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, EmiPlan plan, EmiPlanProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text('Delete EMI Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteEmiPlan(plan);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
