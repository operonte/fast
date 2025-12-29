import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/preferences_service.dart';
import '../models/country_code.dart';
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _countryCode = '+56';
  bool _autoAddCountryCode = true;
  String _defaultMessage = '';
  int _maxRecentNumbers = 10;
  String _selectedCountry = 'chile';
  String _selectedTheme = 'sistema';
  bool _isLoading = true;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _maxNumbersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final countryCode = await PreferencesService.getCountryCode();
    final autoAdd = await PreferencesService.getAutoAddCountryCode();
    final defaultMsg = await PreferencesService.getDefaultMessage();
    final maxNumbers = await PreferencesService.getMaxRecentNumbers();
    final selectedCountry = await PreferencesService.getSelectedCountry();
    final selectedTheme = await PreferencesService.getSelectedTheme();

    setState(() {
      _countryCode = countryCode;
      _autoAddCountryCode = autoAdd;
      _defaultMessage = defaultMsg;
      _maxRecentNumbers = maxNumbers;
      _selectedCountry = selectedCountry;
      _selectedTheme = selectedTheme;
      _messageController.text = defaultMsg;
      _countryCodeController.text = countryCode;
      _maxNumbersController.text = maxNumbers.toString();
      _isLoading = false;
    });
  }

  Future<void> _saveSelectedCountry(String country) async {
    await PreferencesService.setSelectedCountry(country);
    setState(() {
      _selectedCountry = country;
    });
    _showSuccess('País seleccionado: ${country == 'chile' ? 'Chile' : 'Otros países'}');
  }

  Future<void> _saveTheme(String theme) async {
    await PreferencesService.setSelectedTheme(theme);
    setState(() {
      _selectedTheme = theme;
    });
    String themeText = theme == 'rosa' ? 'Rosa' : 
                      (theme == 'verde' ? 'Verde' : 
                      (theme == 'celeste' ? 'Celeste' : 
                      (theme == 'oscuro' ? 'Oscuro' : 'Sistema')));
    _showSuccess('Tema cambiado a: $themeText');
  }

  Future<void> _saveCountryCode() async {
    await PreferencesService.setCountryCode(_countryCode);
    _showSuccess('Código de país guardado');
  }

  Future<void> _saveDefaultMessage() async {
    await PreferencesService.setDefaultMessage(_defaultMessage);
    _showSuccess('Mensaje predefinido guardado');
  }

  Future<void> _saveAutoAddCountryCode() async {
    await PreferencesService.setAutoAddCountryCode(_autoAddCountryCode);
  }

  Future<void> _saveMaxRecentNumbers() async {
    final max = int.tryParse(_maxNumbersController.text) ?? 10;
    if (max < 1 || max > 50) {
      _showError('El número debe estar entre 1 y 50');
      return;
    }
    await PreferencesService.setMaxRecentNumbers(max);
    setState(() {
      _maxRecentNumbers = max;
    });
    _showSuccess('Máximo de números recientes guardado');
  }


  Future<void> _clearRecentNumbers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los números recientes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PreferencesService.clearRecentNumbers();
      _showSuccess('Números recientes eliminados');
    }
  }

  void _showSuccess(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showError(String message) {
    HapticFeedback.mediumImpact();
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

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Seleccionar código de país',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: CountryCode.popularCountries.length,
                itemBuilder: (context, index) {
                  final country = CountryCode.popularCountries[index];
                  final isSelected = country.code == _countryCode;
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.code),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _countryCode = country.code;
                        _countryCodeController.text = country.code;
                      });
                      _saveCountryCode();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('  • '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _countryCodeController.dispose();
    _maxNumbersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección: País de destino
          Card(
            color: primaryColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.public, color: primaryColor, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'País de destino',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecciona el país para el formato de números:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: _selectedCountry == 'chile'
                              ? primaryColor
                              : Colors.white,
                          child: InkWell(
                            onTap: () => _saveSelectedCountry('chile'),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text(
                                    '🇨🇱',
                                    style: TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedCountry == 'chile'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Formato: 569XXXXXXXXX',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _selectedCountry == 'chile'
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: _selectedCountry == 'otros'
                              ? primaryColor
                              : Colors.white,
                          child: InkWell(
                            onTap: () => _saveSelectedCountry('otros'),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text(
                                    '🌍',
                                    style: TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Otros países',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedCountry == 'otros'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Número completo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _selectedCountry == 'otros'
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedCountry == 'chile')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 20, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Se agregará código de área si hace falta',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_selectedCountry == 'otros')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 20, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Se agregará código de área si hace falta',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sección: Código de país
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.language, color: primaryColor),
              title: const Text('Código de país'),
              subtitle: Text('Actual: $_countryCode'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _countryCodeController,
                        decoration: InputDecoration(
                          labelText: 'Código de país',
                          hintText: '+56',
                          prefixIcon: const Icon(Icons.flag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _countryCode = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _saveCountryCode,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar código'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _showCountryCodePicker,
                        icon: const Icon(Icons.list),
                        label: const Text('Seleccionar de lista'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sección: Auto agregar código
          Card(
            child: SwitchListTile(
              secondary: Icon(Icons.auto_fix_high, color: primaryColor),
              title: const Text('Agregar código automáticamente'),
              subtitle: const Text(
                'Agrega el código de país si el número no lo incluye',
              ),
              value: _autoAddCountryCode,
              onChanged: (value) {
                setState(() {
                  _autoAddCountryCode = value;
                });
                _saveAutoAddCountryCode();
              },
            ),
          ),

          const SizedBox(height: 12),

          // Sección: Mensaje predefinido
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.message, color: primaryColor),
              title: const Text('Mensaje predefinido'),
              subtitle: Text(
                _defaultMessage.isEmpty
                    ? 'No configurado'
                    : _defaultMessage.length > 30
                        ? '${_defaultMessage.substring(0, 30)}...'
                        : _defaultMessage,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Mensaje predefinido',
                          hintText: 'Escribe un mensaje que se agregará automáticamente...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _defaultMessage = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _saveDefaultMessage,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar mensaje'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sección: Números recientes
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.history, color: primaryColor),
              title: const Text('Números recientes'),
              subtitle: Text('Máximo: $_maxRecentNumbers'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _maxNumbersController,
                        decoration: InputDecoration(
                          labelText: 'Máximo de números recientes',
                          hintText: '10',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _saveMaxRecentNumbers,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _clearRecentNumbers,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar todos'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sección: Tema
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.palette, color: primaryColor),
              title: const Text('Tema'),
              subtitle: Text(
                _selectedTheme == 'rosa'
                    ? 'Rosa'
                    : (_selectedTheme == 'verde'
                        ? 'Verde'
                        : (_selectedTheme == 'celeste'
                            ? 'Celeste'
                            : (_selectedTheme == 'oscuro'
                                ? 'Oscuro'
                                : 'Sistema'))),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildThemeOption(
                        'rosa',
                        'Rosa',
                        0xFFE91E63,
                        Icons.favorite,
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        'verde',
                        'Verde',
                        0xFF4CAF50,
                        Icons.eco,
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        'celeste',
                        'Celeste',
                        0xFF00BCD4,
                        Icons.water_drop,
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        'sistema',
                        'Sistema',
                        0xFF9C27B0,
                        Icons.brightness_auto,
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        'oscuro',
                        'Oscuro',
                        0xFF424242,
                        Icons.dark_mode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sección: Acerca de
          Card(
            child: ListTile(
              leading: Icon(Icons.info, color: primaryColor),
              title: const Text('Acerca de'),
              subtitle: const Text('Información y contacto'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Información adicional
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_android, color: primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Información',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Versión: 1.0.0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Funcionalidades:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('📱 Envío directo a WhatsApp desde Fast'),
                  _buildFeatureItem('🌍 Soporte para códigos de país'),
                  _buildFeatureItem('💬 Mensajes predefinidos'),
                  _buildFeatureItem('📋 Historial de números recientes'),
                  _buildFeatureItem('⚙️ Configuraciones personalizables'),
                  _buildFeatureItem('🎨 Temas personalizables'),
                  _buildFeatureItem('🔢 Validación de números'),
                  _buildFeatureItem('✨ Interfaz intuitiva y moderna'),
                  const SizedBox(height: 12),
                  const Text(
                    'Características principales:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Abre WhatsApp directamente con el número ingresado\n'
                    '• Permite agregar un mensaje predefinido\n'
                    '• Guarda números recientes para acceso rápido\n'
                    '• Configuración de código de país por defecto\n'
                    '• Personalización de colores del tema\n'
                    '• Limpieza automática de formato de números\n'
                    '• Validación de números de teléfono\n'
                    '• Interfaz moderna y fácil de usar',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String theme,
    String title,
    int color,
    IconData icon,
  ) {
    final isSelected = _selectedTheme == theme;
    final themeData = Theme.of(context);
    final primaryColor = themeData.colorScheme.primary;

    return Card(
      color: isSelected
          ? primaryColor.withValues(alpha: 0.1)
          : Colors.transparent,
      elevation: isSelected ? 2 : 0,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(color).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Color(color),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? primaryColor : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: primaryColor)
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () => _saveTheme(theme),
      ),
    );
  }
}

