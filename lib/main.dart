import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TensApp());
}

class TensApp extends StatelessWidget {
  const TensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TENS Device Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        useMaterial3: true,
      ),
      home: const TensHomePage(),
    );
  }
}

class TensHomePage extends StatefulWidget {
  const TensHomePage({super.key});

  @override
  State<TensHomePage> createState() => _TensHomePageState();
}

class _TensHomePageState extends State<TensHomePage> {
  // State variables
  int _powerLevel = 50;
  String _selectedMode = 'continuous';
  int _timerMinutes = 5;
  int _timerSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  List<FlSpot> _powerReadings = [];
  int _elapsedSeconds = 0;
  int _totalSeconds = 0;
  Timer? _timer;

  final Map<String, String> _modeLabels = {
    'continuous': 'Continuous',
    'burst': 'Burst',
    'modulation': 'Modulation',
    'massage': 'Massage',
  };

  void _adjustPower(int delta) {
    if (_isRunning) return;
    setState(() {
      _powerLevel = (_powerLevel + delta).clamp(0, 100);
    });
  }

  void _setPreset(int level) {
    if (_isRunning) return;
    setState(() {
      _powerLevel = level;
    });
  }

  void _selectMode(String mode) {
    if (_isRunning) return;
    setState(() {
      _selectedMode = mode;
    });
  }

  void _startTimer() {
    final total = _timerMinutes * 60 + _timerSeconds;
    if (total <= 0) return;
    setState(() {
      _isRunning = true;
      _remainingSeconds = total;
      _totalSeconds = total;
      _elapsedSeconds = 0;
      _powerReadings = [FlSpot(0, _powerLevel.toDouble())];
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        _powerReadings.add(FlSpot(_elapsedSeconds.toDouble(), _powerLevel.toDouble()));
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
        if (_remainingSeconds <= 0) {
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
      _powerReadings = [];
      _elapsedSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: _isRunning ? _buildRunningView() : _buildSetupView(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF3B82F6)),
            child: const Text(
              'EMPOWER TENS',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, size: 28),
            title: const Text('Home', style: TextStyle(fontSize: 18)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history, size: 28),
            title: const Text('History', style: TextStyle(fontSize: 18)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, size: 28),
            title: const Text('Account', style: TextStyle(fontSize: 18)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, size: 28),
            title: const Text('Settings', style: TextStyle(fontSize: 18)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TENS Device Controller',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 32),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupView() {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPowerSection(),
                const SizedBox(height: 16),
                _buildPresetButtons(),
                const SizedBox(height: 16),
                _buildModeGrid(),
                const SizedBox(height: 16),
                _buildDeviceStatus(),
                const SizedBox(height: 16),
                _buildTimerSection(),
                const SizedBox(height: 16),
                _buildStartButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Text('Power Level', style: TextStyle(fontSize: 18, color: Colors.grey)),
          Text(
            '$_powerLevel%',
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _powerLevel / 100,
            minHeight: 16,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAdjustButton('-', () => _adjustPower(-1)),
              _buildAdjustButton('+', () => _adjustPower(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      height: 64,
      child: ElevatedButton(
        onPressed: _isRunning ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildPresetButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Presets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          children: [25, 50, 75, 100].map((level) {
            final isSelected = _powerLevel == level;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : () => _setPreset(level),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF3B82F6) : Colors.grey[200],
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      disabledBackgroundColor: Colors.grey[100],
                    ),
                    child: Text('$level%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModeGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Therapy Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3,
          children: _modeLabels.entries.map((entry) {
            final isSelected = _selectedMode == entry.key;
            return SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isRunning ? null : () => _selectMode(entry.key),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? const Color(0xFF10B981) : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey[100],
                ),
                child: Text(entry.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeviceStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.green[600], size: 14),
          const SizedBox(width: 8),
          const Text(
            'TENS Device - Ready',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timer Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTimeInput('Minutes', _timerMinutes, 0, 120, (val) => setState(() => _timerMinutes = val))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeInput('Seconds', _timerSeconds, 0, 59, (val) => setState(() => _timerSeconds = val))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                SizedBox(
                  height: 28,
                  width: 36,
                  child: ElevatedButton(
                    onPressed: value < max ? () => onChanged(value + 1) : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Icon(Icons.arrow_drop_up, size: 20),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 28,
                  width: 36,
                  child: ElevatedButton(
                    onPressed: value > min ? () => onChanged(value - 1) : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Icon(Icons.arrow_drop_down, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: (_timerMinutes * 60 + _timerSeconds) > 0 ? _startTimer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Start Timer'),
      ),
    );
  }

  Widget _buildRunningView() {
    return Column(
      children: [
        _buildHeader(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Power: $_powerLevel%  |  Mode: ${_modeLabels[_selectedMode]}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildGraph(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _stopTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Stop Timer'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraph() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Power Over Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _powerReadings.length < 2
                ? const Center(child: Text('Collecting data...', style: TextStyle(color: Colors.grey)))
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: _totalSeconds.toDouble(),
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 50,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 50,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.grey));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == _totalSeconds.toDouble()) {
                                return Text(_formatTime(value.toInt()), style: const TextStyle(fontSize: 11, color: Colors.grey));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _powerReadings,
                          isCurved: false,
                          color: const Color(0xFF3B82F6),
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
