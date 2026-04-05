import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import 'provider/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Consumer<SettingsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Platform Settings",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: defaultPadding * 2),
                
                // Reward Settings Card
                _buildCard(
                  title: "Discount & Rewards",
                  children: [
                    _buildField("Referral Reward Percentage (%)", provider.referralRewardCtrl, "E.g. 20"),
                    const SizedBox(height: defaultPadding),
                    _buildField("First Order Discount Percentage (%)", provider.firstOrderRewardCtrl, "E.g. 15"),
                  ],
                ),

                const SizedBox(height: defaultPadding * 2),

                // Delivery & Charges Card
                _buildCard(
                  title: "Delivery & Charges",
                  children: [
                    _buildField("Delivery charge within 1 km (₹)", provider.deliveryWithin1kmCtrl, "E.g. 10"),
                    const SizedBox(height: defaultPadding),
                    _buildField("Delivery charge per km for 2–5 km (₹)", provider.deliveryPerKm2to5Ctrl, "E.g. 9"),
                    const SizedBox(height: defaultPadding),
                    _buildField("Delivery charge over 5 km (₹)", provider.deliveryOver5kmCtrl, "E.g. 29"),
                    const SizedBox(height: defaultPadding),
                    _buildField("Handling charge (₹)", provider.handlingChargeCtrl, "E.g. 5"),
                  ],
                ),

                const SizedBox(height: defaultPadding * 2),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isSubmitting ? null : () {
                      provider.updateSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: provider.isSubmitting
                        ? const SizedBox(
                            height: 20, width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Save Settings"),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: defaultPadding * 1.5),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: bgColor,
            filled: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
