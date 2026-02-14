import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:share_plus/share_plus.dart';
import '../app_state.dart';
import '../utils/phone_utils.dart';
import '../services/whatsapp_service.dart';

/// Pantalla principal: campo de número, botón abrir WhatsApp, historial y favoritos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _displayValue = '';
  String? _errorMessage;
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onFieldChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onFieldChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFieldChange() {
    final raw = _controller.text;
    final normalized = normalizePhoneForChile(raw);
    setState(() {
      _displayValue = normalized.isEmpty ? raw : formatPhoneDisplay(normalized);
      _errorMessage = null;
    });
  }

  Future<void> _openWhatsApp() async {
    final raw = _controller.text.trim();
    final normalized = normalizePhoneForChile(raw);
    final validation = validateChileMobile(normalized);
    if (validation != PhoneValidationResult.valid) {
      setState(() => _errorMessage = validation.message);
      return;
    }
    setState(() => _isOpening = true);
    HapticFeedback.lightImpact();
    try {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 50);
      }
    } catch (_) {}
    final text = appStorage.optionalMessage;
    final launched = await openWhatsApp(normalized, text: text.isEmpty ? null : text);
    await appStorage.addToHistory(normalized);
    if (!mounted) return;
    setState(() => _isOpening = false);
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp. Prueba en el navegador.')),
      );
    }
  }

  Future<void> _openNumber(String normalized) async {
    HapticFeedback.lightImpact();
    final text = appStorage.optionalMessage;
    await openWhatsApp(normalized, text: text.isEmpty ? null : text);
    await appStorage.addToHistory(normalized);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _shareNumber(String normalized) async {
    final url = buildWhatsAppUrl(normalized, text: appStorage.optionalMessage.isEmpty ? null : appStorage.optionalMessage);
    // share_plus Share.share with text/url
    try {
      await Share.share(url);
    } catch (_) {}
  }

  // Use share_plus - need to add import
  void _toggleFavorite(String normalized) async {
    if (appStorage.isFavorite(normalized)) {
      await appStorage.removeFavorite(normalized);
    } else {
      await appStorage.addFavorite(normalized);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final history = appStorage.history;
    final favorites = appStorage.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('fasT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Número de teléfono',
                hintText: '9 2004 7008',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
              onChanged: (_) => _onFieldChange(),
              onSubmitted: (_) => _openWhatsApp(),
            ),
            const SizedBox(height: 8),
            if (_displayValue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Se usará: $_displayValue',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isOpening ? null : _openWhatsApp,
              icon: _isOpening
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chat),
              label: Text(_isOpening ? 'Abriendo WhatsApp…' : 'Abrir WhatsApp'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (favorites.isNotEmpty) ...[
              Text('Favoritos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...favorites.take(10).map((n) => _NumberTile(
                    normalized: n,
                    isFavorite: true,
                    onTap: () => _openNumber(n),
                    onShare: () => _shareNumber(n),
                    onToggleFavorite: () => _toggleFavorite(n),
                  )),
              const SizedBox(height: 20),
            ],
            if (history.isNotEmpty) ...[
              Text('Historial reciente', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...history.where((n) => !favorites.contains(n)).take(10).map((n) => _NumberTile(
                    normalized: n,
                    isFavorite: false,
                    onTap: () => _openNumber(n),
                    onShare: () => _shareNumber(n),
                    onToggleFavorite: () => _toggleFavorite(n),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  final String normalized;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;

  const _NumberTile({
    required this.normalized,
    required this.isFavorite,
    required this.onTap,
    required this.onShare,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(formatPhoneDisplay(normalized)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              onPressed: onToggleFavorite,
            ),
            IconButton(icon: const Icon(Icons.share), onPressed: onShare),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
