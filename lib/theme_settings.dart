import 'package:flutter/material.dart';

class ThemeSettingsPage extends StatefulWidget {
  
  final Function(bool)? onThemeChanged;
  final Function(Color)? onColorChanged;
  final Function(Color)? onTextColorChanged;
  final Function(Color)? onIconColorChanged;

  const ThemeSettingsPage({
    super.key,
    this.onThemeChanged,
    this.onColorChanged,
    this.onTextColorChanged,
    this.onIconColorChanged,
  });

  @override
  _ThemeSettingsPageState createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool isDarkMode = false;
  Color selectedColor = Colors.teal;
  Color selectedTextColor = Colors.black;
  Color selectedIconColor = Colors.teal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.teal.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
               
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            label: const Text(
                              "رجوع",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                            ),
                          ),
                          const Icon(Icons.color_lens,
                              size: 60, color: Colors.teal),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "إعدادات المظهر",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),

                    const SizedBox(height: 30),

                    SwitchListTile(
                      title: const Text("الوضع الداكن",
                          style: TextStyle(fontSize: 18, color: Colors.teal)),
                      value: isDarkMode,
                      activeColor: Colors.amber,
                      onChanged: (value) {
                        setState(() => isDarkMode = value);
                        widget.onThemeChanged?.call(isDarkMode);
                      },
                    ),

                    const Divider(),

                    const Text("اختر اللون الأساسي:",
                        style: TextStyle(fontSize: 18, color: Colors.teal)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 15,
                      children: [
                        _buildColorOption(Colors.teal, isPrimary: true),
                        _buildColorOption(Colors.blue, isPrimary: true),
                        _buildColorOption(Colors.green, isPrimary: true),
                        _buildColorOption(Colors.red, isPrimary: true),
                        _buildColorOption(Colors.orange, isPrimary: true),
                      ],
                    ),

                    const Divider(),

                   
                    const Text("اختر لون النصوص:",
                        style: TextStyle(fontSize: 18, color: Colors.teal)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 15,
                      children: [
                        _buildColorOption(Colors.black, isText: true),
                        _buildColorOption(Colors.white, isText: true),
                        _buildColorOption(Colors.teal, isText: true),
                        _buildColorOption(Colors.deepPurple, isText: true),
                      ],
                    ),

                    const Divider(),

                    const Text("اختر لون الأيقونات:",
                        style: TextStyle(fontSize: 18, color: Colors.teal)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 15,
                      children: [
                        _buildColorOption(Colors.teal, isIcon: true),
                        _buildColorOption(Colors.amber, isIcon: true),
                        _buildColorOption(Colors.red, isIcon: true),
                        _buildColorOption(Colors.blue, isIcon: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color,
      {bool isPrimary = false, bool isText = false, bool isIcon = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isPrimary) {
            selectedColor = color;
            widget.onColorChanged?.call(color);
          } else if (isText) {
            selectedTextColor = color;
            widget.onTextColorChanged?.call(color);
          } else if (isIcon) {
            selectedIconColor = color;
            widget.onIconColorChanged?.call(color);
          }
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: (isPrimary && selectedColor == color) ||
                (isText && selectedTextColor == color) ||
                (isIcon && selectedIconColor == color)
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }
}
