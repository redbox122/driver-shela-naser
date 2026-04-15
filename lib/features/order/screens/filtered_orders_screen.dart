import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:shellafood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:shellafood_delivery/features/order/controllers/order_controller.dart';
import 'package:shellafood_delivery/features/order/domain/models/order_model.dart';
import 'package:shellafood_delivery/features/order/widgets/history_order_widget.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:shellafood_delivery/util/app_colors.dart';

/// Screen for displaying orders filtered by date range
/// Supports today, this week, and all time filters
class FilteredOrdersScreen extends StatefulWidget {
  final String filterType; // 'today', 'week', 'all'
  final String title;

  const FilteredOrdersScreen({
    super.key,
    required this.filterType,
    required this.title,
  });

  @override
  State<FilteredOrdersScreen> createState() => _FilteredOrdersScreenState();
}

class _FilteredOrdersScreenState extends State<FilteredOrdersScreen> {
  late List<OrderModel> _filteredOrders;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilteredOrders();
  }

  Future<void> _loadFilteredOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderController = Get.find<OrderController>();

      // Ensure we have completed orders loaded
      if (orderController.completedOrderList == null) {
        await orderController.getCompletedOrders(1);
      }

      // Apply filter based on type
      switch (widget.filterType) {
        case 'today':
          _filteredOrders = orderController.getTodaysOrders();
          break;
        case 'week':
          _filteredOrders = orderController.getThisWeekOrders();
          break;
        case 'all':
          _filteredOrders = orderController.completedOrderList ?? [];
          break;
        default:
          _filteredOrders = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading filtered orders: $e');
      showCustomSnackBar('error_loading_orders'.tr);
      setState(() {
        _isLoading = false;
        _filteredOrders = [];
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadFilteredOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.background,
      appBar: CustomAppBarWidget(
        title: '${widget.title} (${_filteredOrders.length})',
        isBackButtonExist: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredOrders.isEmpty
                ? _buildEmptyState()
                : _buildOrdersList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage;
    IconData emptyIcon;

    switch (widget.filterType) {
      case 'today':
        emptyMessage = 'no_orders_for_today'.tr;
        emptyIcon = Icons.today;
        break;
      case 'week':
        emptyMessage = 'no_orders_this_week'.tr;
        emptyIcon = Icons.date_range;
        break;
      default:
        emptyMessage = 'no_orders_found'.tr;
        emptyIcon = Icons.inbox;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyIcon,
                size: 80,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              emptyMessage,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'pull_to_refresh'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        return HistoryOrderWidget(
          orderModel: _filteredOrders[index],
          isRunning: false,
          index: index,
        );
      },
    );
  }
}
