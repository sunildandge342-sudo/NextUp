import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nextup/screens/scan_qr_screen.dart';
import 'package:nextup/screens/enter_code_screen.dart';
import 'package:nextup/screens/browse_services_screen.dart';
import 'package:nextup/screens/dashboard/help_page.dart';
import 'package:nextup/screens/dashboard/account_page.dart';
import 'package:flutter/material.dart';
import 'QueueScreen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../services/service_api.dart';

class ServiceProviderHomePage extends StatefulWidget {
  final int providerId;


  const ServiceProviderHomePage({
    super.key,
    required this.providerId,

  });

  @override
  State<ServiceProviderHomePage> createState() =>
      _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState
    extends State<ServiceProviderHomePage> {

  int _currentIndex = 0;

  bool _isLoading = true;
  bool _hasError = false;

  List<ServiceModel> _services = [];



  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  // ================= FETCH SERVICES =================

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data =
      await ServiceApi.getServices(widget.providerId);

      if (!mounted) return;

      setState(() {
        _services = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Do you want to exit the application?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {


    final tabs = [
      _buildHomeTab(),
      _buildNotificationTab(),
      _accountTab(),
    ];

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFEFF2FF),
        foregroundColor: Colors.indigo,
        title: const Text(
          "NextUp",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: tabs[_currentIndex],

      floatingActionButton:
      _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: _openAddServiceDialog,
        backgroundColor: const Color(0xFF4A6CF7),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Service"),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) =>
            setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded), // Modern alternative
            activeIcon: Icon(Icons.bar_chart_rounded), // Optionally keep filled when active
            label: "Stats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    ),
    );
  }

  // ================= HOME TAB =================

  Widget _buildHomeTab() {

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Text("Failed to load services"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchServices,
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }
    if (_services.isEmpty) {
      return const Center(
        child: Text(
          "No services added yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchServices,
      child: _services.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.miscellaneous_services_rounded,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              "No services added yet",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: _services.length,
        itemBuilder: (context, index) {

          final service = _services[index];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
              onTap: () {
                print(service);
                print("SERVICE ID: ${service.id}");
                print("SERVICE NAME: ${service.name}");
                print("IS ACTIVE: ${service.isActive}");
                print("PROVIDER ID: ${widget.providerId}");

                if (service.id == null || widget.providerId == null) {
                  print("ERROR: serviceId or providerId is null");
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QueueScreen(
                      serviceId: service.id ?? 0,
                      serviceName: service.name ?? "",
                      isActive: service.isActive ?? false,
                      userId: widget.providerId ?? 0,
                    ),
                  ),
                ).then((refresh) {
                  if (refresh == true) {
                    _fetchServices();
                  }
                });
              },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.indigo.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  // 🔵 Icon Section
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A6CF7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF4A6CF7),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 📝 Service Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Tap to manage queue",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🔳 QR Icon Button
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= CREATE SERVICE =================

  void _openAddServiceDialog() {

    final nameController =
    TextEditingController();
    final descriptionController =
    TextEditingController();
    final capacityController =
    TextEditingController();

    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            Future<void> createService() async {

              final name =
              nameController.text.trim();
              final description =
              descriptionController.text.trim();

              if (name.isEmpty ||
                  description.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Name and description required"),
                  ),
                );
                return;
              }

              int? maxCapacity;

              if (capacityController
                  .text
                  .trim()
                  .isNotEmpty) {

                maxCapacity =
                    int.tryParse(
                        capacityController.text);

                if (maxCapacity == null ||
                    maxCapacity <= 0) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Enter valid capacity"),
                    ),
                  );
                  return;
                }
              }

              setStateDialog(
                      () => isSaving = true);

              try {

                final newService =
                await ServiceApi
                    .createService({
                  "providerId":
                  widget.providerId,
                  "name": name,
                  "description":
                  description,
                  if (maxCapacity != null)
                    "maxCapacity":
                    maxCapacity,
                });

                if (!mounted) return;

                setState(() {
                  _services.insert(
                      0, newService);
                });

                Navigator.pop(dialogContext);

              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                      content:
                      Text(e.toString())),
                );
              } finally {
                if (mounted) {
                  setStateDialog(
                          () => isSaving = false);
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 🔹 Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Create New Service",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Add a service that customers can join in queue.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _premiumInputField(
                        label: "Service Name",
                        hint: "e.g. Haircut, Consultation",
                        controller: nameController,
                      ),

                      const SizedBox(height: 18),

                      _premiumInputField(
                        label: "Description",
                        hint: "Describe this service",
                        controller: descriptionController,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 18),

                      _premiumInputField(
                        label: "Maximum Queue Capacity (Optional)",
                        hint: "Leave empty for unlimited",
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving ? null : createService,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A6CF7),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                "Create Service",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showQrDialog(int serviceId, String serviceName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: QrImageView(
                    data: serviceId.toString(),
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Scan to join queue",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _premiumInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black, // 👈 NORMAL LABEL
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black, // 👈 NORMAL TYPED TEXT
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.35), // 👈 ONLY SUGGESTION FADED
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4A6CF7),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildInputField(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ================= OTHER TABS =================

  Widget _buildNotificationTab() =>
      const Center(
        child:
        Text("Comming Soon.."),
      );

  Widget _accountTab() {
    return AccountPage(
      firstName: "",
      email: "",
      mobile: "",
    );
  }
}










