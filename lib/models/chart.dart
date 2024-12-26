class Chart {
  ChartData? chartData;
  Total? total;

  Chart({
    this.chartData,
    this.total,
  });

  Chart copyWith({
    ChartData? chartData,
    Total? total,
  }) {
    return Chart(
      chartData: chartData ?? this.chartData,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chartData': chartData,
      'total': total,
    };
  }

  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(
      chartData: json['chartData'] == null
          ? null
          : ChartData.fromJson(json['chartData'] as Map<String, dynamic>),
      total: json['total'] == null
          ? null
          : Total.fromJson(json['total'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() => "Chart(chartData: $chartData,total: $total)";

  @override
  int get hashCode => Object.hash(chartData, total);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chart &&
          runtimeType == other.runtimeType &&
          chartData == other.chartData &&
          total == other.total;
}

class ChartData {
  List<String>? labels;
  List<int>? revenue;
  List<int>? tickets;
  List<int>? cancelledTickets;
  List<int>? users;

  ChartData({
    this.labels,
    this.revenue,
    this.tickets,
    this.cancelledTickets,
    this.users,
  });

  ChartData copyWith({
    List<String>? labels,
    List<int>? revenue,
    List<int>? tickets,
    List<int>? cancelledTickets,
    List<int>? users,
  }) {
    return ChartData(
      labels: labels ?? this.labels,
      revenue: revenue ?? this.revenue,
      tickets: tickets ?? this.tickets,
      cancelledTickets: cancelledTickets ?? this.cancelledTickets,
      users: users ?? this.users,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labels': labels,
      'revenue': revenue,
      'tickets': tickets,
      'cancelledTickets': cancelledTickets,
      'users': users,
    };
  }

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      labels:
          (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList(),
      revenue:
          (json['revenue'] as List<dynamic>?)?.map((e) => e as int).toList(),
      tickets:
          (json['tickets'] as List<dynamic>?)?.map((e) => e as int).toList(),
      cancelledTickets: (json['cancelledTickets'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      users: (json['users'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  @override
  String toString() =>
      "ChartData(labels: $labels,revenue: $revenue,tickets: $tickets,cancelledTickets: $cancelledTickets,users: $users)";

  @override
  int get hashCode =>
      Object.hash(labels, revenue, tickets, cancelledTickets, users);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartData &&
          runtimeType == other.runtimeType &&
          labels == other.labels &&
          revenue == other.revenue &&
          tickets == other.tickets &&
          cancelledTickets == other.cancelledTickets &&
          users == other.users;
}

class Total {
  int? totalRevenue;
  int? totalTickets;
  int? totalCancelledTickets;
  int? totalUsers;

  Total({
    this.totalRevenue,
    this.totalTickets,
    this.totalCancelledTickets,
    this.totalUsers,
  });

  Total copyWith({
    int? totalRevenue,
    int? totalTickets,
    int? totalCancelledTickets,
    int? totalUsers,
  }) {
    return Total(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalTickets: totalTickets ?? this.totalTickets,
      totalCancelledTickets:
          totalCancelledTickets ?? this.totalCancelledTickets,
      totalUsers: totalUsers ?? this.totalUsers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalTickets': totalTickets,
      'totalCancelledTickets': totalCancelledTickets,
      'totalUsers': totalUsers,
    };
  }

  factory Total.fromJson(Map<String, dynamic> json) {
    return Total(
      totalRevenue: json['totalRevenue'] as int?,
      totalTickets: json['totalTickets'] as int?,
      totalCancelledTickets: json['totalCancelledTickets'] as int?,
      totalUsers: json['totalUsers'] as int?,
    );
  }

  @override
  String toString() =>
      "Total(totalRevenue: $totalRevenue,totalTickets: $totalTickets,totalCancelledTickets: $totalCancelledTickets,totalUsers: $totalUsers)";

  @override
  int get hashCode => Object.hash(
      totalRevenue, totalTickets, totalCancelledTickets, totalUsers);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Total &&
          runtimeType == other.runtimeType &&
          totalRevenue == other.totalRevenue &&
          totalTickets == other.totalTickets &&
          totalCancelledTickets == other.totalCancelledTickets &&
          totalUsers == other.totalUsers;
}
