String timeAgo(String? dateStr) {
  if (dateStr == null) return '';
  final date = DateTime.tryParse(dateStr);
  if (date == null) return '';

  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'şimdi';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
  if (diff.inHours < 24) return '${diff.inHours} saat önce';
  if (diff.inDays < 7) return '${diff.inDays} gün önce';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} hafta önce';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ay önce';
  return '${(diff.inDays / 365).floor()} yıl önce';
}