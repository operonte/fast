import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/preferences_service.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedTheme = 'sistema';

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final theme = await PreferencesService.getSelectedTheme();
    if (mounted) {
      setState(() {
        _selectedTheme = theme;
      });
    }
  }

  // Método para recargar el tema (llamado desde WhatsAppPage)
  void reloadTheme() {
    _loadThemeSettings();
  }

  int _getThemeColor() {
    switch (_selectedTheme) {
      case 'rosa':
        return 0xFFE91E63; // Rosa
      case 'verde':
        return 0xFF4CAF50; // Verde
      case 'celeste':
        return 0xFF00BCD4; // Celeste
      case 'oscuro':
        return 0xFF9C27B0; // Morado (para oscuro)
      case 'sistema':
      default:
        return 0xFF9C27B0; // Morado (para sistema)
    }
  }

  ThemeMode _getThemeMode() {
    switch (_selectedTheme) {
      case 'oscuro':
        return ThemeMode.dark;
      case 'sistema':
        return ThemeMode.system;
      case 'rosa':
      case 'verde':
      case 'celeste':
      default:
        return ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();
    final themeMode = _getThemeMode();

    return MaterialApp(
      title: 'Fast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(themeColor),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(themeColor),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro
      ),
      themeMode: themeMode,
      home: WhatsAppPage(onThemeChanged: reloadTheme),
    );
  }
}

class WhatsAppPage extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const WhatsAppPage({super.key, this.onThemeChanged});

  @override
  State<WhatsAppPage> createState() => _WhatsAppPageState();
}

class _WhatsAppPageState extends State<WhatsAppPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<String> _recentNumbers = [];
  // ignore: unused_field
  String _countryCode = '+56'; // Reservado para futuras funcionalidades
  // ignore: unused_field
  bool _autoAddCountryCode = true; // Reservado para futuras funcionalidades
  String _defaultMessage = '';
  bool _showMessageField = false;
  bool _isLoading = false;
  String _selectedCountry = 'chile'; // 'chile' o 'otros'

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadRecentNumbers();
  }

  Future<void> _loadPreferences() async {
    final countryCode = await PreferencesService.getCountryCode();
    final autoAdd = await PreferencesService.getAutoAddCountryCode();
    final defaultMsg = await PreferencesService.getDefaultMessage();
    final selectedCountry = await PreferencesService.getSelectedCountry();

    if (mounted) {
      setState(() {
        _countryCode = countryCode;
        _autoAddCountryCode = autoAdd;
        _defaultMessage = defaultMsg;
        _selectedCountry = selectedCountry;
        if (defaultMsg.isNotEmpty) {
          _messageController.text = defaultMsg;
          _showMessageField = true;
        }
      });
    }
  }

  Future<void> _loadRecentNumbers() async {
    final numbers = await PreferencesService.getRecentNumbers();
    if (mounted) {
      setState(() {
        _recentNumbers = numbers;
      });
    }
  }

  bool _isValidPhoneNumber(String number) {
    // Remover caracteres no numéricos excepto +
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');

    // Debe empezar con + y tener al menos 10 dígitos después
    if (!cleaned.startsWith('+')) return false;

    // Debe tener entre 10 y 15 dígitos (incluyendo código de país)
    final digitsOnly = cleaned.substring(1);
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  Future<void> _sendWhatsApp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String phoneNumber = _phoneController.text.trim();
    String message = _messageController.text.trim();

    // Limpiar el número (solo dígitos y +)
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (phoneNumber.isEmpty) {
      _showError('Por favor ingresa un número de teléfono');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Procesar según el país seleccionado
    if (_selectedCountry == 'chile') {
      // Lógica para Chile
      String digitsOnly = phoneNumber.replaceAll('+', '');

      // Si empieza con 56, ya tiene el código de país
      if (digitsOnly.startsWith('56')) {
        // Verificar que tenga el formato correcto: 569XXXXXXXXX (11 dígitos)
        if (digitsOnly.length == 11 && digitsOnly.startsWith('569')) {
          phoneNumber = '+$digitsOnly';
        } else {
          _showError(
            'Formato incorrecto para Chile. Debe ser: 569XXXXXXXXX (11 dígitos). Ejemplo: 56920947008',
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else if (digitsOnly.startsWith('9')) {
        // Si empieza con 9
        if (digitsOnly.length == 9) {
          // Solo agregar código si está habilitado
          if (_autoAddCountryCode) {
            phoneNumber = '+56$digitsOnly';
          } else {
            _showError(
              'El número debe incluir el código de país (+56). Ejemplo: +56920947008',
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          _showError(
            'Formato incorrecto para Chile. Debe ser: 9XXXXXXXX (9 dígitos) o 569XXXXXXXXX (11 dígitos). Ejemplo: 920947008 o 56920947008',
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        // Si tiene 11 dígitos y no empieza con 56
        if (digitsOnly.length == 11) {
          // Solo agregar código si está habilitado
          if (_autoAddCountryCode) {
            phoneNumber = '+56$digitsOnly';
          } else {
            _showError(
              'El número debe incluir el código de país (+56). Ejemplo: +56920947008',
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else if (digitsOnly.length == 9) {
          // Si tiene 9 dígitos, agregar 56 solo si está habilitado
          if (_autoAddCountryCode) {
            phoneNumber = '+56$digitsOnly';
          } else {
            _showError(
              'El número debe incluir el código de país (+56). Ejemplo: +56920947008',
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          _showError(
            'Formato incorrecto para Chile. Debe ser: 9XXXXXXXX (9 dígitos) o 569XXXXXXXXX (11 dígitos). Ejemplo: 920947008 o 56920947008',
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
    } else {
      // Lógica para Otros países
      if (phoneNumber.startsWith('+')) {
        // Ya tiene el formato correcto
      } else {
        // Solo agregar el + si está habilitado
        if (_autoAddCountryCode) {
          phoneNumber = '+$phoneNumber';
        } else {
          _showError(
            'El número debe incluir el código de país con +. Ejemplo: +1234567890',
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
    }

    // Validar formato del número final
    if (!_isValidPhoneNumber(phoneNumber)) {
      _showError(
        'El número de teléfono no es válido. Debe tener entre 10 y 15 dígitos después del código de país.',
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Guardar en números recientes
    await PreferencesService.addRecentNumber(phoneNumber);
    await _loadRecentNumbers();

    // Crear la URL de WhatsApp
    String url = 'https://wa.me/$phoneNumber';
    if (message.isNotEmpty) {
      final encodedMessage = Uri.encodeComponent(message);
      url += '?text=$encodedMessage';
    }

    final Uri whatsappUrl = Uri.parse(url);

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        // Limpiar campos después de enviar
        _phoneController.clear();
        if (!_showMessageField || _defaultMessage.isEmpty) {
          _messageController.clear();
        } else {
          _messageController.text = _defaultMessage;
        }
      } else {
        _showError('No se pudo abrir WhatsApp. ¿Está instalado?');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _selectRecentNumber(String number) {
    HapticFeedback.lightImpact();
    setState(() {
      _phoneController.text = number;
    });
  }

  void _copyNumber(String number) {
    Clipboard.setData(ClipboardData(text: number));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Número copiado al portapapeles'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleMessageField() {
    setState(() {
      _showMessageField = !_showMessageField;
      if (!_showMessageField) {
        _messageController.clear();
      } else if (_defaultMessage.isNotEmpty) {
        _messageController.text = _defaultMessage;
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    // Usar el color de fondo del tema (oscuro o claro según corresponda)
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Fast',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              // Recargar preferencias y tema
              await _loadPreferences();
              await _loadRecentNumbers();
              // Notificar cambio de tema si existe callback
              widget.onThemeChanged?.call();
            },
            tooltip: 'Configuraciones',
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título principal
              Text(
                'fast',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Campo de número de teléfono
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Número de teléfono',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: _selectedCountry == 'chile'
                              ? 'Ej: 56920947008 o 920947008'
                              : 'Ej: +1234567890',
                          prefixIcon: Icon(
                            Icons.phone_android,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Se agregará código de área si hace falta',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle para mensaje
              Card(
                child: ListTile(
                  leading: Icon(Icons.message, color: primaryColor),
                  title: const Text('Agregar mensaje'),
                  trailing: Switch(
                    value: _showMessageField,
                    onChanged: (value) => _toggleMessageField(),
                  ),
                  onTap: () => _toggleMessageField(),
                ),
              ),

              // Campo de mensaje (condicional)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showMessageField
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.message, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Mensaje (opcional)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _messageController,
                                    maxLines: 4,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      hintText: 'Escribe tu mensaje aquí...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Botón de enviar
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Enviar mensaje',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Números recientes
              if (_recentNumbers.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Icon(Icons.history, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Números recientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._recentNumbers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final number = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.phone, color: primaryColor),
                        ),
                        title: Text(
                          number,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () => _copyNumber(number),
                              tooltip: 'Copiar número',
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                await PreferencesService.removeRecentNumber(
                                  number,
                                );
                                await _loadRecentNumbers();
                              },
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                        onTap: () => _selectRecentNumber(number),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
