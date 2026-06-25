import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final exchangesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await apiClient.dio.get('/users/me/exchanges');
  return res.data as List<dynamic>;
});

final countriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final res = await apiClient.dio.get('/users/countries');
  return res.data as List<dynamic>;
});

final universitiesProvider =
    FutureProvider.family<List<dynamic>, String?>((ref, countryId) async {
  final res = await apiClient.dio.get('/users/universities',
      queryParameters: countryId != null ? {'countryId': countryId} : null);
  return res.data as List<dynamic>;
});

class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  @override
  Widget build(BuildContext context) {
    final exchangesAsync = ref.watch(exchangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Erasmus Değişimlerim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExchangeDialog(context),
          ),
        ],
      ),
      body: exchangesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (exchanges) => exchanges.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flight_outlined,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz değişim bilgisi eklemediniz',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _showAddExchangeDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Değişim Ekle'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: exchanges.length,
                itemBuilder: (ctx, i) {
                  final e = exchanges[i];
                  return _ExchangeCard(
                    exchange: e,
                    onDelete: () async {
                      await apiClient.dio
                          .delete('/users/me/exchanges/${e['id']}');
                      ref.refresh(exchangesProvider);
                    },
                  );
                },
              ),
      ),
    );
  }

  void _showAddExchangeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddExchangeSheet(
        onSaved: () {
          ref.refresh(exchangesProvider);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ExchangeCard extends StatelessWidget {
  final Map<String, dynamic> exchange;
  final VoidCallback onDelete;

  const _ExchangeCard({required this.exchange, required this.onDelete});

  String _statusLabel(String status) {
    const labels = {
      'planning': 'Planlıyor',
      'accepted': 'Kabul Edildi',
      'ongoing': 'Devam Ediyor',
      'completed': 'Tamamlandı',
    };
    return labels[status] ?? status;
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'planning': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'ongoing': return Colors.green;
      case 'completed': return Colors.grey;
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  String _termLabel(String? term) {
    const labels = {
      'fall': 'Güz',
      'spring': 'Bahar',
      'summer': 'Yaz',
      'full_year': 'Tam Yıl',
    };
    return labels[term] ?? term ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final status = exchange['exchangeStatus'] ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status, context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(status, context)),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: _statusColor(status, context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (exchange['isCurrent'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'Güncel',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (exchange['academicYear'] != null)
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Akademik Yıl',
                value: exchange['academicYear'],
              ),
            if (exchange['term'] != null)
              _InfoRow(
                icon: Icons.wb_sunny_outlined,
                label: 'Dönem',
                value: _termLabel(exchange['term']),
              ),
            if (exchange['startDate'] != null)
              _InfoRow(
                icon: Icons.flight_takeoff_outlined,
                label: 'Başlangıç',
                value: exchange['startDate'].toString().substring(0, 10),
              ),
            if (exchange['endDate'] != null)
              _InfoRow(
                icon: Icons.flight_land_outlined,
                label: 'Bitiş',
                value: exchange['endDate'].toString().substring(0, 10),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Değişimi Sil'),
        content: const Text('Bu değişim kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class AddExchangeSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const AddExchangeSheet({super.key, required this.onSaved});

  @override
  ConsumerState<AddExchangeSheet> createState() => _AddExchangeSheetState();
}

class _AddExchangeSheetState extends ConsumerState<AddExchangeSheet> {
  String _status = 'planning';
  String? _selectedCountryId;
  String? _selectedUniversityId;
  String? _term;
  String? _academicYear;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _saving = false;

  final _statuses = ['planning', 'accepted', 'ongoing', 'completed'];
  final _statusLabels = {
    'planning': 'Planlıyor',
    'accepted': 'Kabul Edildi',
    'ongoing': 'Devam Ediyor',
    'completed': 'Tamamlandı',
  };
  final _terms = ['fall', 'spring', 'summer', 'full_year'];
  final _termLabels = {
    'fall': 'Güz',
    'spring': 'Bahar',
    'summer': 'Yaz',
    'full_year': 'Tam Yıl',
  };

  // Akademik yıl seçenekleri: 5 yıl öncesinden 1 yıl sonrasına
  List<String> get _academicYears {
    final now = DateTime.now().year;
    final years = <String>[];
    for (int y = now + 1; y >= now - 5; y--) {
      years.add('${y}-${y + 1}');
    }
    return years;
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  // Backend'in beklediği format: YYYY-MM-DD
  String _apiDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 6),
      lastDate: DateTime(now.year + 3),
      helpText: 'Başlangıç tarihi seç',
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: _startDate ?? DateTime(now.year - 6),
      lastDate: DateTime(now.year + 4),
      helpText: 'Bitiş tarihi seç',
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await apiClient.dio.post('/users/me/exchanges', data: {
        'exchangeStatus': _status,
        'hostCountryId': _selectedCountryId,
        'hostUniversityId': _selectedUniversityId,
        'term': _term,
        'academicYear': _academicYear,
        'startDate': _startDate != null ? _apiDate(_startDate!) : null,
        'endDate': _endDate != null ? _apiDate(_endDate!) : null,
        'isCurrent': _isCurrent,
      });
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);
    final universitiesAsync = ref.watch(universitiesProvider(_selectedCountryId));

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Değişim Ekle',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Durum
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Değişim Durumu',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
              items: _statuses
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabels[s]!),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 16),
            // Ülke
            countriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Ülkeler yüklenemedi: $e'),
              data: (countries) => DropdownButtonFormField<String>(
                value: _selectedCountryId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Gidilen Ülke',
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Seçiniz')),
                  ...countries.map((c) => DropdownMenuItem(
                        value: c['id'] as String,
                        child: Text(c['name'] as String),
                      )),
                ],
                onChanged: (val) => setState(() {
                  _selectedCountryId = val;
                  _selectedUniversityId = null;
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Üniversite
            universitiesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Üniversiteler yüklenemedi: $e'),
              data: (universities) => DropdownButtonFormField<String>(
                value: _selectedUniversityId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Gidilen Üniversite',
                  prefixIcon: Icon(Icons.school_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Seçiniz')),
                  ...universities.map((u) => DropdownMenuItem(
                        value: u['id'] as String,
                        child: Text(
                          u['name'] as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                ],
                onChanged: (val) => setState(() => _selectedUniversityId = val),
              ),
            ),
            const SizedBox(height: 16),
            // Dönem
            DropdownButtonFormField<String>(
              value: _term,
              decoration: const InputDecoration(
                labelText: 'Dönem',
                prefixIcon: Icon(Icons.wb_sunny_outlined),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Seçiniz')),
                ..._terms.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(_termLabels[t]!),
                    )),
              ],
              onChanged: (val) => setState(() => _term = val),
            ),
            const SizedBox(height: 16),
            // Akademik Yıl - artık dropdown
            DropdownButtonFormField<String>(
              value: _academicYear,
              decoration: const InputDecoration(
                labelText: 'Akademik Yıl',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Seçiniz')),
                ..._academicYears.map((y) => DropdownMenuItem(
                      value: y,
                      child: Text(y),
                    )),
              ],
              onChanged: (val) => setState(() => _academicYear = val),
            ),
            const SizedBox(height: 16),
            // Başlangıç tarihi - takvim seçici
            InkWell(
              onTap: _pickStartDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Başlangıç Tarihi',
                  prefixIcon: Icon(Icons.flight_takeoff_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _startDate != null
                      ? _formatDate(_startDate!)
                      : 'Tarih seçiniz',
                  style: TextStyle(
                    color: _startDate != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bitiş tarihi - takvim seçici
            InkWell(
              onTap: _pickEndDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Bitiş Tarihi',
                  prefixIcon: Icon(Icons.flight_land_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _endDate != null ? _formatDate(_endDate!) : 'Tarih seçiniz',
                  style: TextStyle(
                    color: _endDate != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Güncel değişimim'),
              subtitle: const Text('Şu an devam eden değişim'),
              value: _isCurrent,
              onChanged: (val) => setState(() => _isCurrent = val),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}