import 'package:flutter/material.dart';

class TicketScaffold extends StatelessWidget {
  const TicketScaffold({
    super.key,
    this.body,
    this.appBar,
    this.appBarActions,
    this.title,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  final Widget? body;
  final PreferredSizeWidget? appBar;
  final List<Widget>? appBarActions;
  final String? title;
  final Widget? floatingActionButton;
  final bool showAppBar;

  final noContent = const Center(child: Text('No content'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!showAppBar || (title == null && appBar == null))
          ? null
          : appBar ??
              AppBar(
                title: Text(
                  title ?? 'Ticket app',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                centerTitle: true,
                actions: appBarActions,
              ),
      body: body ?? noContent,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: floatingActionButton,
    );
  }
}
