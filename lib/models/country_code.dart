class CountryCode {
  final String code;
  final String name;
  final String flag;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
  });

  static const List<CountryCode> popularCountries = [
    CountryCode(code: '+52', name: 'México', flag: '🇲🇽'),
    CountryCode(code: '+1', name: 'Estados Unidos / Canadá', flag: '🇺🇸'),
    CountryCode(code: '+34', name: 'España', flag: '🇪🇸'),
    CountryCode(code: '+54', name: 'Argentina', flag: '🇦🇷'),
    CountryCode(code: '+55', name: 'Brasil', flag: '🇧🇷'),
    CountryCode(code: '+56', name: 'Chile', flag: '🇨🇱'),
    CountryCode(code: '+57', name: 'Colombia', flag: '🇨🇴'),
    CountryCode(code: '+51', name: 'Perú', flag: '🇵🇪'),
    CountryCode(code: '+58', name: 'Venezuela', flag: '🇻🇪'),
    CountryCode(code: '+593', name: 'Ecuador', flag: '🇪🇨'),
    CountryCode(code: '+502', name: 'Guatemala', flag: '🇬🇹'),
    CountryCode(code: '+506', name: 'Costa Rica', flag: '🇨🇷'),
    CountryCode(code: '+507', name: 'Panamá', flag: '🇵🇦'),
    CountryCode(code: '+505', name: 'Nicaragua', flag: '🇳🇮'),
    CountryCode(code: '+504', name: 'Honduras', flag: '🇭🇳'),
    CountryCode(code: '+503', name: 'El Salvador', flag: '🇸🇻'),
    CountryCode(code: '+595', name: 'Paraguay', flag: '🇵🇾'),
    CountryCode(code: '+598', name: 'Uruguay', flag: '🇺🇾'),
    CountryCode(code: '+591', name: 'Bolivia', flag: '🇧🇴'),
    CountryCode(code: '+49', name: 'Alemania', flag: '🇩🇪'),
    CountryCode(code: '+33', name: 'Francia', flag: '🇫🇷'),
    CountryCode(code: '+39', name: 'Italia', flag: '🇮🇹'),
    CountryCode(code: '+44', name: 'Reino Unido', flag: '🇬🇧'),
  ];
}

