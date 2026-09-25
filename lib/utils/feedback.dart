import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
void showAppSnackbar(String title, String message, {bool error = false}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    maxWidth: 480,
    margin: const EdgeInsets.all(16),
    backgroundColor: error ? const Color(0xFFFDECEC) : AppColors.surface,
    colorText: AppColors.textPrimary,
    borderColor: error ? AppColors.error : AppColors.outline,
    borderWidth: 1,
  );
}