import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';

/// Ajustes: tema, mensaje opcional, tutorial de nuevo, limpiar historial/favoritos, enlaces a Acerca de, Contacto, Privacidad, Términos.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const _SectionTitle(title: 'Apariencia'),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Modo oscuro'),
            subtitle: Text(_themeModeLabel(appStorage.themeMode)),
            onTap: () => _showThemeDialog(context),
          ),
          const Divider(height: 1),
          const _SectionTitle(title: 'WhatsApp'),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Mensaje inicial opcional'),
            subtitle: Text(
              appStorage.optionalMessage.isEmpty ? 'Ninguno' : appStorage.optionalMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _showOptionalMessageDialog(context),
          ),
          const Divider(height: 1),
          const _SectionTitle(title: 'Datos'),
          ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('Ver tutorial de nuevo'),
            onTap: () async {
              await appStorage.setOnboardingDone(false);
              if (context.mounted) context.go('/onboarding');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Limpiar historial'),
            onTap: () => _confirmClear(context, 'historial', appStorage.clearHistory),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Limpiar favoritos'),
            onTap: () => _confirmClear(context, 'favoritos', appStorage.clearFavorites),
          ),
          const Divider(height: 1),
          const _SectionTitle(title: 'Información'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () => context.push('/about'),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contacto'),
            onTap: () => context.push('/contact'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de privacidad'),
            onTap: () => context.push('/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Términos de uso'),
            onTap: () => context.push('/terms'),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Oscuro';
      default:
        return 'Sistema';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modo oscuro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Sistema'),
              value: 'system',
              groupValue: appStorage.themeMode,
              onChanged: (v) async {
                if (v != null) {
                  await appStorage.setThemeMode(v);
                  onThemeChanged?.call(() {});
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Claro'),
              value: 'light',
              groupValue: appStorage.themeMode,
              onChanged: (v) async {
                if (v != null) {
                  await appStorage.setThemeMode(v);
                  onThemeChanged?.call(() {});
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Oscuro'),
              value: 'dark',
              groupValue: appStorage.themeMode,
              onChanged: (v) async {
                if (v != null) {
                  await appStorage.setThemeMode(v);
                  onThemeChanged?.call(() {});
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionalMessageDialog(BuildContext context) {
    final controller = TextEditingController(text: appStorage.optionalMessage);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mensaje inicial opcional'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Texto que se pre-rellenará en WhatsApp',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await appStorage.setOptionalMessage(controller.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, String name, Future<void> Function() clear) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Eliminar todo el $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) await clear();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
