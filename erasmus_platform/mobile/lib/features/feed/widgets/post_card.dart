import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  Color _typeColor(String type, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    switch (type) {
      case 'experience': return cs.primary;
      case 'advice': return Colors.green;
      case 'warning': return Colors.orange;
      case 'housing': return Colors.blue;
      case 'event': return Colors.purple;
      default: return cs.secondary;
    }
  }

  String _typeLabel(String type) {
    const labels = {
      'experience': 'Deneyim',
      'advice': 'Tavsiye',
      'warning': 'Uyarı',
      'housing': 'Konut',
      'event': 'Etkinlik',
      'academic': 'Akademik',
    };
    return labels[type] ?? type;
  }

  @override
  Widget build(BuildContext context) {
    final profile = post['user']?['profile'] as Map<String, dynamic>?;
    final type = post['postType'] as String? ?? 'experience';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/posts/${post['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: profile?['profilePhotoUrl'] != null
                        ? NetworkImage(profile!['profilePhotoUrl'])
                        : null,
                    child: profile?['profilePhotoUrl'] == null
                        ? Text((profile?['fullName'] as String?)?.substring(0, 1).toUpperCase() ?? '?')
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile?['fullName'] ?? 'Kullanıcı',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('@${profile?['username'] ?? ''}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _typeColor(type, context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_typeLabel(type),
                        style: TextStyle(
                          fontSize: 11,
                          color: _typeColor(type, context),
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              if (post['title'] != null) ...[
                const SizedBox(height: 10),
                Text(post['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
              const SizedBox(height: 8),
              Text(
                post['content'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.favorite_border, size: 18, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 4),
                  Text('${post['likeCount'] ?? 0}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.comment_outlined, size: 18, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 4),
                  Text('${post['commentCount'] ?? 0}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}