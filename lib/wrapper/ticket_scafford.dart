import 'package:flutter/material.dart';

class TicketScaffold extends StatelessWidget {
  const TicketScaffold({
    super.key,
    this.body,
    this.appBar,
    this.appBarActions,
    this.title,
  });

  final Widget? body;
  final PreferredSizeWidget? appBar;
  final List<Widget>? appBarActions;
  final String? title;

  final noContent = const Center(child: Text('No content'));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ??
          AppBar(
            title: Text(
              title ?? 'Ticket app',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: appBarActions,
          ),
      body: body ?? noContent,
    );
  }
}
