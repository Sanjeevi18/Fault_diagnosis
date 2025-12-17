import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/error_controller.dart';

class ErrorSearchView extends StatelessWidget {
  ErrorSearchView({super.key});

  final ErrorController controller = Get.put(ErrorController());
  final TextEditingController searchInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 250, 255, 1),
      appBar: AppBar(
        title: const Text(
          "Technician Error Lookup",
          // REQUESTED CHANGE: Font Size 20
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Search Bar ---
            TextField(
              controller: searchInputController,
              onChanged: (value) => controller.searchError(value),
              decoration: InputDecoration(
                labelText: "Search Error Code (e.g., FEC1)",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    searchInputController.clear();
                    controller.searchError('');
                    // Keyboard dismissal optional: FocusScope.of(context).unfocus();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- List View with Lazy Loading ---
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // NOTE: removed the "if empty" check to ensure list always displays

                return ListView.builder(
                  // Attach the ScrollController for Lazy Loading
                  controller: controller.scrollController,
                  // Add +1 to item count for the bottom loading indicator
                  itemCount: controller.displayedErrors.length + 1,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Logic to show loading indicator at the very bottom
                    if (index == controller.displayedErrors.length) {
                      return Obx(
                        () => controller.isLoadingMore.value
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ); // Hidden if not loading
                    }

                    final error = controller.displayedErrors[index];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.blue.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  error.code,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Colors.grey.withValues(alpha: 0.6),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            "Error ${error.code}: ${error.description}",
                                      ),
                                    );
                                    Get.snackbar(
                                      "Copied",
                                      "Error details copied to clipboard",
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 1),
                                      margin: const EdgeInsets.all(16),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            const Text(
                              "FAILURE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              error.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.build_circle_outlined,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "RECOMMENDED ACTION",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    error.action,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
