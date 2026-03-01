import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  static const String fontFamilyPrimary = 'Poppins';
  static const String fontFamilySecondary = 'Oxygen';

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamilyPrimary,
    color: AppColors.textPrimary,
  );
  static const TextStyle locheadlineLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamilyPrimary,
    color: AppColors.textPrimary,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: fontFamilyPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontFamily: fontFamilyPrimary,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.buttonText,
  );
  static const TextStyle locbuttonText = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.buttonText,
  );

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24);

  static const SizedBox verticalSpaceSmall = SizedBox(height: 8);
  static const SizedBox verticalSpaceMedium = SizedBox(height: 16);
  static const SizedBox verticalSpaceLarge = SizedBox(height: 32);

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryAccent,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(69)),
    elevation: 0,
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
      side: const BorderSide(color: AppColors.primaryAccent, width: 2),
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: fontFamilySecondary,
    ),
  );
}
