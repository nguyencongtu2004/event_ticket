import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/service/http_service.dart';

class ReportRequest extends HttpService {
  Future<Response> getTotalRevenueChart(
      {DateTime? startDate,
      DateTime? endDate,
      ChartIntervals? interval}) async {
    final response = await get(url: Api.getTotalRevenueChart, queryParameters: {
      if (startDate != null && endDate != null)
        'start_date': startDate.toIso8601String(),
      if (startDate != null && endDate != null)
        'end_date': endDate.toIso8601String(),
      if (interval != null) 'interval': interval.value,
    });
    return response;
  }

  Future<Response> getRevenueChartByEventId(String eventId,
      {DateTime? startDate,
      DateTime? endDate,
      ChartIntervals? interval}) async {
    final response =
        await get(url: Api.getRevenueChartByEventId(eventId), queryParameters: {
      if (startDate != null && endDate != null)
        'start_date': startDate.toIso8601String(),
      if (startDate != null && endDate != null)
        'end_date': endDate.toIso8601String(),
      if (interval != null) 'interval': interval.value,
    });
    return response;
  }
}
