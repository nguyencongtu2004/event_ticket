import 'dart:math';

import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/models/chart.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/requests/report_request.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ReportEventScreen extends StatefulWidget {
  final Event event;

  const ReportEventScreen({super.key, required this.event});

  @override
  createState() => _ReportEventScreenState();
}

class _ReportEventScreenState extends State<ReportEventScreen> {
  Chart? _chartData;
  DateTime? _startDate;
  DateTime? _endDate;
  ChartIntervals? _selectedInterval;
  final _reportRequest = ReportRequest();

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    try {
      final response = await _reportRequest.getRevenueChartByEventId(
        widget.event.id,
        startDate: _startDate,
        endDate: _endDate,
        interval: _selectedInterval,
      );
      // Chỉ cập nhật dữ liệu khi fetch thành công
      final newChartData = Chart.fromJson(response.data);
      setState(() => _chartData = newChartData);
    } catch (e) {
      context.showAnimatedToast('Failed to fetch report data: $e');
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Event Report',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // header của sự kiện
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventHeader(),
              const SizedBox(height: 16),
              _buildEventStats(),
              const SizedBox(height: 16),
            ],
          ),

          // Phần biểu đồ và báo cáo chi tiết
          if (_chartData == null)
            SizedBox(
              height: 200,
              child: const CircularProgressIndicator().centered(),
            )
          else ...[
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chọn khoàng ngày
                'Date Range'.text.titleMedium(context).make(),
                Row(children: [
                  ChoiceChip(
                    label: Text(_startDate != null && _endDate != null
                        ? '${'${_startDate!.toLocal()}'.split(' ')[0]} - ${'${_endDate!.toLocal()}'.split(' ')[0]}'
                        : 'Select Date'),
                    selected: _startDate != null && _endDate != null,
                    onSelected: (_) => _selectDateRange(),
                  ).px(4),
                ]).scrollHorizontal(),

                // Chọn khoàng thời gian
                'Interval'.text.titleMedium(context).make(),
                Row(
                  children: ChartIntervals.values.map((interval) {
                    return ChoiceChip(
                      label: Text(interval.toString().split('.').last),
                      selected: _selectedInterval == interval,
                      onSelected: (_) {
                        setState(() => _selectedInterval = interval);
                        _fetchReportData();
                      },
                    ).px(4);
                  }).toList(),
                ).scrollHorizontal(),
              ],
            ).p(8),

            // Phần tổng quan
            _buildTotalSummary(),

            // Các biểu đồ
            const SizedBox(height: 20),
            _buildChartSection(
              'Revenue',
              _chartData?.chartData?.revenue ?? [],
              Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildChartSection(
              'Tickets',
              _chartData?.chartData?.tickets ?? [],
              Colors.green,
            ),
            const SizedBox(height: 20),
            _buildChartSection(
              'Cancelled Tickets',
              _chartData?.chartData?.cancelledTickets ?? [],
              Colors.red,
            ),
            const SizedBox(height: 20),
            _buildChartSection(
              'Users',
              _chartData?.chartData?.users ?? [],
              Colors.purple,
            ),
            const SizedBox(height: 80),
          ],
        ],
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          widget.event.images.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.event.images.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.event, size: 40),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name ?? 'Unnamed Event',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.event.location ?? 'Location not specified',
                        style: context.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.event.date != null
                          ? widget.event.date!
                              .toLocal()
                              .toString()
                              .split(' ')[0]
                          : 'Date not specified',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Statistics',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.people,
                label: 'Attendees',
                value:
                    '${widget.event.attendees.length}/${widget.event.maxAttendees ?? 0}',
              ),
              _buildStatItem(
                icon: Icons.monetization_on,
                label: 'Tickets Sold',
                value: '${widget.event.ticketsSold ?? 0}',
              ),
              _buildStatItem(
                icon: Icons.category,
                label: 'Category',
                value: widget.event.category.isNotEmpty
                    ? widget.event.category.map((c) => c.name).join(', ')
                    : 'No Category',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: context.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Phần dưới cho biểu đồ

  Widget _buildTotalSummary() {
    final total = _chartData?.total;
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'Total Summary'.text.titleLarge(context).make(),
          10.heightBox,
          _buildSummaryRow('Total Revenue', total?.totalRevenue ?? 0),
          _buildSummaryRow('Total Tickets', total?.totalTickets ?? 0),
          _buildSummaryRow(
              'Cancelled Tickets', total?.totalCancelledTickets ?? 0),
          _buildSummaryRow('Total Users', total?.totalUsers ?? 0),
        ],
      ).p(16),
    );
  }

  Widget _buildChartSection(String title, List<int> data, Color color) {
    double calculateSafeInterval(List<int> data) {
      if (data.isEmpty) return 1.0;

      final maxValue = data.reduce((a, b) => a > b ? a : b);
      if (maxValue == 0) return 1.0;

      final interval = maxValue / 5;
      return interval > 0 ? interval : 1.0;
    }

    return Card(
      elevation: 4,
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title.text.titleLarge(context).make(),
          SizedBox(
            width: max(MediaQuery.of(context).size.width, data.length * 50.0),
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >=
                                (_chartData?.chartData?.labels?.length ?? 0)) {
                          return const Text('');
                        }
                        return SizedBox(
                          height: 90, // Tăng chiều cao
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Center(
                              child: Text(
                                _chartData!.chartData!.labels![index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        );
                      },
                      interval: 1,
                      reservedSize: 70, // Tăng kích thước dự trữ
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: calculateSafeInterval(data),
                      reservedSize: 50, // Tăng khoảng trống để hiển thị số
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.2),
                    ),
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                  ),
                ],
                minY: 0,
                maxY: (data.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(),
              ),
            ),
          ).scrollHorizontal(),
        ],
      ).p(16),
    );
  }

  Widget _buildSummaryRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.text.bodyLarge(context).make(),
        if (label == 'Total Revenue')
          value.toDouble().toCurrency().text.bold.bodyLarge(context).make()
        else
          value.toString().text.bold.bodyLarge(context).make(),
      ],
    ).py(4);
  }
}
