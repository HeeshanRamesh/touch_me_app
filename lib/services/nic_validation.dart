
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class NICValidationService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Validates if the uploaded image is a Sri Lankan NIC
  static Future<NICValidationResult> validateNICImage({
    required Uint8List imageBytes,
    required bool isFrontSide,
  }) async {
    try {
      // First, validate basic image properties
      final basicValidation = await _validateBasicImageProperties(imageBytes);
      if (!basicValidation.isValid) {
        return basicValidation;
      }

      // Create InputImage from bytes (simplified approach)
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata:  InputImageMetadata(
          size: Size(800, 600),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.yuv420,
          bytesPerRow: 800,
        ),
      );

      // Perform text recognition with error handling
      RecognizedText? recognizedText;
      try {
        recognizedText = await _textRecognizer.processImage(inputImage);
      } catch (e) {
        // If ML Kit fails, fall back to basic validation
        print('Text recognition failed: $e');
        return _fallbackValidation(imageBytes, isFrontSide);
      }

      // Validate based on side with more lenient criteria
      if (isFrontSide) {
        return _validateNICFrontImproved(recognizedText, imageBytes);
      } else {
        return _validateNICBackImproved(recognizedText, imageBytes);
      }
    } catch (e) {
      print('NIC validation error: $e');
      return _fallbackValidation(imageBytes, isFrontSide);
    }
  }

  /// Basic image validation with flexible constraints
  static Future<NICValidationResult> _validateBasicImageProperties(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return NICValidationResult(
          isValid: false,
          confidence: 0.0,
          errorMessage: 'Invalid image format. Please upload a JPG or PNG image.',
        );
      }

      // Check file size (prevent extremely large files)
      if (imageBytes.length > 10 * 1024 * 1024) { // 10MB limit
        return NICValidationResult(
          isValid: false,
          confidence: 0.0,
          errorMessage: 'Image file too large. Please use an image smaller than 10MB.',
        );
      }

      // Check minimum dimensions (more lenient)
      if (image.width < 150 || image.height < 100) {
        return NICValidationResult(
          isValid: false,
          confidence: 0.0,
          errorMessage: 'Image resolution too low. Please use a clearer, higher resolution image.',
        );
      }

      // Check maximum dimensions (prevent unnecessarily large images)
      if (image.width > 4000 || image.height > 4000) {
        return NICValidationResult(
          isValid: false,
          confidence: 0.0,
          errorMessage: 'Image resolution too high. Please use a smaller image (max 4000x4000 pixels).',
        );
      }

      // More lenient aspect ratio check with warning
      double aspectRatio = image.width / image.height;
      if (aspectRatio < 0.8 || aspectRatio > 2.5) {
        return NICValidationResult(
          isValid: false,
          confidence: 20.0,
          errorMessage: 'Image shape seems unusual for a NIC. Please ensure the complete NIC card is visible and properly oriented.',
        );
      }

      // Warn about non-ideal aspect ratios but don't reject
      if (aspectRatio < 1.0 || aspectRatio > 2.0) {
        return NICValidationResult(
          isValid: true,
          confidence: 70.0,
          foundFeatures: ['Valid Image Format'],
          errorMessage: null,
        );
      }

      return NICValidationResult(
        isValid: true,
        confidence: 100.0,
        foundFeatures: ['Valid Image Format', 'Ideal Dimensions'],
      );
    } catch (e) {
      return NICValidationResult(
        isValid: false,
        confidence: 0.0,
        errorMessage: 'Error processing image. Please try a different image.',
      );
    }
  }

  /// Improved front side validation with more flexible criteria
  static NICValidationResult _validateNICFrontImproved(RecognizedText recognizedText, Uint8List imageBytes) {
    final String fullText = recognizedText.text.toLowerCase().replaceAll(' ', '');
    double confidence = 40.0; // Start with base confidence for basic image validation
    List<String> foundFeatures = ['Valid Image Format'];
    List<String> missingFeatures = [];

    // Check for NIC number pattern (more flexible)
    final nicNumberRegex = RegExp(r'\d{9}[vx]|\d{12}|\d{10}[vx]');
    final digitPatterns = RegExp(r'\d{8,12}');
    
    if (nicNumberRegex.hasMatch(fullText) || digitPatterns.hasMatch(fullText)) {
      confidence += 25.0;
      foundFeatures.add('ID Number Pattern');
    }

    // Check for Sri Lankan text patterns (more flexible)
    final sriLankaKeywords = [
      'srilanka', 'lanka', 'democratic', 'socialist', 'republic',
      'national', 'identity', 'card', 'nic'
    ];
    
    int keywordCount = 0;
    for (String keyword in sriLankaKeywords) {
      if (fullText.contains(keyword)) {
        keywordCount++;
      }
    }
    
    if (keywordCount >= 2) {
      confidence += 20.0;
      foundFeatures.add('Official Text Elements');
    } else if (keywordCount >= 1) {
      confidence += 10.0;
      foundFeatures.add('Some Official Text');
    }

    // Check for personal info patterns
    final personalInfoKeywords = ['name', 'sex', 'date', 'birth', 'place'];
    int personalInfoCount = 0;
    for (String keyword in personalInfoKeywords) {
      if (fullText.contains(keyword)) {
        personalInfoCount++;
      }
    }
    
    if (personalInfoCount >= 2) {
      confidence += 15.0;
      foundFeatures.add('Personal Information Fields');
    }

    // Additional structural validation
    if (_hasCardLikeStructure(imageBytes)) {
      confidence += 10.0;
      foundFeatures.add('Card-like Structure');
    }

    // More lenient validation - accept if confidence is above 50%
    bool isValid = confidence >= 50.0;
    
    if (!isValid) {
      missingFeatures.addAll([
        if (!foundFeatures.contains('ID Number Pattern')) 'Clear ID Number',
        if (!foundFeatures.contains('Official Text Elements')) 'Official Text',
        if (!foundFeatures.contains('Personal Information Fields')) 'Personal Info Fields',
      ]);
    }

    return NICValidationResult(
      isValid: isValid,
      confidence: confidence.clamp(0.0, 100.0),
      foundFeatures: foundFeatures,
      missingFeatures: missingFeatures,
      errorMessage: isValid ? null : 'Please ensure the image shows a clear, complete NIC front side',
    );
  }

  /// Improved back side validation
  static NICValidationResult _validateNICBackImproved(RecognizedText recognizedText, Uint8List imageBytes) {
    final String fullText = recognizedText.text.toLowerCase().replaceAll(' ', '');
    double confidence = 40.0; // Base confidence
    List<String> foundFeatures = ['Valid Image Format'];
    List<String> missingFeatures = [];

    // Check for address-related content
    final addressKeywords = ['address', 'province', 'district', 'division', 'grama'];
    int addressCount = 0;
    for (String keyword in addressKeywords) {
      if (fullText.contains(keyword)) {
        addressCount++;
      }
    }
    
    if (addressCount >= 1) {
      confidence += 20.0;
      foundFeatures.add('Address Information');
    }

    // Check for signature/date patterns
    final backSideKeywords = ['signature', 'date', 'issue', 'registrar', 'officer'];
    int backSideCount = 0;
    for (String keyword in backSideKeywords) {
      if (fullText.contains(keyword)) {
        backSideCount++;
      }
    }
    
    if (backSideCount >= 1) {
      confidence += 20.0;
      foundFeatures.add('Official Elements');
    }

    // Check for any number patterns (could be NIC number or dates)
    if (RegExp(r'\d{4,}').hasMatch(fullText)) {
      confidence += 10.0;
      foundFeatures.add('Numeric Information');
    }

    // Structural validation
    if (_hasCardLikeStructure(imageBytes)) {
      confidence += 10.0;
      foundFeatures.add('Card-like Structure');
    }

    bool isValid = confidence >= 50.0;
    
    if (!isValid) {
      missingFeatures.addAll([
        if (!foundFeatures.contains('Address Information')) 'Address Details',
        if (!foundFeatures.contains('Official Elements')) 'Official Signatures/Dates',
      ]);
    }

    return NICValidationResult(
      isValid: isValid,
      confidence: confidence.clamp(0.0, 100.0),
      foundFeatures: foundFeatures,
      missingFeatures: missingFeatures,
      errorMessage: isValid ? null : 'Please ensure the image shows a clear, complete NIC back side',
    );
  }

  /// Fallback validation when text recognition fails
  static NICValidationResult _fallbackValidation(Uint8List imageBytes, bool isFrontSide) {
    bool hasCardStructure = _hasCardLikeStructure(imageBytes);
    
    if (hasCardStructure) {
      return NICValidationResult(
        isValid: true,
        confidence: 60.0,
        foundFeatures: ['Card-like Structure', 'Valid Image Format'],
        errorMessage: null,
      );
    }
    
    return NICValidationResult(
      isValid: false,
      confidence: 30.0,
      foundFeatures: ['Valid Image Format'],
      missingFeatures: ['Card-like Structure'],
      errorMessage: 'Please ensure the image clearly shows the complete NIC',
    );
  }

  /// Check if image has card-like structure
  static bool _hasCardLikeStructure(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return false;

      // Check aspect ratio
      double aspectRatio = image.width / image.height;
      if (aspectRatio < 1.2 || aspectRatio > 2.0) return false;

      // Check minimum size
      if (image.width < 200 || image.height < 100) return false;

      // Check if there's sufficient contrast (cards usually have text on light background)
      final grayscale = img.grayscale(image);
      int darkPixels = 0;
      int lightPixels = 0;
      int sampleSize = (image.width * image.height / 100).round(); // Sample 1% of pixels
      
      for (int i = 0; i < sampleSize; i++) {
        int x = (i * 7) % image.width; // Pseudo-random sampling
        int y = (i * 11) % image.height;
        final pixel = grayscale.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        
        if (luminance < 100) {
          darkPixels++;
        } else if (luminance > 150) {
          lightPixels++;
        }
      }
      
      // Cards typically have good contrast between text and background
      double contrastRatio = (darkPixels + lightPixels) / sampleSize.toDouble();
      return contrastRatio > 0.3;
      
    } catch (e) {
      print('Structure validation error: $e');
      return false;
    }
  }

  /// Dispose resources
  static void dispose() {
    _textRecognizer.close();
  }
}

/// Result class for NIC validation
class NICValidationResult {
  final bool isValid;
  final double confidence;
  final List<String> foundFeatures;
  final List<String> missingFeatures;
  final String? errorMessage;

  NICValidationResult({
    required this.isValid,
    required this.confidence,
    this.foundFeatures = const [],
    this.missingFeatures = const [],
    this.errorMessage,
  });

  @override
  String toString() {
    return 'NICValidationResult(isValid: $isValid, confidence: ${confidence.toStringAsFixed(1)}%, foundFeatures: $foundFeatures, missingFeatures: $missingFeatures)';
  }
}