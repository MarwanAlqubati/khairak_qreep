import 'package:flutter/material.dart';
import 'beneficiary_details.dart';

class AccessControlPage extends StatefulWidget {
  const AccessControlPage({super.key});

  @override
  State<AccessControlPage> createState() => _AccessControlPageState();
}

class _AccessControlPageState extends State<AccessControlPage> {
  final TextEditingController searchController = TextEditingController();

  // ✅ قائمة المستفيدين التجريبية
  final List<Map<String, String>> beneficiaries = [
    {
      'name': 'مستفيد 1',
      'phone': '+966500000000',
      'nationalId': '1234567890',
    },
    {
      'name': 'مستفيد 2',
      'phone': '+966511111111',
      'nationalId': '9876543210',
    },
    {
      'name': 'مستفيد 3',
      'phone': '+966522222222',
      'nationalId': '1122334455',
    },
  ];

  List<Map<String, String>> filteredBeneficiaries = [];

  @override
  void initState() {
    super.initState();
    filteredBeneficiaries = beneficiaries;
  }

  // 🔍 وظيفة البحث
  void searchByNationalId() {
    String query = searchController.text.trim();
    setState(() {
      if (query.isEmpty) {
        filteredBeneficiaries = beneficiaries;
      } else {
        filteredBeneficiaries = beneficiaries
            .where((b) => b['nationalId']!.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ الخلفية المتدرجة
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.teal.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ الشعار والزر العلوي
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "رجوع",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                    const Icon(
                      Icons.volunteer_activism,
                      color: Colors.amber,
                      size: 70,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "قائمة المستفيدين",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 15),

              // 🔹 حقل البحث + زر البحث
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // حقل إدخال رقم الهوية
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "ابحث برقم الهوية",
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // زر البحث
                    ElevatedButton(
                      onPressed: searchByNationalId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 26),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 عرض النتائج
              Expanded(
                child: filteredBeneficiaries.isEmpty
                    ? const Center(
                        child: Text(
                          "لا يوجد نتائج مطابقة",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredBeneficiaries.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final beneficiary = filteredBeneficiaries[index];
                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.person,
                                  color: Colors.amber, size: 35),
                              title: Text(
                                beneficiary['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              subtitle: Text(
                                "رقم الهوية: ${beneficiary['nationalId']}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BeneficiaryDetailPage(
                                      name: beneficiary['name']!,
                                      phone: beneficiary['phone']!,
                                      nationalId: beneficiary['nationalId']!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
