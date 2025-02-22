// ignore_for_file: unused_local_variable
import 'package:customer_frontend/constants.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderStatus extends StatelessWidget {
  final int status;

  const OrderStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 0:
        statusText = "Pending";
        statusColor = kPrimaryColor;
        statusIcon = Icons.hourglass_top;
        break;
      case 1:
        statusText = "Completed";
        statusColor = kPrimaryColor;
        statusIcon = Icons.check_circle;
        break;
      case 2:
        statusText = "In Transit";
        statusColor = Colors.orange;
        statusIcon = Icons.directions_car;
        break;
      default:
        statusText = "Unknown";
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Center(
      child: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.center,
                isFirst: true,
                beforeLineStyle: LineStyle(
                  color: status >= 0 ? statusColor : Colors.grey,
                  thickness: 2,
                ),
                afterLineStyle: LineStyle(
                  color: Colors.grey,
                  thickness: 2,
                ),
                indicatorStyle: IndicatorStyle(
                  width: 40,
                  color: status >= 0 ? statusColor : Colors.grey,
                  iconStyle: IconStyle(
                    iconData: Icons.hourglass_top,
                    color: Colors.white,
                  ),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Pending",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // In Transit (New tile)
            Expanded(
              child: TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.center,
                beforeLineStyle: LineStyle(
                  color: status >= 3 ? statusColor : Colors.grey,
                  thickness: 2,
                ),
                afterLineStyle: LineStyle(
                  color: status > 3 ? statusColor : Colors.grey,
                  thickness: 2,
                ),
                indicatorStyle: IndicatorStyle(
                  width: 40,
                  color: status >= 3 ? statusColor : Colors.grey,
                  iconStyle: IconStyle(
                    iconData: Icons.directions_car, // Icon for "In Transit"
                    color: Colors.white,
                  ),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "In Transit", 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // Completed
            Expanded(
              child: TimelineTile(
                isLast: true,
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.center,
                beforeLineStyle: LineStyle(
                  color: status >= 1 ? statusColor : Colors.grey,
                  thickness: 2,
                ),
                afterLineStyle: LineStyle(
                  color: status > 1 ? statusColor : Colors.grey,
                  thickness: 2,
                ),
                indicatorStyle: IndicatorStyle(
                  width: 40,
                  color: status >= 1 ? statusColor : Colors.grey,
                  iconStyle: IconStyle(
                    iconData: Icons.check_circle,
                    color: Colors.white,
                  ),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Completed",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // Cancelled
          ],
        ),
      ),
    );
  }
}
