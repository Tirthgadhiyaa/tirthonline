// lib/screens/user_panel/dashboard/widgets/activity_timeline_widget.dart

import 'package:flutter/material.dart';
import 'package:jewellery_diamond/models/activity_model.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ActivityTimelineWidget extends StatelessWidget {
  final List<ActivityModel> activities;
  final bool isLoading;

  const ActivityTimelineWidget({
    Key? key,
    required this.activities,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (activities.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // Navigate to activity history
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (activities.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent activity',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildTimelineTile(
                  context,
                  activity,
                  isFirst: index == 0,
                  isLast: index == activities.length - 1,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    ActivityModel activity, {
    required bool isFirst,
    required bool isLast,
  }) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'order':
        icon = Icons.shopping_bag;
        color = Colors.green;
        break;
      case 'wishlist':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'cart':
        icon = Icons.shopping_cart;
        color = Colors.blue;
        break;
      case 'view':
        icon = Icons.visibility;
        color = Colors.purple;
        break;
      case 'hold':
        icon = Icons.pause_circle_filled;
        color = Colors.orange;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 30,
        height: 30,
        indicator: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
      ),
      beforeLineStyle: LineStyle(
        color: Colors.grey.shade300,
      ),
      afterLineStyle: LineStyle(
        color: Colors.grey.shade300,
      ),
      endChild: Container(
        constraints: const BoxConstraints(
          minHeight: 80,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, y • h:mm a').format(
                DateTime.parse(activity.timestamp),
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
