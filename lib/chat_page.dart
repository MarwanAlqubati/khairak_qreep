import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  const ChatPage({super.key, required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // مؤقتًا بدون قاعدة بيانات
  final List<Map<String, dynamic>> _messages = [
    {"text": "السلام عليكم، تم استلام تبرعك 💚", "isBeneficiary": true},
    {"text": "وعليكم السلام، الله يجزاك خير 🌸", "isBeneficiary": false},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "text": _messageController.text.trim(),
        "isBeneficiary": true, // لأن المستخدم الحالي هو المستفيد
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🔹 خلفية متدرجة بنفس تنسيق تطبيق المتبرع
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffe9fdfb),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔹 الشريط العلوي (الهيدر)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.teal),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.person, color: Colors.teal),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 1),

              // 🔹 الرسائل
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isBeneficiary = msg["isBeneficiary"] as bool;

                    return Align(
                      alignment: isBeneficiary
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isBeneficiary
                              ? Colors.teal.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isBeneficiary
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isBeneficiary
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          msg["text"],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🔹 شريط الكتابة بأسفل الشاشة (مع الأدوات الثلاث)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.teal),
                      onPressed: () {
                        // لاحقًا: رفع صورة
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.teal),
                      onPressed: () {
                        // لاحقًا: رفع ملف PDF
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.location_on, color: Colors.teal),
                      onPressed: () {
                        // لاحقًا: إرسال الموقع
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "اكتب رسالتك هنا...",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.amber),
                      onPressed: _sendMessage,
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
