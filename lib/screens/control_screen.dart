import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Import for Timer
import '../config/theme.dart';
import '../services/api_service.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final AgriApiService _apiService = AgriApiService();
  final _formKey = GlobalKey<FormState>();

  // Ayar Değişkenleri
  double _phThreshold = 6.0;
  double _ecThreshold = 1.8;
  TimeOfDay _dayStartTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _nightStartTime = const TimeOfDay(hour: 18, minute: 0);
  double _dayClimateOnTemp = 28.0;
  double _dayClimateOffTemp = 25.0;
  double _nightClimateOnTemp = 20.0;
  double _nightClimateOffTemp = 23.0;
  double _manualDoseAmount = 10.0; // ml
  bool _isManualFanOn = false;
  bool _isManualAcOn = false;
  double _dliTarget = 17.0;

  // Manuel Kontrol Override
  bool _isManualOverrideActive = false;
  Timer? _overrideTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _overrideTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  void _toggleManualOverride(bool newValue) {
    setState(() {
      _isManualOverrideActive = newValue;
    });

    if (newValue) {
      _overrideTimer?.cancel(); // Cancel any existing timer
      _overrideTimer = Timer(const Duration(minutes: 10), () {
        if (mounted) {
          setState(() {
            _isManualOverrideActive = false;
            // Optionally, turn off manual controls here if they were left on
            _isManualFanOn = false;
            _isManualAcOn = false;
            // Call API to turn off fan/AC if needed
             _apiService.controlClimate('fan', false);
             _apiService.controlClimate('ac', false);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manuel kontrol süresi doldu, override kapatıldı.')),
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manuel kontrol override aktif, 10 dakika boyunca geçerli.')),
      );
    } else {
      _overrideTimer?.cancel(); // Manually turned off, cancel timer
       // Optionally, turn off manual controls here if they were left on
        if (_isManualFanOn) {
          setState(() {
            _isManualFanOn = false;
          });
          _apiService.controlClimate('fan', false);
        }
        if (_isManualAcOn) {
          setState(() {
            _isManualAcOn = false;
          });
          _apiService.controlClimate('ac', false);
        }
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _apiService.getSettings();
    if (settings.isNotEmpty) {
      setState(() {
        _phThreshold = settings['ph_threshold'] ?? _phThreshold;
        _ecThreshold = settings['ec_threshold'] ?? _ecThreshold;
        _dayStartTime = _parseTimeString(settings['day_start_time'], _dayStartTime);
        _nightStartTime = _parseTimeString(settings['night_start_time'], _nightStartTime);
        _dayClimateOnTemp = settings['day_climate_on_temp'] ?? _dayClimateOnTemp;
        _dayClimateOffTemp = settings['day_climate_off_temp'] ?? _dayClimateOffTemp;
        _nightClimateOnTemp = settings['night_climate_on_temp'] ?? _nightClimateOnTemp;
        _nightClimateOffTemp = settings['night_climate_off_temp'] ?? _nightClimateOffTemp;
        _manualDoseAmount = settings['manual_dose_amount'] ?? _manualDoseAmount;
        _isManualFanOn = settings['is_manual_fan_on'] ?? _isManualFanOn;
        _isManualAcOn = settings['is_manual_ac_on'] ?? _isManualAcOn;
        _dliTarget = settings['dli_target'] ?? _dliTarget;
      });
    }
  }

  TimeOfDay _parseTimeString(String? timeString, TimeOfDay defaultValue) {
    if (timeString != null && timeString.contains(':')) {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return defaultValue;
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final settings = {
        'ph_threshold': _phThreshold,
        'ec_threshold': _ecThreshold,
        'day_start_time': '${_dayStartTime.hour.toString().padLeft(2, '0')}:${_dayStartTime.minute.toString().padLeft(2, '0')}',
        'night_start_time': '${_nightStartTime.hour.toString().padLeft(2, '0')}:${_nightStartTime.minute.toString().padLeft(2, '0')}',
        'day_climate_on_temp': _dayClimateOnTemp,
        'day_climate_off_temp': _dayClimateOffTemp,
        'night_climate_on_temp': _nightClimateOnTemp,
        'night_climate_off_temp': _nightClimateOffTemp,
        'manual_dose_amount': _manualDoseAmount,
        'is_manual_fan_on': _isManualFanOn,
        'is_manual_ac_on': _isManualAcOn,
        'dli_target': _dliTarget,
      };

      final success = await _apiService.updateSettings(settings);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar başarıyla kaydedildi!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar kaydedilemedi.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDayTime) async {
    final initialTime = isDayTime ? _dayStartTime : _nightStartTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.black,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialTime) {
      setState(() {
        if (isDayTime) {
          _dayStartTime = picked;
        } else {
          _nightStartTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Kontrol Ayarları', style: Theme.of(context).textTheme.displayLarge),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Dozlama Ayarları ---
              _buildSectionTitle('Dozlama Ayarları'),
              _buildSettingItem(
                context,
                'pH Eşiği',
                TextFormField(
                  initialValue: _phThreshold.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 6.0', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _phThreshold = double.tryParse(value ?? '') ?? _phThreshold,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                ),
              ),
              _buildSettingItem(
                context,
                'EC Eşiği',
                TextFormField(
                  initialValue: _ecThreshold.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 1.8', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _ecThreshold = double.tryParse(value ?? '') ?? _ecThreshold,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                ),
              ),
              const SizedBox(height: 20),

              // --- Zaman Ayarları ---
              _buildSectionTitle('Zaman Ayarları'),
              _buildSettingItem(
                context,
                'Gündüz Başlangıç Saati',
                _buildTimePickerButton(context, _dayStartTime, true),
              ),
              _buildSettingItem(
                context,
                'Gece Başlangıç Saati',
                _buildTimePickerButton(context, _nightStartTime, false),
              ),
              const SizedBox(height: 20),

              // --- Gündüz İklim Kontrol Ayarları ---
              _buildSectionTitle('Gündüz İklim Kontrol Ayarları'),
              _buildSettingItem(
                context,
                'Klima Açılma Sıcaklığı',
                TextFormField(
                  initialValue: _dayClimateOnTemp.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 28.0', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _dayClimateOnTemp = double.tryParse(value ?? '') ?? _dayClimateOnTemp,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                ),
              ),
              _buildSettingItem(
                context,
                'Klima Kapanma Sıcaklığı',
                TextFormField(
                  initialValue: _dayClimateOffTemp.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 25.0', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _dayClimateOffTemp = double.tryParse(value ?? '') ?? _dayClimateOffTemp,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                ),
              ),
              const SizedBox(height: 20),

              // --- Gece İklim Kontrol Ayarları ---
              _buildSectionTitle('Gece İklim Kontrol Ayarları'),
              _buildSettingItem(
                context,
                'Klima Açılma Sıcaklığı',
                TextFormField(
                  initialValue: _nightClimateOnTemp.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 20.0', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _nightClimateOnTemp = double.tryParse(value ?? '') ?? _nightClimateOnTemp,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                ),
              ),
              _buildSettingItem(
                context,
                'Klima Kapanma Sıcaklığı',
                TextFormField(
                  initialValue: _nightClimateOffTemp.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 23.0', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _nightClimateOffTemp = double.tryParse(value ?? '') ?? _nightClimateOffTemp,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                ),
              ),
              const SizedBox(height: 20),

              // --- Işık (DLI) Ayarları ---
              _buildSectionTitle('Işık Ayarları (DLI)'),
              _buildSettingItem(
                context,
                'Hedef DLI Değeri',
                TextFormField(
                  initialValue: _dliTarget.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 17.0', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _dliTarget = double.tryParse(value ?? '') ?? _dliTarget,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                ),
              ),
              const SizedBox(height: 20),

              // --- Manuel Kontroller ---
              _buildSectionTitle('Manuel Kontroller'),
              SwitchListTile(
                title: Text('Manuel Kontrol Override', style: Theme.of(context).textTheme.bodyMedium),
                value: _isManualOverrideActive,
                onChanged: _toggleManualOverride,
                activeColor: AppTheme.primaryColor,
                inactiveTrackColor: Colors.grey.shade700,
              ),
              const SizedBox(height: 10),
              _buildSettingItem(
                context,
                'Manuel Doz Miktarı (ml)',
                TextFormField(
                  initialValue: _manualDoseAmount.toStringAsFixed(1),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration().copyWith(hintText: 'Örn: 10.0', hintStyle: AppTheme.inputDecorationTheme.hintStyle, border: AppTheme.inputDecorationTheme.border, filled: AppTheme.inputDecorationTheme.filled, fillColor: AppTheme.inputDecorationTheme.fillColor),
                  onSaved: (value) => _manualDoseAmount = double.tryParse(value ?? '') ?? _manualDoseAmount,
                  validator: (value) => value == null || double.tryParse(value) == null ? 'Geçersiz değer' : null,
                  enabled: _isManualOverrideActive,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                        ),
                        onPressed: _isManualOverrideActive ? () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final success = await _apiService.manualDose('A', _manualDoseAmount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? 'Manuel A Besini gönderildi!' : 'Manuel A Besini hatası!'), backgroundColor: success ? Colors.green : Colors.red),
                            );
                          }
                        } : null,
                        icon: const Icon(Icons.science, size: 18),
                        label: const Text('A Besini'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                        ),
                        onPressed: _isManualOverrideActive ? () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final success = await _apiService.manualDose('B', _manualDoseAmount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? 'Manuel B Besini gönderildi!' : 'Manuel B Besini hatası!'), backgroundColor: success ? Colors.green : Colors.red),
                            );
                          }
                        } : null,
                        icon: const Icon(Icons.science, size: 18),
                        label: const Text('B Besini'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                        ),
                        onPressed: _isManualOverrideActive ? () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final success = await _apiService.manualDose('pH_down', _manualDoseAmount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? 'Manuel pH Düşürücü gönderildi!' : 'Manuel pH Düşürücü hatası!'), backgroundColor: success ? Colors.green : Colors.red),
                            );
                          }
                        } : null,
                        icon: const Icon(Icons.bloodtype, size: 18),
                        label: const Text('pH Düşürücü'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isManualFanOn ? AppTheme.primaryColor : AppTheme.cardColor,
                        foregroundColor: _isManualFanOn ? Colors.black : AppTheme.textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                      ),
                      onPressed: _isManualOverrideActive ? () async {
                        setState(() {
                          _isManualFanOn = !_isManualFanOn;
                        });
                        final success = await _apiService.controlClimate('fan', _isManualFanOn);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Fan kontrolü gönderildi!' : 'Fan kontrol hatası!'), backgroundColor: success ? Colors.green : Colors.red),
                        );
                      } : null,
                      icon: Icon(_isManualFanOn ? Icons.power_settings_new : Icons.power_off, size: 18),
                      label: Text(_isManualFanOn ? 'Fan Kapat' : 'Fan Aç'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isManualAcOn ? AppTheme.primaryColor : AppTheme.cardColor,
                        foregroundColor: _isManualAcOn ? Colors.black : AppTheme.textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                      ),
                      onPressed: _isManualOverrideActive ? () async {
                        setState(() {
                          _isManualAcOn = !_isManualAcOn;
                        });
                        final success = await _apiService.controlClimate('ac', _isManualAcOn);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Klima kontrolü gönderildi!' : 'Klima kontrol hatası!'), backgroundColor: success ? Colors.green : Colors.red),
                        );
                      } : null,
                      icon: Icon(_isManualAcOn ? Icons.power_settings_new : Icons.power_off, size: 18),
                      label: Text(_isManualAcOn ? 'Klima Kapat' : 'Klima Aç'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Ayarları Kaydet',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 10),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: control),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton(BuildContext context, TimeOfDay time, bool isDayTime) {
    return ElevatedButton(
      onPressed: () => _selectTime(context, isDayTime),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        time.format(context),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryColor),
      ),
    );
  }
}