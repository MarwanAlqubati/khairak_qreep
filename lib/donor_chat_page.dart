import 'package:flutter/material.dart';

class DonorChatPage extends StatefulWidget {
  final String beneficiaryName;
  final String phoneNumber;

  const DonorChatPage({
    super.key,
    required this.beneficiaryName,
    required this.phoneNumber,
  });

  @override
  State<DonorChatPage> createState() => _DonorChatPageState();
}

class _DonorChatPageState extends State<DonorChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // 🔹 قائمة الرسائل (مؤقتًا - مستقبلاً بتكون من قاعدة بيانات Firebase أو SQLite)
  final List<Map<String, dynamic>> _messages = [
    {"text": "السلام عليكم، تم تأكيد تبرعي لك 💚", "isDonor": true},
    {"text": "وعليكم السلام، جزاك الله خير 🌸", "isDonor": false},
  ];

  // إرسال رسالة جديدة
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "text": _messageController.text.trim(),
        "isDonor": true,
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🔹 خلفية متدرجة بنفس تصميم التطبيق
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
              // 🔹 الهيدر (اسم المستفيد + زر الرجوع)
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.beneficiaryName,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          widget.phoneNumber,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                    final isDonor = msg["isDonor"] as bool;

                    return Align(
                      alignment: isDonor
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDonor
                              ? Colors.teal.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isDonor
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isDonor
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

              // 🔹 شريط كتابة الرسالة
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "اكتب رسالتك هنا...",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.teal),
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
