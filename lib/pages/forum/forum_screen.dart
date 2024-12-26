import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/models/conversasion.dart';
import 'package:event_ticket/providers/forum_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  static const showAddConversasion = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void onConversasionTap(BuildContext context, Conversasion conversasion) {
    context.push(Routes.getForumDetailPath(conversasion.id),
        extra: conversasion);
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(forumProvider);
    return TicketScaffold(
      title: 'Forums',
      appBarActions: [
        if (showAddConversasion)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Implement create new conversation
            },
            tooltip: 'Create New Forum',
          ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(forumProvider.future),
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              floating: true,
              delegate: _SearchBarDelegate(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSearchBar(),
                ),
              ),
            ),
            switch (asyncValue) {
              AsyncValue<List<Conversasion>>(:final valueOrNull) =>
                valueOrNull != null
                    ? _buildConversasionList(context, ref, valueOrNull)
                    : SliverToBoxAdapter(child: _buildEmptyState(context)),
              // ignore: dead_code, unreachable_switch_case
              AsyncValue(:final error) => SliverToBoxAdapter(
                  child: _buildErrorState(error!),
                ),
              // ignore: dead_code, unreachable_switch_case
              _ => const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            }
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      hintText: 'Search forums...',
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim();
        });
      },
      leading: const Icon(Icons.search),
      trailing: _searchQuery.isNotEmpty
          ? [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            ]
          : null,
    );
  }

  Widget _buildConversasionList(
      BuildContext context, WidgetRef ref, List<Conversasion>? conversations) {
    // First check if the conversations list is null or empty
    if (conversations == null || conversations.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(context),
      );
    }

    final filteredConversations = conversations
        .where((conv) =>
            conv.title != null &&
            conv.title!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (filteredConversations.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(context),
      );
    }

    // Return the list of filtered conversations
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filteredConversations[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _buildConversationCard(context, item),
            );
          },
          childCount: filteredConversations.length,
        ),
      ),
    );
  }

  Widget _buildConversationCard(BuildContext context, Conversasion item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => onConversasionTap(context, item),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title ?? 'Untitled Conversation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildTypeChip(context, item.type),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.createdAt?.toDDMMYYYY() ?? 'Unknown Date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(width: 16),
                  if (item.type == ConversasionType.private) ...[
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.members?.length ?? 0} members',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, ConversasionType? type) {
    if (type == null) return const SizedBox.shrink();

    Color chipColor;
    String chipText;
    switch (type) {
      case ConversasionType.private:
        chipColor = Colors.deepPurple;
        chipText = 'Private';
        break;
      case ConversasionType.public:
        chipColor = Colors.green;
        chipText = 'Public';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        chipText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No Conversations Found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No forums match your search'
                    : 'Start a conversation and connect with others!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 20),
              if (showAddConversasion)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement create new conversation
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Create Forum'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_rounded,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something Went Wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(forumProvider.future),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// Delegate để tạo header tìm kiếm nổi
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchBarDelegate({required this.child});

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
