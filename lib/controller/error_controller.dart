import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../model/error_model.dart'; // Ensure this path matches your project structure

class ErrorController extends GetxController {
  // Master list of ALL data
  var _allErrors = <ErrorCode>[];

  // List currently displayed in the UI (Observable)
  var displayedErrors = <ErrorCode>[].obs;

  var isLoading = true.obs;
  var isLoadingMore = false.obs; // For the bottom loader

  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  // Scroll Controller for the ListView
  final ScrollController scrollController = ScrollController();

  // Search Query tracker
  String _currentQuery = '';

  @override
  void onInit() {
    super.onInit();
    loadDatabase();

    // Listener for Lazy Loading (Infinite Scroll)
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // User reached bottom, load more
        loadMoreData();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadDatabase() async {
    try {
      isLoading.value = true;
      final String response = await rootBundle.loadString(
        'assets/database.json',
      );
      final List<dynamic> data = json.decode(response);

      // Store everything in the master list
      _allErrors = data.map((e) => ErrorCode.fromJson(e)).toList();

      // Initial load of the displayed list
      resetList();
    } catch (e) {
      print("Error loading database: $e");
      Get.snackbar("Error", "Could not load error database.");
    } finally {
      isLoading.value = false;
    }
  }

  // Resets the list to the first page (used on Init and Clear Search)
  void resetList() {
    _currentQuery = '';
    _currentPage = 0;
    displayedErrors.clear();
    _loadNextChunk(_allErrors);
  }

  // Search Logic
  void searchError(String query) {
    _currentQuery = query;
    _currentPage = 0; // Reset pagination for new search
    displayedErrors.clear();

    if (query.isEmpty) {
      // If search is cleared, go back to showing the full list (paginated)
      resetList();
    } else {
      // Filter the master list
      List<ErrorCode> results = _allErrors.where((error) {
        return error.code.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // Load the first chunk of the search results
      _loadNextChunk(results);
    }
  }

  // The actual "Lazy Load" logic triggered by scrolling
  void loadMoreData() {
    if (isLoadingMore.value) return;

    // Determine which list we are paginating (Full list or Search Results)
    List<ErrorCode> sourceList;
    if (_currentQuery.isEmpty) {
      sourceList = _allErrors;
    } else {
      sourceList = _allErrors.where((error) {
        return error.code.toLowerCase().contains(_currentQuery.toLowerCase());
      }).toList();
    }

    if (displayedErrors.length < sourceList.length) {
      _loadNextChunk(sourceList);
    }
  }

  // Helper to slice the list and append data
  void _loadNextChunk(List<ErrorCode> source) async {
    isLoadingMore.value = true;

    // Simulate a tiny delay for visual effect (optional, remove in production if unwanted)
    await Future.delayed(const Duration(milliseconds: 300));

    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;

    // Boundary check
    if (end > source.length) end = source.length;

    if (start < source.length) {
      displayedErrors.addAll(source.sublist(start, end));
      _currentPage++;
    }

    isLoadingMore.value = false;
  }
}
