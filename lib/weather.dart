import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Enhanced weather strings with AI advice
const Map<String, Map<String, String>> weatherStrings = {
  'hi': {
    'weather_title': 'मौसम जानकारी',
    'current_weather': 'वर्तमान मौसम',
    'ai_advice': 'कृषि सलाह',
    'weather_summary': 'मौसम सारांश',
    'speak_advice': 'सलाह सुनें',
    'generating_advice': 'सलाह तैयार की जा रही है...',
    'advice_error': 'सलाह प्राप्त करने में त्रुटि',
    // ... other strings
  },
  'en': {
    'weather_title': 'Weather Information',
    'current_weather': 'Current Weather',
    'ai_advice': 'AI Farming Advice',
    'weather_summary': 'Weather Summary',
    'speak_advice': 'Speak Advice',
    'generating_advice': 'Generating advice...',
    'advice_error': 'Error getting advice',
    // ... other strings
  },
  'ta': {
    'weather_title': 'வானிலை தகவல்',
    'current_weather': 'தற்போதைய வானிلை',
    'ai_advice': 'விவசாய ஆலோசனை',
    'weather_summary': 'வானிலை சுருக்கம்',
    'speak_advice': 'ஆலோசனை கேளுங்கள்',
    'generating_advice': 'ஆலோசனை தயாராகிறது...',
    'advice_error': 'ஆலோசনை பெறுவதில் பிழை',
    // ... other strings
  },
};

class EnhancedWeatherPage extends StatefulWidget {
  final String languageCode;
  final Position? currentPosition;

  const EnhancedWeatherPage({
    super.key,
    required this.languageCode,
    this.currentPosition,
  });

  @override
  State<EnhancedWeatherPage> createState() => _EnhancedWeatherPageState();
}

class _EnhancedWeatherPageState extends State<EnhancedWeatherPage> {
  // API Keys - Replace with your actual keys
  static const String _weatherApiKey = '555f341d870f6c33624ce9907ba0c63e';

  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _hourlyForecast;
  List<dynamic>? _dailyForecast;
  bool _isLoading = true;
  String? _error;
  Position? _position;

  // AI Advice related
  String? _aiAdvice;
  bool _isGeneratingAdvice = false;
  String? _adviceError;

  late FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initializeWeather();
    _setupTts();
  }

  void _setupTts() async {
    await _tts.setLanguage(_getLanguageCode());
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  String _getLanguageCode() {
    switch (widget.languageCode) {
      case 'hi':
        return 'hi-IN';
      case 'ta':
        return 'ta-IN';
      case 'te':
        return 'te-IN';
      case 'kn':
        return 'kn-IN';
      default:
        return 'en-US';
    }
  }

  Future<void> _initializeWeather() async {
    try {
      if (widget.currentPosition != null) {
        _position = widget.currentPosition;
      } else {
        _position = await _getCurrentLocation();
      }

      if (_position != null) {
        await _fetchWeatherData();
        await _generateAIAdvice();
      } else {
        setState(() {
          _error = 'Location not available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_position == null) return;

    try {
      final currentResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${_position!.latitude}&lon=${_position!.longitude}&appid=$_weatherApiKey&units=metric',
        ),
      );

      final forecastResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${_position!.latitude}&lon=${_position!.longitude}&appid=$_weatherApiKey&units=metric',
        ),
      );

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        setState(() {
          _currentWeather = currentData;
          _hourlyForecast = forecastData['list'].take(8).toList();
          _dailyForecast = _processDailyForecast(forecastData['list']);
          _isLoading = false;
          _error = null;
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> _processDailyForecast(List<dynamic> hourlyData) {
    Map<String, dynamic> dailyData = {};

    for (var item in hourlyData) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = {
          'dt': item['dt'],
          'main': item['main'],
          'weather': item['weather'],
          'temps': [item['main']['temp']],
        };
      } else {
        dailyData[dateKey]['temps'].add(item['main']['temp']);
      }
    }

    List<dynamic> result = [];
    dailyData.forEach((key, value) {
      List<double> temps = List<double>.from(value['temps']);
      value['main']['temp_max'] = temps.reduce((a, b) => a > b ? a : b);
      value['main']['temp_min'] = temps.reduce((a, b) => a < b ? a : b);
      result.add(value);
    });

    return result.take(7).toList();
  }

  // AI Advice Generation using Hugging Face Free API
  Future<void> _generateAIAdvice() async {
    if (_currentWeather == null) return;

    setState(() {
      _isGeneratingAdvice = true;
      _adviceError = null;
    });

    try {
      final advice = await _getAIFarmingAdvice();
      final translatedAdvice = await _translateAdvice(advice);

      setState(() {
        _aiAdvice = translatedAdvice;
        _isGeneratingAdvice = false;
      });
    } catch (e) {
      setState(() {
        _adviceError = e.toString();
        _isGeneratingAdvice = false;
      });
    }
  }

  Future<String> _getAIFarmingAdvice() async {
    final temp = _currentWeather!['main']['temp'];
    final humidity = _currentWeather!['main']['humidity'];
    final windSpeed = _currentWeather!['wind']['speed'];
    final description = _currentWeather!['weather'][0]['description'];
    final pressure = _currentWeather!['main']['pressure'];

    // Create weather context for AI
    final weatherContext =
        """
Weather Conditions:
- Temperature: ${temp}°C
- Humidity: ${humidity}%
- Wind Speed: ${windSpeed}m/s
- Condition: $description
- Pressure: ${pressure}hPa
- Next 24h forecast: ${_getNext24HourSummary()}

Generate specific farming advice based on these conditions.
""";

    // Use Hugging Face's free inference API
    try {
      final response = await http.post(
        Uri.parse(
          'https://api-inference.huggingface.co/models/microsoft/DialoGPT-medium',
        ),
        headers: {
          'Authorization':
              'Bearer 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', // Get from https://huggingface.co/settings/tokens
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': 'Generate farming advice for: $weatherContext',
          'parameters': {'max_length': 150, 'temperature': 0.7},
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[0]['generated_text'] ?? _getFallbackAdvice();
      } else {
        return _getFallbackAdvice();
      }
    } catch (e) {
      return _getFallbackAdvice();
    }
  }

  String _getNext24HourSummary() {
    if (_hourlyForecast == null || _hourlyForecast!.isEmpty) return '';

    final next24h = _hourlyForecast!.take(8).toList();
    final avgTemp =
        next24h.map((e) => e['main']['temp']).reduce((a, b) => a + b) /
        next24h.length;
    final hasRain = next24h.any(
      (e) => e['weather'][0]['main'].toLowerCase().contains('rain'),
    );

    return 'Average temp: ${avgTemp.toStringAsFixed(1)}°C, Rain expected: ${hasRain ? 'Yes' : 'No'}';
  }

  String _getFallbackAdvice() {
    final temp = _currentWeather!['main']['temp'];
    final humidity = _currentWeather!['main']['humidity'];
    final description = _currentWeather!['weather'][0]['description']
        .toLowerCase();

    List<String> advice = [];

    if (temp > 35) {
      advice.add(
        'High temperature detected. Increase irrigation frequency and provide shade for sensitive crops.',
      );
    } else if (temp < 10) {
      advice.add(
        'Low temperature alert. Protect crops from frost damage using covers or heating.',
      );
    }

    if (humidity > 80) {
      advice.add(
        'High humidity may promote fungal diseases. Ensure good air circulation and avoid overhead watering.',
      );
    } else if (humidity < 30) {
      advice.add(
        'Low humidity detected. Increase watering frequency and consider mulching.',
      );
    }

    if (description.contains('rain')) {
      advice.add(
        'Rain expected. Delay pesticide application and ensure proper drainage.',
      );
    } else if (description.contains('clear')) {
      advice.add(
        'Clear weather is ideal for spraying pesticides and fertilizers.',
      );
    }

    if (advice.isEmpty) {
      advice.add(
        'Weather conditions are moderate. Continue regular farming activities with standard care.',
      );
    }

    return advice.join(' ');
  }

  Future<String> _translateAdvice(String advice) async {
    if (widget.languageCode == 'en') return advice;

    // Use Google Translate free tier or LibreTranslate
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.de/translate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': advice,
          'source': 'en',
          'target': widget.languageCode,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translatedText'] ?? advice;
      }
    } catch (e) {
      // Fallback to predefined translations
      return _getFallbackTranslation(advice);
    }

    return advice;
  }

  String _getFallbackTranslation(String advice) {
    // Simple keyword-based translation for common advice
    final translationMap = {
      'hi': {
        'irrigation': 'सिंचाई',
        'temperature': 'तापमान',
        'humidity': 'नमी',
        'rain': 'बारिश',
        'crops': 'फसलें',
        'High temperature': 'उच्च तापमान',
        'Low humidity': 'कम नमी',
        'Rain expected': 'बारिश की संभावना',
      },
      'ta': {
        'irrigation': 'நீர்ப்பாசனம்',
        'temperature': 'வெப்பநிலை',
        'humidity': 'ஈரப்பதம்',
        'rain': 'மழை',
        'crops': 'பயிர்கள்',
        'High temperature': 'அதிக வெப்பநிலை',
        'Low humidity': 'குறைந்த ஈரப்பதம்',
        'Rain expected': 'மழை எதிர்பார்க்கப்படுகிறது',
      },
    };

    String translated = advice;
    final langMap = translationMap[widget.languageCode];
    if (langMap != null) {
      langMap.forEach((key, value) {
        translated = translated.replaceAll(key, value);
      });
    }

    return translated;
  }

  Future<void> _speakAdvice() async {
    if (_aiAdvice == null) return;

    try {
      await _tts.setLanguage(_getLanguageCode());
      await _tts.speak(_aiAdvice!);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  Widget _buildAIAdviceCard() {
    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings['ai_advice']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isGeneratingAdvice ? null : _generateAIAdvice,
                  icon: _isGeneratingAdvice
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh, color: Colors.white),
                ),
                IconButton(
                  onPressed: _aiAdvice != null ? _speakAdvice : null,
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isGeneratingAdvice)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      strings['generating_advice']!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            else if (_adviceError != null)
              Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings['advice_error']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              )
            else if (_aiAdvice != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _aiAdvice!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (_currentWeather == null) return const SizedBox();

    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;
    final temp = _currentWeather!['main']['temp'].round();
    final feelsLike = _currentWeather!['main']['feels_like'].round();
    final description = _currentWeather!['weather'][0]['description'];
    final iconCode = _currentWeather!['weather'][0]['icon'];

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              strings['current_weather']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      _getWeatherIcon(iconCode),
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${temp}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Feels like ${feelsLike}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWeatherIcon(String iconCode) {
    const iconMap = {
      '01d': '☀️',
      '01n': '🌙',
      '02d': '⛅',
      '02n': '☁️',
      '03d': '☁️',
      '03n': '☁️',
      '04d': '☁️',
      '04n': '☁️',
      '09d': '🌧️',
      '09n': '🌧️',
      '10d': '🌦️',
      '10n': '🌧️',
      '11d': '⛈️',
      '11n': '⛈️',
      '13d': '❄️',
      '13n': '❄️',
      '50d': '🌫️',
      '50n': '🌫️',
    };
    return iconMap[iconCode] ?? '☀️';
  }

  @override
  Widget build(BuildContext context) {
    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings['weather_title']!),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _initializeWeather();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading weather data...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initializeWeather,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCurrentWeatherCard(),
                    _buildAIAdviceCard(),
                    // Add other existing widgets here
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
