import '../../../core/data/data_provider.dart';
import 'view_order_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../models/order.dart';
import '../../../utility/constants.dart';
import '../provider/order_provider.dart';


class OrderListSection extends StatelessWidget {
  const OrderListSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All Order",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                return DataTable(
                  columnSpacing: defaultPadding,
                  // minWidth: 600,
                  columns: [
                    DataColumn(
                      label: Text("Customer Name"),
                    ),
                    DataColumn(
                      label: Text("Amount"),
                    ),
                    DataColumn(
                      label: Text("Payment"),
                    ),
                    DataColumn(
                      label: Text("Order Status"),
                    ),
                    DataColumn(
                      label: Text("Delivery"),
                    ),
                    DataColumn(
                      label: Text("Date"),
                    ),
                    DataColumn(
                      label: Text("Edit"),
                    ),
                    DataColumn(
                      label: Text("Delete"),
                    ),
                  ],
                  rows: List.generate(
                    dataProvider.orders.length,
                    (index) => orderDataRow(dataProvider.orders[index],index+1, delete: () {
                      Provider.of<OrderProvider>(context, listen: false).deleteOrder(dataProvider.orders[index]);
                    }, edit: () {
                      showOrderForm(context, dataProvider.orders[index]);
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow orderDataRow(Order orderInfo, int index, {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
              child: Text(index.toString(), textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(orderInfo.userID?.name ?? ''),
            ),
          ],
        ),
      ),
      DataCell(Text('₹${orderInfo.orderTotal?.total ?? 0}')),
      DataCell(Text(orderInfo.paymentMethod ?? '')),
      DataCell(Text(orderInfo.orderStatus ?? '')),
      DataCell(_buildDeliveryChip(orderInfo.deliveryStatus)),
      DataCell(Text(orderInfo.orderDate ?? '')),
      DataCell(IconButton(
          onPressed: () {
            if (edit != null) edit();
          },
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ))),
      DataCell(IconButton(
          onPressed: () {
            if (delete != null) delete();
          },
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ))),
    ],
  );
}

Widget _buildDeliveryChip(String? status) {
  Color color;
  switch (status) {
    case 'PENDING': color = Colors.grey; break;
    case 'CREATED': color = Colors.blue; break;
    case 'SHIPPED': color = Colors.indigo; break;
    case 'IN_TRANSIT': color = Colors.orange; break;
    case 'OUT_FOR_DELIVERY': color = Colors.amber; break;
    case 'DELIVERED': color = Colors.green; break;
    default: color = Colors.grey;
  }
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color, width: 1),
    ),
    child: Text(
      status ?? 'N/A',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}
