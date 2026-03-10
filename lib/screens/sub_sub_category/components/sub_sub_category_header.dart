import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/data/data_provider.dart';
import '../../../utility/constants.dart';

class SubSubCategoryHeader extends StatelessWidget {
  const SubSubCategoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Sub SubCategories",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Spacer(flex: 1),
        Expanded(
          child: TextField(
            onChanged: (value) {
              context.read<DataProvider>().filterSubSubCategories(value);
            },
            decoration: InputDecoration(
              hintText: "Search",
              fillColor: secondaryColor,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              suffixIcon: InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(defaultPadding * 0.75),
                  margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
