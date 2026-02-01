import 'package:admin/models/emi_plan.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../provider/emi_plan_provider.dart';

void showAddEmiPlanForm(BuildContext context, EmiPlan? planToEdit) {
  final provider = Provider.of<EmiPlanProvider>(context, listen: false);
  provider.setDataForUpdateEmiPlan(planToEdit);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(defaultPadding),
        child: _AddEmiPlanFormContent(planToEdit: planToEdit),
      ),
    ),
  );
}

class _AddEmiPlanFormContent extends StatelessWidget {
  final EmiPlan? planToEdit;

  const _AddEmiPlanFormContent({this.planToEdit});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmiPlanProvider>(
      builder: (context, provider, _) {
        return Form(
          key: provider.addEmiPlanFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    planToEdit != null ? 'Edit EMI Plan' : 'Add EMI Plan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      provider.clearFields();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Gap(defaultPadding),

              // Plan Name
              TextFormField(
                controller: provider.nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Plan Name *',
                  hintText: 'e.g., 3 Month No-Cost EMI',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Plan name is required';
                  }
                  return null;
                },
              ),
              const Gap(defaultPadding),

              // Tenure & Interest Rate
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: provider.tenureCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tenure (Months) *',
                        hintText: '3',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tenure is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: provider.interestRateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Interest Rate (%)',
                        hintText: '0',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(defaultPadding),

              // Processing Fee & Min Amount
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: provider.processingFeeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Processing Fee (₹)',
                        hintText: '0',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Gap(defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: provider.minOrderAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Order Amount (₹)',
                        hintText: '3000',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(defaultPadding),

              // Max Amount
              TextFormField(
                controller: provider.maxOrderAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Order Amount (₹) - Optional',
                  hintText: 'Leave empty for no limit',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(defaultPadding),

              // Active Toggle
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Enable this EMI plan for customers'),
                value: provider.isActive,
                activeColor: primaryColor,
                onChanged: provider.toggleActiveStatus,
              ),
              const Gap(defaultPadding),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (provider.addEmiPlanFormKey.currentState!.validate()) {
                      provider.submitEmiPlan();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    planToEdit != null ? 'Update EMI Plan' : 'Create EMI Plan',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
