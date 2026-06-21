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

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.trim().isNotEmpty) {
      _controller.text = text.trim();
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
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
    await _launch(normalized);
    if (!mounted) return;
    setState(() => _isOpening = false);
  }

  Future<void> _openNumber(String normalized) async {
    await _launch(normalized);
    if (mounted) setState(() {});
  }

  /// Lanza WhatsApp y solo guarda en historial si efectivamente se abrió.
  Future<void> _launch(String normalized) async {
    HapticFeedback.lightImpact();
    try {
      if (await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Vibration no disponible: $e');
    }
    final message = appStorage.optionalMessage;
    final launched = await openWhatsApp(
      normalized,
      text: message.isEmpty ? null : message,
    );
    if (launched) {
      await appStorage.addToHistory(normalized);
    } else if (mounted) {
      await _showWhatsAppFallback(normalized);
    }
  }

  /// Cuando no se pudo abrir WhatsApp (p. ej. no está instalado), ofrece
  /// abrir la conversación en el navegador o instalar WhatsApp.
  Future<void> _showWhatsAppFallback(String normalized) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No se pudo abrir WhatsApp'),
        content: const Text(
          'Puede que WhatsApp no esté instalado. ¿Qué quieres hacer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('store'),
            child: const Text('Instalar WhatsApp'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('browser'),
            child: const Text('Abrir en navegador'),
          ),
        ],
      ),
    );

    final message = appStorage.optionalMessage;
    switch (action) {
      case 'browser':
        final ok = await openWhatsAppInBrowser(
          normalized,
          text: message.isEmpty ? null : message,
        );
        if (ok) {
          await appStorage.addToHistory(normalized);
          if (mounted) setState(() {});
        } else if (mounted) {
          _showSnack('No se pudo abrir el navegador.');
        }
      case 'store':
        await openWhatsAppStorePage();
    }
  }

  Future<void> _shareNumber(String normalized) async {
    final message = appStorage.optionalMessage;
    final url = buildWhatsAppUrl(
      normalized,
      text: message.isEmpty ? null : message,
    );
    try {
      await Share.share(url);
    } catch (e) {
      debugPrint('Share falló: $e');
      if (mounted) _showSnack('No se pudo compartir el enlace.');
    }
  }

  Future<void> _toggleFavorite(String normalized) async {
    final wasFavorite = appStorage.isFavorite(normalized);
    if (wasFavorite) {
      await appStorage.removeFavorite(normalized);
    } else {
      await appStorage.addFavorite(normalized);
    }
    if (mounted) {
      setState(() {});
      _showSnack(wasFavorite ? 'Quitado de favoritos' : 'Agregado a favoritos');
    }
  }

  Future<void> _deleteFromHistory(String normalized) async {
    final index = appStorage.history.indexOf(normalized);
    await appStorage.removeFromHistory(normalized);
    if (mounted) {
      setState(() {});
      _showUndoSnack('Eliminado del historial', () async {
        await appStorage.restoreHistory(normalized, index < 0 ? 0 : index);
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _deleteFavorite(String normalized) async {
    final index = appStorage.favorites.indexOf(normalized);
    await appStorage.removeFavorite(normalized);
    if (mounted) {
      setState(() {});
      _showUndoSnack('Eliminado de favoritos', () async {
        await appStorage.restoreFavorite(normalized, index < 0 ? 0 : index);
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _editLabel(String normalized) async {
    final controller = TextEditingController(
      text: appStorage.labelFor(normalized) ?? '',
    );
    final label = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Etiqueta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(
            hintText: 'Ej: Mamá, Pizzería…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (label != null) {
      await appStorage.setLabel(normalized, label);
      if (mounted) setState(() {});
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUndoSnack(String message, Future<void> Function() onUndo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(label: 'Deshacer', onPressed: onUndo),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = appStorage.favorites;
    final history = appStorage.history
        .where((n) => !favorites.contains(n))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('fasT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
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
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d+\s()\-]')),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: InputDecoration(
                labelText: 'Número de teléfono',
                hintText: '9 2004 7008',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  tooltip: 'Pegar',
                  onPressed: _pasteFromClipboard,
                ),
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
              ...favorites
                  .take(10)
                  .map(
                    (n) => _NumberTile(
                      key: ValueKey('fav_$n'),
                      normalized: n,
                      label: appStorage.labelFor(n),
                      isFavorite: true,
                      onTap: () => _openNumber(n),
                      onShare: () => _shareNumber(n),
                      onToggleFavorite: () => _toggleFavorite(n),
                      onEditLabel: () => _editLabel(n),
                      onDelete: () => _deleteFavorite(n),
                    ),
                  ),
              const SizedBox(height: 20),
            ],
            if (history.isNotEmpty) ...[
              Text(
                'Historial reciente',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...history
                  .take(10)
                  .map(
                    (n) => _NumberTile(
                      key: ValueKey('hist_$n'),
                      normalized: n,
                      label: appStorage.labelFor(n),
                      isFavorite: false,
                      onTap: () => _openNumber(n),
                      onShare: () => _shareNumber(n),
                      onToggleFavorite: () => _toggleFavorite(n),
                      onEditLabel: () => _editLabel(n),
                      onDelete: () => _deleteFromHistory(n),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  final String normalized;
  final String? label;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEditLabel;
  final VoidCallback onDelete;

  const _NumberTile({
    super.key,
    required this.normalized,
    required this.label,
    required this.isFavorite,
    required this.onTap,
    required this.onShare,
    required this.onToggleFavorite,
    required this.onEditLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;
    return Dismissible(
      key: ValueKey('dismiss_${isFavorite}_$normalized'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(hasLabel ? label! : formatPhoneDisplay(normalized)),
          subtitle: hasLabel ? Text(formatPhoneDisplay(normalized)) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                tooltip: isFavorite ? 'Quitar de favoritos' : 'Favorito',
                onPressed: onToggleFavorite,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'share':
                      onShare();
                    case 'label':
                      onEditLabel();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Compartir'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'label',
                    child: ListTile(
                      leading: Icon(Icons.label_outline),
                      title: Text('Etiqueta'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
