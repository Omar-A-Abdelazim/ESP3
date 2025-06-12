import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';

// متغير عالمي لتخزين عنوان IP
String esp32IpAddress = '192.168.192.105';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warsha Team App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        primaryColor: Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
          ),
        ),
        child: FadeTransition(
          opacity: _animation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Color(0xFF1565C0),
                    child: Text(
                      'W',
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Warsha Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  void _validateAndLogin() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      if (username.isEmpty || password.isEmpty) {
        _errorMessage = "Incomplete data";
      } else if (username == "WARSHA" && password == "123456789") {
        _errorMessage = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        _errorMessage = "Incorrect data";
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Color(0xFF1565C0),
                        child: Text(
                          'W',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Warsha Team',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Login to your account',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              CustomInputField(
                hintText: "Username",
                icon: Icons.person_outline,
                controller: _usernameController,
              ),
              SizedBox(height: 20),
              CustomInputField(
                hintText: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
                controller: _passwordController,
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xFF2196F3),
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Or sign in with',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GoogleLogoButton(onPressed: () {}),
                      SizedBox(width: 20),
                      SocialLoginButton(
                        onPressed: () {},
                        icon: 'f',
                        color: Colors.white,
                        textColor: Color(0xFF3b5998),
                      ),
                      SizedBox(width: 20),
                      SocialLoginButton(
                        onPressed: () {},
                        icon: 't',
                        color: Colors.white,
                        textColor: Color(0xFF1DA1F2),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Sign up here",
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  bool isConnected = false;
  double pollutionLevel = 0.0;
  double temperature = 0.0;
  bool isBalanced = true;
  double boardTemperature = 0.0;
  bool fanStatus = false;
  bool alertStatus = false;
  String lastUpdate = "Never";
  String connectionError = "";

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  IOWebSocketChannel? _channel;
  int _retryCount = 0;
  static const int _maxRetries = 5;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _pulseController.repeat(reverse: true);

    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    if (_retryCount >= _maxRetries) {
      setState(() {
        isConnected = false;
        lastUpdate = "Failed to connect after $_maxRetries attempts";
        connectionError = "Max retries reached. Check ESP32 IP and network.";
      });
      print("❌ Connection failed after $_maxRetries attempts");
      return;
    }

    print(
        "📡 Attempting WebSocket connection (Attempt ${_retryCount + 1}/$_maxRetries)");
    try {
      _channel = IOWebSocketChannel.connect(
        'ws://$esp32IpAddress:81',
        pingInterval: Duration(seconds: 5),
      );
      print("✅ WebSocket initiated: ws://$esp32IpAddress:81");

      _channel!.stream.listen(
        (data) {
          print("📥 Data: $data");
          try {
            final jsonData = jsonDecode(data);
            setState(() {
              isConnected = jsonData['isConnected'] ?? false;
              pollutionLevel = (jsonData['pollution'] ?? 0.0).toDouble();
              temperature = (jsonData['temperature'] ?? 0.0).toDouble();
              boardTemperature =
                  (jsonData['boardTemperature'] ?? 0.0).toDouble();
              isBalanced = jsonData['isBalanced'] ?? true;
              fanStatus = jsonData['fanStatus'] ?? false;
              alertStatus = jsonData['alertStatus'] ?? false;
              lastUpdate = DateTime.now().toString().substring(0, 19);
              connectionError = "";
              _retryCount = 0;
            });
          } catch (e) {
            print("⚠️ JSON error: $e");
            setState(() {
              lastUpdate =
                  "Data error at ${DateTime.now().toString().substring(0, 19)}";
              connectionError = "Invalid data: $e";
            });
          }
        },
        onDone: () {
          setState(() {
            isConnected = false;
            lastUpdate =
                "Disconnected at ${DateTime.now().toString().substring(0, 19)}";
            connectionError = "WebSocket closed.";
          });
          print("🔌 WebSocket closed, retrying...");
          _retryCount++;
          Future.delayed(Duration(seconds: 2), _connectToWebSocket);
        },
        onError: (error) {
          setState(() {
            isConnected = false;
            lastUpdate =
                "Error at ${DateTime.now().toString().substring(0, 19)}";
            connectionError = "WebSocket error: $error";
          });
          print("❌ WebSocket Error: $error");
          _retryCount++;
          Future.delayed(Duration(seconds: 2), _connectToWebSocket);
        },
        cancelOnError: false,
      );
    } catch (e) {
      setState(() {
        isConnected = false;
        lastUpdate =
            "Connection Error at ${DateTime.now().toString().substring(0, 19)}";
        connectionError = "Failed to connect: $e";
      });
      print("❌ Connection Error: $e");
      _retryCount++;
      Future.delayed(Duration(seconds: 2), _connectToWebSocket);
    }
  }

  void _toggleFan() {
    if (_channel != null && isConnected) {
      final command = jsonEncode({"fan": !fanStatus});
      _channel!.sink.add(command);
      print("📤 Command: $command");
      setState(() {
        fanStatus = !fanStatus;
      });
    } else {
      print("⚠️ Fan command failed: Not connected");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot control fan: ESP32 not connected")),
      );
    }
  }

  void _toggleAlert() {
    if (_channel != null && isConnected) {
      final command = jsonEncode({"alert": !alertStatus});
      _channel!.sink.add(command);
      print("📤 Command: $command");
      setState(() {
        alertStatus = !alertStatus;
      });
    } else {
      print("⚠️ Alert command failed: Not connected");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot control alert: ESP32 not connected")),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  Color _getPollutionColor(double level) {
    if (level < 30) return Colors.green;
    if (level < 60) return Colors.orange;
    return Colors.red;
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 35) return Colors.green;
    if (temp < 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF2C3E55),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isConnected ? _pulseAnimation.value : 1.0,
                  child: CircleAvatar(
                    backgroundColor: isConnected ? Colors.green : Colors.red,
                    radius: 8,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            _retryCount = 0;
            _connectToWebSocket();
            await Future.delayed(Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConnectionStatusCard(),
                if (connectionError.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Connection Error: $connectionError",
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 20),
                _buildDataGrid(),
                SizedBox(height: 20),
                _buildControlSection(),
                SizedBox(height: 20),
                _buildStatusIndicators(),
                SizedBox(height: 20),
                _buildLastUpdateCard(),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        },
        icon: Icon(Icons.settings),
        label: Text('Settings'),
        backgroundColor: Color(0xFF2196F3),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isConnected
                ? [Color(0xFF4CAF50), Color(0xFF45A049)]
                : [Color(0xFFE53935), Color(0xFFD32F2F)],
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESP32 Status',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildAnimatedDataCard(
          title: 'Pollution Level',
          value: '${pollutionLevel.toStringAsFixed(1)}%',
          icon: Icons.air,
          color: _getPollutionColor(pollutionLevel),
          progress: pollutionLevel / 100,
        ),
        _buildAnimatedDataCard(
          title: 'Temperature',
          value: '${temperature.toStringAsFixed(1)}°C',
          icon: Icons.thermostat,
          color: Color(0xFF2196F3),
          progress: (temperature - 10) / 40,
        ),
        _buildAnimatedDataCard(
          title: 'Balance Status',
          value: isBalanced ? 'Balanced' : 'Unbalanced',
          icon: isBalanced ? Icons.balance : Icons.warning,
          color: isBalanced ? Colors.green : Colors.orange,
          progress: isBalanced ? 1.0 : 0.3,
        ),
        _buildAnimatedDataCard(
          title: 'Board Temperature',
          value: '${boardTemperature.toStringAsFixed(1)}°C',
          icon: Icons.device_thermostat,
          color: _getTemperatureColor(boardTemperature),
          progress: (boardTemperature - 30) / 20,
        ),
      ],
    );
  }

  Widget _buildAnimatedDataCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Color(0xFF2C3E55),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _toggleFan,
              style: ElevatedButton.styleFrom(
                backgroundColor: fanStatus ? Colors.green : Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                fanStatus ? 'Fan On' : 'Fan Off',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: _toggleAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: alertStatus ? Colors.red : Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                alertStatus ? 'Alert On' : 'Alert Off',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicators() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Icon(
                  fanStatus ? Icons.air : Icons.power_off,
                  color: fanStatus ? Colors.green : Colors.grey,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  'Fan Status',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  fanStatus ? 'On' : 'Off',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: fanStatus ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Icon(
                  alertStatus
                      ? Icons.notification_important
                      : Icons.notifications_off,
                  color: alertStatus ? Colors.red : Colors.grey,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  'Alert Status',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  alertStatus ? 'On' : 'Off',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: alertStatus ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdateCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Colors.grey[600],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Last update: $lastUpdate',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Color(0xFF2196F3),
              ),
              onPressed: () {
                _retryCount = 0;
                _connectToWebSocket();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoRefresh = true;
  double _refreshInterval = 5.0;
  TextEditingController _ipController =
      TextEditingController(text: esp32IpAddress);
  String? _ipError;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  bool _isValidIpAddress(String ip) {
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }

  void _updateIpAddress() {
    String newIp = _ipController.text.trim();
    setState(() {
      if (newIp.isEmpty) {
        _ipError = 'IP address cannot be empty';
      } else if (!_isValidIpAddress(newIp)) {
        _ipError = 'Invalid IP address format';
      } else {
        _ipError = null;
        esp32IpAddress = newIp;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('IP Address updated to $esp32IpAddress')),
        );
        // إعادة الاتصال باستخدام العنوان الجديد
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E55)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF2C3E55),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsSection(
              title: 'WebSocket Configuration',
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        hintText: "ESP32 IP Address",
                        icon: Icons.network_wifi,
                        controller: _ipController,
                      ),
                      if (_ipError != null) ...[
                        SizedBox(height: 8),
                        Text(
                          _ipError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildActionTile(
                  title: 'Save IP Address',
                  subtitle: 'Update ESP32 WebSocket IP',
                  icon: Icons.save,
                  onTap: _updateIpAddress,
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: 'Notifications',
              children: [
                _buildSwitchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Receive alerts for critical data',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: 'Data Refresh',
              children: [
                _buildSwitchTile(
                  title: 'Auto Refresh',
                  subtitle: 'Automatically update sensor data',
                  value: _autoRefresh,
                  onChanged: (value) {
                    setState(() {
                      _autoRefresh = value;
                    });
                  },
                ),
                if (_autoRefresh) ...[
                  SizedBox(height: 16),
                  _buildSliderTile(
                    title: 'Refresh Interval',
                    subtitle: '${_refreshInterval.toInt()} seconds',
                    value: _refreshInterval,
                    min: 1.0,
                    max: 30.0,
                    onChanged: (value) {
                      setState(() {
                        _refreshInterval = value;
                      });
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: 'Device',
              children: [
                _buildActionTile(
                  title: 'Reset ESP32 Connection',
                  subtitle: 'Restart connection to ESP32',
                  icon: Icons.refresh,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ESP32 connection reset')),
                    );
                  },
                ),
                _buildActionTile(
                  title: 'Device Information',
                  subtitle: 'View ESP32 details',
                  icon: Icons.info_outline,
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: 'About',
              children: [
                _buildActionTile(
                  title: 'App Version',
                  subtitle: '1.0.0',
                  icon: Icons.app_settings_alt,
                  onTap: null,
                ),
                _buildActionTile(
                  title: 'Help & Support',
                  subtitle: 'Get help with the app',
                  icon: Icons.help_outline,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E55),
            ),
          ),
        ),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E55),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E55),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            activeColor: Color(0xFF2196F3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF2196F3)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E55),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: Colors.grey[400])
          : null,
      onTap: onTap,
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;

  const CustomInputField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 15, right: 10),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(
                icon,
                color: Colors.lightBlue,
                size: 22,
              ),
            ),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class GoogleLogoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleLogoButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/google_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final Color color;
  final Color textColor;

  const SocialLoginButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Color(0xFF1565C0),
                          child: Text(
                            'W',
                            style: TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Create your account',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                CustomInputField(
                  hintText: "Username",
                  icon: Icons.person,
                ),
                SizedBox(height: 20),
                CustomInputField(
                  hintText: "Email",
                  icon: Icons.email_outlined,
                ),
                SizedBox(height: 20),
                CustomInputField(
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color(0xFF2196F3),
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'Or sign up with',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GoogleLogoButton(onPressed: () {}),
                        SizedBox(width: 20),
                        SocialLoginButton(
                          onPressed: () {},
                          icon: 'f',
                          color: Colors.white,
                          textColor: Color(0xFF3b5998),
                        ),
                        SizedBox(width: 20),
                        SocialLoginButton(
                          onPressed: () {},
                          icon: 't',
                          color: Colors.white,
                          textColor: Color(0xFF1DA1F2),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
