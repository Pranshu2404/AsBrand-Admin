import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utility/constants.dart';
import 'components/add_emi_plan_form.dart';
import 'components/emi_plan_list_section.dart';
import 'provider/emi_plan_provider.dart';
import 'package:provider/provider.dart';

class EmiPlansScreen extends StatelessWidget {
  const EmiPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmiPlanProvider()..getAllEmiPlans(),
      child: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildActionsRow(context),
                        const Gap(defaultPadding),
                        const EmiPlanListSection(),
                      ],
                    ),
                  ),
                ],
              )
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
          "EMI Plans Management",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.credit_card, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                "BNPL Configuration",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Consumer<EmiPlanProvider>(
      builder: (context, provider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                "Manage EMI Tenures & Interest Rates",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical: defaultPadding,
                ),
                backgroundColor: primaryColor,
              ),
              onPressed: () {
                showAddEmiPlanForm(context, null);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add EMI Plan"),
            ),
            const Gap(20),
            IconButton(
              onPressed: () {
                provider.getAllEmiPlans(showSnack: true);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        );
      },
    );
  }
}
