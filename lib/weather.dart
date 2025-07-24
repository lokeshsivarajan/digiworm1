import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Add these localized strings for weather page
const Map<String, Map<String, String>> weatherStrings = {
  'hi': {
    'weather_title': 'मौसम जानकारी',
    'current_weather': 'वर्तमान मौसम',
    'feels_like': 'महसूस होता है',
    'humidity': 'आर्द्रता',
    'pressure': 'दबाव',
    'wind_speed': 'हवा की गति',
    'visibility': 'दृश्यता',
    'uv_index': 'यूवी इंडेक्स',
    'sunrise': 'सूर्योदय',
    'sunset': 'सूर्यास्त',
    'hourly_forecast': 'घंटे के अनुसार पूर्वानुमान',
    'daily_forecast': '7 दिन का पूर्वानुमान',
    'high': 'अधिकतम',
    'low': 'न्यूनतम',
    'loading': 'लोड हो रहा है...',
    'error': 'त्रुटि',
    'retry': 'पुनः प्रयास करें',
    'location_error': 'स्थान की जानकारी नहीं मिली',
    'farming_tips': 'कृषि सुझाव',
    'good_for_farming': 'खेती के लिए अच्छा मौसम',
    'check_irrigation': 'सिंचाई की जांच करें',
    'protect_crops': 'फसलों की सुरक्षा करें',
  },
  'en': {
    'weather_title': 'Weather Information',
    'current_weather': 'Current Weather',
    'feels_like': 'Feels like',
    'humidity': 'Humidity',
    'pressure': 'Pressure',
    'wind_speed': 'Wind Speed',
    'visibility': 'Visibility',
    'uv_index': 'UV Index',
    'sunrise': 'Sunrise',
    'sunset': 'Sunset',
    'hourly_forecast': 'Hourly Forecast',
    'daily_forecast': '7-Day Forecast',
    'high': 'High',
    'low': 'Low',
    'loading': 'Loading...',
    'error': 'Error',
    'retry': 'Retry',
    'location_error': 'Location not available',
    'farming_tips': 'Farming Tips',
    'good_for_farming': 'Good weather for farming',
    'check_irrigation': 'Check irrigation needs',
    'protect_crops': 'Protect crops from weather',
  },
  'kn': {
    'weather_title': 'ಹವಾಮಾನ ಮಾಹಿತಿ',
    'current_weather': 'ಪ್ರಸ್ತುತ ಹವಾಮಾನ',
    'feels_like': 'ಅನಿಸುತ್ತದೆ',
    'humidity': 'ಆರ್ದ್ರತೆ',
    'pressure': 'ಒತ್ತಡ',
    'wind_speed': 'ಗಾಳಿಯ ವೇಗ',
    'visibility': 'ಗೋಚರತೆ',
    'uv_index': 'ಯುವಿ ಇಂಡೆಕ್ಸ್',
    'sunrise': 'ಸೂರ್ಯೋದಯ',
    'sunset': 'ಸೂರ್ಯಾಸ್ತ',
    'hourly_forecast': 'ಗಂಟೆಯ ಮುನ್ಸೂಚನೆ',
    'daily_forecast': '7 ದಿನಗಳ ಮುನ್ಸೂಚನೆ',
    'high': 'ಗರಿಷ್ಠ',
    'low': 'ಕನಿಷ್ಠ',
    'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
    'error': 'ದೋಷ',
    'retry': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
    'location_error': 'ಸ್ಥಳ ಲಭ್ಯವಿಲ್ಲ',
    'farming_tips': 'ಕೃಷಿ ಸಲಹೆಗಳು',
    'good_for_farming': 'ಕೃಷಿಗೆ ಒಳ್ಳೆಯ ಹವಾಮಾನ',
    'check_irrigation': 'ನೀರಾವರಿ ಅಗತ್ಯಗಳನ್ನು ಪರಿಶೀಲಿಸಿ',
    'protect_crops': 'ಹವಾಮಾನದಿಂದ ಬೆಳೆಗಳನ್ನು ರಕ್ಷಿಸಿ',
  },
  'ta': {
    'weather_title': 'வானிலை தகவல்',
    'current_weather': 'தற்போதைய வானிலை',
    'feels_like': 'உணர்வு',
    'humidity': 'ஈரப்பதம்',
    'pressure': 'அழுத்தம்',
    'wind_speed': 'காற்றின் வேகம்',
    'visibility': 'தெரிவுத்திறன்',
    'uv_index': 'யூவி குறியீடு',
    'sunrise': 'சூரிய உதயம்',
    'sunset': 'சூரிய அஸ்தமனம்',
    'hourly_forecast': 'மணிநேர முன்னறிவிப்பு',
    'daily_forecast': '7 நாள் முன்னறிவிப்பு',
    'high': 'அதிகபட்சம்',
    'low': 'குறைந்தபட்சம்',
    'loading': 'ஏற்றுகிறது...',
    'error': 'பிழை',
    'retry': 'மீண்டும் முயற்சி',
    'location_error': 'இடம் கிடைக்கவில்லை',
    'farming_tips': 'விவசாய குறிப்புகள்',
    'good_for_farming': 'விவசாயத்திற்கு நல்ல வானிலை',
    'check_irrigation': 'நீர்ப்பாசன தேவைகளை சரிபார்க்கவும்',
    'protect_crops': 'வானிலையிலிருந்து பயிர்களை பாதுகாக்கவும்',
  },
  'te': {
    'weather_title': 'వాతావరణ సమాచారం',
    'current_weather': 'ప్రస్తుత వాతావరణం',
    'feels_like': 'అనిపిస్తుంది',
    'humidity': 'తేమ',
    'pressure': 'ఒత్తిడి',
    'wind_speed': 'గాలి వేగం',
    'visibility': 'దృశ్యత',
    'uv_index': 'యూవి ఇండెక్స్',
    'sunrise': 'సూర్యోదయం',
    'sunset': 'సూర్యాస్తమయం',
    'hourly_forecast': 'గంటల వారీ సూచన',
    'daily_forecast': '7 రోజుల సూచన',
    'high': 'గరిష్టం',
    'low': 'కనిష్టం',
    'loading': 'లోడ్ అవుతోంది...',
    'error': 'లోపం',
    'retry': 'మళ్లీ ప్రయత్నించండీ',
    'location_error': 'స్థానం అందుబాటులో లేదు',
    'farming_tips': 'వ్యవసాయ చిట్కాలు',
    'good_for_farming': 'వ్యవసాయానికి మంచి వాతావరణం',
    'check_irrigation': 'నీటిపారుదల అవసరాలను తనిఖీ చేయండి',
    'protect_crops': 'వాతావరణం నుండి పంటలను రక్షించండి',
  },
};

class WeatherPage extends StatefulWidget {
  final String languageCode;
  final Position? currentPosition;

  const WeatherPage({
    super.key,
    required this.languageCode,
    this.currentPosition,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Replace with your OpenWeatherMap API key
  static const String _apiKey = '555f341d870f6c33624ce9907ba0c63e';

  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _hourlyForecast;
  List<dynamic>? _dailyForecast;
  bool _isLoading = true;
  String? _error;
  Position? _position;

  late FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initializeWeather();
    _setupTts();
  }

  void _setupTts() {
    _tts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
    });
  }

  Future<void> _testTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.speak("This is a test message for TTS functionality.");
    } catch (e) {
      debugPrint("TTS Test Error: $e");
    }
  }

  Future<void> _initializeWeather() async {
    try {
      // Get current position if not provided
      if (widget.currentPosition != null) {
        _position = widget.currentPosition;
      } else {
        _position = await _getCurrentLocation();
      }

      if (_position != null) {
        await _fetchWeatherData();
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
      // Fetch current weather
      final currentResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${_position!.latitude}&lon=${_position!.longitude}&appid=$_apiKey&units=metric',
        ),
      );

      // Fetch forecast data
      final forecastResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${_position!.latitude}&lon=${_position!.longitude}&appid=$_apiKey&units=metric',
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

  String _getWeatherIcon(String iconCode) {
    // Map OpenWeatherMap icon codes to weather conditions
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
                      '${strings['feels_like']!} ${feelsLike}°C',
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

  Widget _buildWeatherDetailsGrid() {
    if (_currentWeather == null) return const SizedBox();

    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;
    final humidity = _currentWeather!['main']['humidity'];
    final pressure = _currentWeather!['main']['pressure'];
    final windSpeed = _currentWeather!['wind']['speed'];
    final visibility = (_currentWeather!['visibility'] / 1000).toStringAsFixed(
      1,
    );

    final sunrise = DateTime.fromMillisecondsSinceEpoch(
      _currentWeather!['sys']['sunrise'] * 1000,
    );
    final sunset = DateTime.fromMillisecondsSinceEpoch(
      _currentWeather!['sys']['sunset'] * 1000,
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDetailCard(
              Icons.water_drop,
              strings['humidity']!,
              '$humidity%',
            ),
            _buildDetailCard(
              Icons.compress,
              strings['pressure']!,
              '${pressure}hPa',
            ),
            _buildDetailCard(
              Icons.air,
              strings['wind_speed']!,
              '${windSpeed}m/s',
            ),
            _buildDetailCard(
              Icons.visibility,
              strings['visibility']!,
              '${visibility}km',
            ),
            _buildDetailCard(
              Icons.wb_sunny,
              strings['sunrise']!,
              DateFormat('HH:mm').format(sunrise),
            ),
            _buildDetailCard(
              Icons.brightness_3,
              strings['sunset']!,
              DateFormat('HH:mm').format(sunset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    if (_hourlyForecast == null) return const SizedBox();

    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings['hourly_forecast']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _hourlyForecast!.length,
                itemBuilder: (context, index) {
                  final item = _hourlyForecast![index];
                  final time = DateTime.fromMillisecondsSinceEpoch(
                    item['dt'] * 1000,
                  );
                  final temp = item['main']['temp'].round();
                  final iconCode = item['weather'][0]['icon'];

                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(time),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getWeatherIcon(iconCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          '${temp}°C',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecast() {
    if (_dailyForecast == null) return const SizedBox();

    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings['daily_forecast']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dailyForecast!.length,
              itemBuilder: (context, index) {
                final item = _dailyForecast![index];
                final date = DateTime.fromMillisecondsSinceEpoch(
                  item['dt'] * 1000,
                );
                final maxTemp = item['main']['temp_max'].round();
                final minTemp = item['main']['temp_min'].round();
                final iconCode = item['weather'][0]['icon'];
                final description = item['weather'][0]['description'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('EEE, MMM d').format(date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _getWeatherIcon(iconCode),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${strings['high']!}: ${maxTemp}°',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${strings['low']!}: ${minTemp}°',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmingTips() {
    if (_currentWeather == null) return const SizedBox();

    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;
    final temp = _currentWeather!['main']['temp'];
    final humidity = _currentWeather!['main']['humidity'];
    final windSpeed = _currentWeather!['wind']['speed'];

    List<String> tips = [];

    if (temp > 30) {
      tips.add(strings['check_irrigation']!);
    }
    if (humidity > 80) {
      tips.add(strings['protect_crops']!);
    }
    if (windSpeed < 2 && temp > 20 && temp < 30) {
      tips.add(strings['good_for_farming']!);
    }

    if (tips.isEmpty) {
      tips.add(strings['good_for_farming']!);
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.agriculture, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  strings['farming_tips']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips
                .map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _speakCurrentWeather() async {
    if (_currentWeather == null) return;

    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;
    final temp = _currentWeather!['main']['temp'].round();
    final description = _currentWeather!['weather'][0]['description'];

    String message = "${strings['current_weather']!}: $description, ${temp}°C.";

    await _tts.setLanguage(widget.languageCode);
    await _tts.speak(message);
  }

  final Map<String, String> weatherDescriptionMap = {
    'clear sky': 'clear skies',
    'few clouds': 'a few clouds',
    'scattered clouds': 'scattered clouds',
    'broken clouds': 'partly cloudy',
    'overcast clouds': 'overcast',
    'light rain': 'light rain',
    'moderate rain': 'moderate rain',
    'heavy intensity rain': 'heavy rain',
    'thunderstorm': 'a thunderstorm',
    'snow': 'snowfall',
    'mist': 'misty conditions',
    'haze': 'hazy conditions',
    'fog': 'foggy conditions',
  };

  Future<void> _speakForecast() async {
    if (_dailyForecast == null) return;

    String message = widget.languageCode == 'hi'
        ? "आने वाले छह दिनों के मौसम की जानकारी इस प्रकार है: "
        : "Here is the weather forecast for the next six days: ";

    for (var i = 0; i < 6 && i < _dailyForecast!.length; i++) {
      final item = _dailyForecast![i];
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final maxTemp = item['main']['temp_max'].round();
      final minTemp = item['main']['temp_min'].round();
      String description = item['weather'][0]['description'];

      // Convert description to user-friendly text
      description =
          weatherDescriptionMap[description.toLowerCase()] ?? description;

      if (widget.languageCode == 'hi') {
        message +=
            "${DateFormat('EEEE', 'hi_IN').format(date)} को ${description} की संभावना है, अधिकतम तापमान ${maxTemp} डिग्री और न्यूनतम तापमान ${minTemp} डिग्री होगा। ";
      } else {
        message +=
            "On ${DateFormat('EEEE').format(date)}, expect ${description} with a high of ${maxTemp} degrees and a low of ${minTemp} degrees. ";
      }
    }

    try {
      await _tts.setLanguage(
        widget.languageCode == 'hi'
            ? 'hi-IN'
            : widget.languageCode == 'ta'
            ? 'ta-IN'
            : widget.languageCode == 'kn'
            ? 'kn-IN'
            : widget.languageCode == 'te'
            ? 'te-IN'
            : 'en-US',
      );
      await _tts.speak(message);
    } catch (e) {
      debugPrint("TTS Forecast Error: $e");
    }
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
            icon: const Icon(Icons.volume_up),
            onPressed: _speakCurrentWeather,
            tooltip: "Speak Current Weather",
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _speakForecast,
            tooltip: "Speak Forecast",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _fetchWeatherData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.speaker),
            onPressed: _testTts,
            tooltip: "Test TTS",
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      strings['loading']!,
                      style: const TextStyle(fontSize: 16),
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
                    Text(
                      strings['error']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _initializeWeather();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(strings['retry']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCurrentWeatherCard(),
                    _buildWeatherDetailsGrid(),
                    _buildHourlyForecast(),
                    _buildDailyForecast(),
                    _buildFarmingTips(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
