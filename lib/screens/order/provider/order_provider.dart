import 'dart:convert';
import '../../../models/order.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/data/data_provider.dart';
import '../../../utility/snack_bar_helper.dart';


class OrderProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final orderFormKey = GlobalKey<FormState>();
  TextEditingController trackingUrlCtrl = TextEditingController();
  String selectedOrderStatus = 'pending';
  Order? orderForUpdate;

  bool isShippingLoading = false;

  OrderProvider(this._dataProvider);

  /// Update an existing order's status and tracking URL
  Future<void> updateOrder() async {
    try {
      if (orderForUpdate == null) return;

      final data = {
        'orderStatus': selectedOrderStatus,
        'trackingUrl': trackingUrlCtrl.text,
      };

      final response = await service.updateItem(
        endpointUrl: 'orders',
        itemId: orderForUpdate!.sId!,
        itemData: data,
      );

      if (response.isOk) {
        SnackBarHelper.showSuccessSnackBar('Order updated successfully');
        _dataProvider.getAllOrders(showSnack: true);
      } else {
        final body = response.body;
        final message = body is Map ? body['message'] : 'Failed to update order';
        SnackBarHelper.showErrorSnackBar(message.toString());
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  /// Delete an order
  Future<void> deleteOrder(Order order) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'orders',
        itemId: order.sId!,
      );

      if (response.isOk) {
        SnackBarHelper.showSuccessSnackBar('Order deleted successfully');
        _dataProvider.getAllOrders(showSnack: false);
      } else {
        SnackBarHelper.showErrorSnackBar('Failed to delete order');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  /// Generate Shiprocket shipment for a paid order
  Future<void> generateShipment(String orderId) async {
    try {
      isShippingLoading = true;
      notifyListeners();

      final response = await service.addItem(
        endpointUrl: 'shipping/generate/$orderId',
        itemData: {},
      );

      if (response.isOk) {
        final body = response.body;
        final message = body is Map ? body['message'] : 'Shipment created';
        SnackBarHelper.showSuccessSnackBar(message.toString());
        _dataProvider.getAllOrders(showSnack: false);
      } else {
        final body = response.body;
        final message = body is Map ? body['message'] : 'Failed to generate shipment';
        SnackBarHelper.showErrorSnackBar(message.toString());
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      isShippingLoading = false;
      notifyListeners();
    }
  }

  updateUI() {
    notifyListeners();
  }
}
