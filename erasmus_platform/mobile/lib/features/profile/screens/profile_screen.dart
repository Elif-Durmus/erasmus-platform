import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(profile: profile),
              const Divider(),
              _ProfileStats(profile: profile),
              const Divider(),
              _ProfileInfo(profile: profile),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: profile['profilePhotoUrl'] != null
                ? NetworkImage(profile['profilePhotoUrl'])
                : null,
            child: profile['profilePhotoUrl'] == null
                ? Text(
                    (profile['fullName'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 36),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(profile['fullName'] ?? '', style: Theme.of(context).textTheme.titleLarge),
          Text('@${profile['username'] ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  )),
          if (profile['bio'] != null) ...[
            const SizedBox(height: 8),
            Text(profile['bio'], textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _ProfileStats({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Takipçi', value: '0'),
          _StatItem(label: 'Takip', value: '0'),
          _StatItem(label: 'Paylaşım', value: '0'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _ProfileInfo({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile['department'] != null)
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(profile['department']),
              subtitle: const Text('Bölüm'),
            ),
          if (profile['studyLevel'] != null)
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(profile['studyLevel']),
              subtitle: const Text('Eğitim seviyesi'),
            ),
        ],
      ),
    );
  }
}