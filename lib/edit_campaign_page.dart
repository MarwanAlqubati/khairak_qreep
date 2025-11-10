import 'package:exakhairak_qreep/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exakhairak_qreep/models/app_Charity.dart';

class EditCampaignPage extends StatefulWidget {
  final AppCharity charity;

  const EditCampaignPage({super.key, required this.charity});

  @override
  State<EditCampaignPage> createState() => _EditCampaignPageState();
}

class _EditCampaignPageState extends State<EditCampaignPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _charityNameController;

  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();

    // تحميل البيانات الحالية في الحقول
    _titleController = TextEditingController(text: widget.charity.titlle);
    _descriptionController =
        TextEditingController(text: widget.charity.description);
    _charityNameController =
        TextEditingController(text: widget.charity.charityname);

    // تحويل اسم الأيقونة المخزنة إلى IconData - الطريقة الصحيحة
    _selectedIcon = AppIcons.getIconFromName(widget.charity.iconName);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى اختيار أيقونة للحملة"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('charity')
          .doc(widget.charity.uid)
          .update({
        'titlle': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'charityname': _charityNameController.text.trim(),

        'icon':
            AppIcons.getNameFromIcon(_selectedIcon!), // حفظ اسم الأيقونة فقط
      });
      print(AppIcons.getNameFromIcon(_selectedIcon!));

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات بنجاح ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحفظ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text("رجوع",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    const Text(
                      "تعديل الحملة",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _buildTextField(
                            controller: _titleController,
                            label: "عنوان الحملة"),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _descriptionController,
                          label: "وصف الحملة",
                          maxLines: 4,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                            controller: _charityNameController,
                            label: "اسم الجمعية"),

                        const SizedBox(height: 20),

                        // عرض الأيقونة الحالية المحددة
                        if (_selectedIcon != null) ...[
                          const Text(
                            "الأيقونة الحالية:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          ),
                          const SizedBox(height: 10),
                          Icon(_selectedIcon, size: 40, color: Colors.teal),
                          const SizedBox(height: 20),
                        ],

                        const Text(
                          "اختر أيقونة جديدة للحملة:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppIcons.availableIcons.map((iconData) {
                            final icon = iconData['icon'] as IconData;
                            final label = iconData['label'] as String;
                            final selected = _selectedIcon == icon;

                            return Tooltip(
                              message: label,
                              child: ChoiceChip(
                                label: Icon(icon,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black54),
                                selected: selected,
                                selectedColor: Colors.teal,
                                padding: const EdgeInsets.all(8),
                                onSelected: (sel) {
                                  setState(() {
                                    _selectedIcon = sel ? icon : null;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      "حفظ التعديلات",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? "يرجى إدخال $label" : null,
    );
  }
}
