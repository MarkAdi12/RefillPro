// ignore_for_file: unused_local_variable
import 'package:customer_frontend/constants.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderStatus extends StatelessWidget {
  final int status;

  const OrderStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    print('Order status: $status');
    return Center(
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimelineTile("Pending", Icons.hourglass_top, 0),
            _buildTimelineTile(
                status == 2 ? "Redelivering" : "Preparing",
                Icons.kitchen,
                1,
                disableAfterLine: status == 2), // Disable afterLine when reattempting
            _buildTimelineTile("In Transit", Icons.directions_car, 3),
            _buildTimelineTile("Completed", Icons.check_circle, 4,
                isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(String label, IconData icon, int step,
      {bool isLast = false, bool disableAfterLine = false}) {
    return Expanded(
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        alignment: TimelineAlign.center,
        isFirst: step == 0,
        isLast: isLast,
        beforeLineStyle: LineStyle(
          color: status >= step ? kPrimaryColor : Colors.grey,
          thickness: 2,
        ),
        afterLineStyle: LineStyle(
          color: (disableAfterLine || status <= step) ? Colors.grey : kPrimaryColor,
          thickness: 2,
        ),
        indicatorStyle: IndicatorStyle(
          width: 40,
          color: status >= step ? kPrimaryColor : Colors.grey,
          iconStyle: IconStyle(
            iconData: icon,
            color: Colors.white,
          ),
        ),
        endChild: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
