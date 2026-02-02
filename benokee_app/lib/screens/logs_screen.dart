import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final StorageService _storage = StorageService();
  List<Map<String, String>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _storage.getCheckInLogs();
    setState(() {
      _logs = logs;
    });
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logs wissen?', style: TextStyle(fontSize: 28)),
        content: const Text(
          'Weet je zeker dat je alle logs wilt wissen?',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Wissen', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearLogs();
      await _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logs gewist'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Geschiedenis', style: TextStyle(fontSize: 28)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearLogs,
              tooltip: 'Logs wissen',
            ),
        ],
      ),
      body: _logs.isEmpty
          ? const Center(
              child: Text(
                'Geen logs beschikbaar',
                style: TextStyle(fontSize: 24),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                DateTime? dateTime;
                try {
                  dateTime = DateTime.parse(log['date'] ?? log['time'] ?? '');
                } catch (e) {
                  // Invalid date
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                    title: Text(
                      dateTime != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
                          : 'Onbekende datum',
                      style: const TextStyle(fontSize: 24),
                    ),
                    subtitle: dateTime != null
                        ? Text(
                            '${DateTime.now().difference(dateTime).inHours} uur geleden',
                            style: const TextStyle(fontSize: 20),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
