import 'dart:convert';
import 'dart:async'; // Required for Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../model/error_model.dart';

class ErrorController extends GetxController {
  var _allErrors = <ErrorCode>[];
  var displayedErrors = <ErrorCode>[].obs;

  // Memoized list to avoid re-filtering during scroll
  List<ErrorCode> _currentFilteredList = [];

  var isLoading = true.obs;
  var isLoadingMore = false.obs;

  int _currentPage = 0;
  final int _itemsPerPage = 15; // Reduced for faster initial load
  final ScrollController scrollController = ScrollController();

  String _currentQuery = '';
  var selectedCategory = 'All'.obs;

  Timer? _debounce; // For search efficiency

  final List<String> categories = [
    'All', // Default selected
    'PIM 50',
    'ROM 50',
    'PM',
    'LOM 110',
    'Common Negation errors',
  ];

  @override
  void onInit() {
    super.onInit();
    loadDatabase();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Enhanced lazy loading with better threshold
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 300) {
      loadMoreData();
    }

    // Preload when user is 80% through current content
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      _preloadNextChunk();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
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
      _allErrors = data.map((e) => ErrorCode.fromJson(e)).toList();
      applyFilters();
    } catch (e) {
      Get.snackbar("Error", "Could not load error database.");
    } finally {
      isLoading.value = false;
    }
  }

  void searchError(String query) {
    // Debounce search to save CPU cycles
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _currentQuery = query;
      _resetPagination();
    });
  }

  void setCategory(String? category) {
    selectedCategory.value = category ?? 'All';
    _resetPagination();
  }

  void _resetPagination() {
    _currentPage = 0;
    displayedErrors.clear();
    applyFilters();
  }

  void applyFilters() {
    // Filter once and store in _currentFilteredList
    _currentFilteredList = _allErrors.where((error) {
      bool matchesCategory =
          selectedCategory.value == 'All' ||
          error.category == selectedCategory.value;
      bool matchesQuery =
          _currentQuery.isEmpty ||
          error.code.toLowerCase().contains(_currentQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    _loadNextChunk();
  }

  void loadMoreData() {
    if (isLoadingMore.value ||
        displayedErrors.length >= _currentFilteredList.length)
      return;
    _loadNextChunk();
  }

  void _preloadNextChunk() {
    // Silently preload next chunk when user is near bottom
    if (!isLoadingMore.value &&
        displayedErrors.length < _currentFilteredList.length) {
      int nextStart = (_currentPage) * _itemsPerPage;
      int nextEnd = nextStart + (_itemsPerPage ~/ 2); // Preload half chunk

      if (nextEnd > _currentFilteredList.length) {
        nextEnd = _currentFilteredList.length;
      }

      if (nextStart < _currentFilteredList.length) {
        Future.delayed(const Duration(milliseconds: 50), () {
          displayedErrors.addAll(
            _currentFilteredList.sublist(nextStart, nextEnd),
          );
        });
      }
    }
  }

  void _loadNextChunk() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    await Future.delayed(const Duration(milliseconds: 100));

    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;

    if (end > _currentFilteredList.length) end = _currentFilteredList.length;

    if (start < _currentFilteredList.length) {
      displayedErrors.addAll(_currentFilteredList.sublist(start, end));
      _currentPage++;
    }

    isLoadingMore.value = false;
  }
}
