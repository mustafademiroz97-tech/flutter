import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/climate_model.dart';

/// ControlScreen - Main climate control interface
/// Manages climate settings, sensor thresholds, manual overrides, and system configuration
class ControlScreen extends StatefulWidget {
  const ControlScreen({Key? key}) : super(key: key);

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late ApiService _apiService;
  bool _isLoading = false;
  String? _errorMessage;

  // Climate control state
  double _targetTemperature = 22.0;
  double _targetHumidity = 45.0;
  bool _systemEnabled = true;
  bool _manualOverride = false;

  // Sensor thresholds
  double _minTemperature = 18.0;
  double _maxTemperature = 28.0;
  double _minHumidity = 30.0;
  double _maxHumidity = 60.0;

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
    _loadCurrentSettings();
  }

  /// Load current climate control settings from API
  Future<void> _loadCurrentSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final settings = await _apiService.getClimateSettings();
      setState(() {
        _targetTemperature = settings['targetTemperature'] ?? 22.0;
        _targetHumidity = settings['targetHumidity'] ?? 45.0;
        _systemEnabled = settings['systemEnabled'] ?? true;
        _manualOverride = settings['manualOverride'] ?? false;
        _minTemperature = settings['minTemperature'] ?? 18.0;
        _maxTemperature = settings['maxTemperature'] ?? 28.0;
        _minHumidity = settings['minHumidity'] ?? 30.0;
        _maxHumidity = settings['maxHumidity'] ?? 60.0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load settings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Update target temperature setting
  Future<void> _updateTargetTemperature(double value) async {
    setState(() {
      _targetTemperature = value;
    });

    try {
      await _apiService.setTargetTemperature(value);
      _showSnackBar('Temperature set to ${value.toStringAsFixed(1)}°C');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update temperature: $e';
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  /// Update target humidity setting
  Future<void> _updateTargetHumidity(double value) async {
    setState(() {
      _targetHumidity = value;
    });

    try {
      await _apiService.setTargetHumidity(value);
      _showSnackBar('Humidity set to ${value.toStringAsFixed(1)}%');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update humidity: $e';
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  /// Toggle system enabled/disabled state
  Future<void> _toggleSystemEnabled(bool value) async {
    setState(() {
      _systemEnabled = value;
    });

    try {
      await _apiService.setSystemEnabled(value);
      _showSnackBar(value ? 'System enabled' : 'System disabled');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to toggle system: $e';
        _systemEnabled = !value;
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  /// Toggle manual override mode
  Future<void> _toggleManualOverride(bool value) async {
    setState(() {
      _manualOverride = value;
    });

    try {
      await _apiService.setManualOverride(value);
      _showSnackBar(value ? 'Manual override enabled' : 'Manual override disabled');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to toggle manual override: $e';
        _manualOverride = !value;
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  /// Update temperature sensor threshold
  Future<void> _updateTemperatureThreshold(
    double minTemp,
    double maxTemp,
  ) async {
    setState(() {
      _minTemperature = minTemp;
      _maxTemperature = maxTemp;
    });

    try {
      await _apiService.setSensorThresholds(
        'temperature',
        minTemp,
        maxTemp,
      );
      _showSnackBar(
        'Temperature range set to ${minTemp.toStringAsFixed(1)}°C - ${maxTemp.toStringAsFixed(1)}°C',
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update temperature threshold: $e';
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  /// Update humidity sensor threshold
  Future<void> _updateHumidityThreshold(
    double minHum,
    double maxHum,
  ) async {
    setState(() {
      _minHumidity = minHum;
      _maxHumidity = maxHum;
    });

    try {
      await _apiService.setSensorThresholds(
        'humidity',
        minHum,
        maxHum,
      );
      _showSnackBar(
        'Humidity range set to ${minHum.toStringAsFixed(1)}% - ${maxHum.toStringAsFixed(1)}%',
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update humidity threshold: $e';
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  /// Save all settings to device storage
  Future<void> _saveSettings() async {
    try {
      await _apiService.saveClimateSettings({
        'targetTemperature': _targetTemperature,
        'targetHumidity': _targetHumidity,
        'systemEnabled': _systemEnabled,
        'manualOverride': _manualOverride,
        'minTemperature': _minTemperature,
        'maxTemperature': _maxTemperature,
        'minHumidity': _minHumidity,
        'maxHumidity': _maxHumidity,
      });
      _showSnackBar('Settings saved successfully');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save settings: $e';
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  /// Reset all settings to default values
  Future<void> _resetSettings() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to defaults? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.resetClimateSettings();
                await _loadCurrentSettings();
                _showSnackBar('Settings reset to defaults');
              } catch (e) {
                setState(() {
                  _errorMessage = 'Failed to reset settings: $e';
                });
                _showSnackBar('Error: $e', isError: true);
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Show snackbar notification
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Climate Control'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message display
                  if (_errorMessage != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 16),

                  // System Status Section
                  _buildSectionHeader('System Control'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('System Enabled'),
                            subtitle: Text(
                              _systemEnabled ? 'System is running' : 'System is stopped',
                            ),
                            value: _systemEnabled,
                            onChanged: _toggleSystemEnabled,
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('Manual Override'),
                            subtitle: const Text(
                              'Enable manual control of climate settings',
                            ),
                            value: _manualOverride,
                            onChanged: _toggleManualOverride,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Climate Control Section
                  _buildSectionHeader('Climate Targets'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Temperature Control
                          _buildControlSlider(
                            label: 'Target Temperature',
                            value: _targetTemperature,
                            min: 15.0,
                            max: 35.0,
                            unit: '°C',
                            onChanged: _updateTargetTemperature,
                          ),
                          const SizedBox(height: 20),

                          // Humidity Control
                          _buildControlSlider(
                            label: 'Target Humidity',
                            value: _targetHumidity,
                            min: 20.0,
                            max: 80.0,
                            unit: '%',
                            onChanged: _updateTargetHumidity,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sensor Thresholds Section
                  _buildSectionHeader('Sensor Thresholds'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Temperature Threshold
                          const Text(
                            'Temperature Range',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildThresholdInput(
                                  label: 'Min',
                                  value: _minTemperature,
                                  unit: '°C',
                                  onChanged: (value) {
                                    if (value < _maxTemperature) {
                                      _updateTemperatureThreshold(
                                        value,
                                        _maxTemperature,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildThresholdInput(
                                  label: 'Max',
                                  value: _maxTemperature,
                                  unit: '°C',
                                  onChanged: (value) {
                                    if (value > _minTemperature) {
                                      _updateTemperatureThreshold(
                                        _minTemperature,
                                        value,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Humidity Threshold
                          const Text(
                            'Humidity Range',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildThresholdInput(
                                  label: 'Min',
                                  value: _minHumidity,
                                  unit: '%',
                                  onChanged: (value) {
                                    if (value < _maxHumidity) {
                                      _updateHumidityThreshold(
                                        value,
                                        _maxHumidity,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildThresholdInput(
                                  label: 'Max',
                                  value: _maxHumidity,
                                  unit: '%',
                                  onChanged: (value) {
                                    if (value > _minHumidity) {
                                      _updateHumidityThreshold(
                                        _minHumidity,
                                        value,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Management Section
                  _buildSectionHeader('Settings Management'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Save Settings'),
                            subtitle: const Text('Save current settings to device storage'),
                            trailing: const Icon(Icons.save),
                            onTap: _saveSettings,
                          ),
                          const Divider(height: 0),
                          ListTile(
                            title: const Text('Reset to Defaults'),
                            subtitle: const Text('Restore all settings to factory defaults'),
                            trailing: const Icon(Icons.restore),
                            onTap: _resetSettings,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildSectionHeader('Quick Stats'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildStatRow(
                            'System Status',
                            _systemEnabled ? 'Running' : 'Stopped',
                            _systemEnabled ? Colors.green : Colors.grey,
                          ),
                          const Divider(),
                          _buildStatRow(
                            'Control Mode',
                            _manualOverride ? 'Manual' : 'Automatic',
                            _manualOverride ? Colors.orange : Colors.blue,
                          ),
                          const Divider(),
                          _buildStatRow(
                            'Target Temperature',
                            '${_targetTemperature.toStringAsFixed(1)}°C',
                            Colors.purple,
                          ),
                          const Divider(),
                          _buildStatRow(
                            'Target Humidity',
                            '${_targetHumidity.toStringAsFixed(1)}%',
                            Colors.cyan,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// Build section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build control slider widget
  Widget _buildControlSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Build threshold input widget
  Widget _buildThresholdInput({
    required String label,
    required double value,
    required String unit,
    required Function(double) onChanged,
  }) {
    final controller = TextEditingController(
      text: value.toStringAsFixed(1),
    );

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSubmitted: (value) {
        final numValue = double.tryParse(value);
        if (numValue != null) {
          onChanged(numValue);
        }
      },
    );
  }

  /// Build stat row widget
  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
