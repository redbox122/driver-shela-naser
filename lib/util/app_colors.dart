import 'package:flutter/material.dart';

/// Centralized color palette for the delivery app
/// Following Material Design 3 principles with delivery-focused color scheme
class AppColors {
  // Primary Colors - Delivery/Go theme
  static const Color primary = Color(0xFF2A9849); // Green - delivery/go
  static const Color primaryLight = Color(0xFF54B46B); // Light green
  static const Color primaryDark = Color(0xFF1E6B35); // Dark green

  // Accent Colors - Active states
  static const Color accent = Color(0xFF1ED7AA); // Teal - active states
  static const Color accentLight = Color(0xFF4DE5C4); // Light teal
  static const Color accentDark = Color(0xFF00A085); // Dark teal

  // Error Colors - Urgent attention
  static const Color error = Color(0xFFE84D4F); // Red - urgent attention
  static const Color errorLight = Color(0xFFFF6B6D); // Light red
  static const Color errorDark = Color(0xFFC62828); // Dark red

  // Warning Colors
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFFB74D); // Light orange
  static const Color warningDark = Color(0xFFF57C00); // Dark orange

  // Success Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784); // Light green
  static const Color successDark = Color(0xFF388E3C); // Dark green

  // Neutral Colors
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light gray
  static const Color background = Color(0xFFFAFAFA); // Background

  // Card Background Colors
  static const Color cardBackgroundLight = Color(0xFFFDFDFD);
  static const Color cardBackgroundDark = Color(0xFF1A1A1A);

  // Text Colors
  static const Color onSurface = Color(0xFF212121); // Dark gray
  static const Color onSurfaceVariant = Color(0xFF757575); // Medium gray
  static const Color onSurfaceDisabled = Color(0xFFBDBDBD); // Light gray

  // Dark Theme Colors
  static const Color surfaceDark = Color(0xFF121212); // Dark surface
  static const Color surfaceVariantDark = Color(0xFF1E1E1E); // Dark variant
  static const Color backgroundDark = Color(0xFF000000); // Dark background
  static const Color onSurfaceDark = Color(0xFFE0E0E0); // Light text
  static const Color onSurfaceVariantDark =
      Color(0xFFB0B0B0); // Medium light text

  // Status Colors
  static const Color online = Color(0xFF4CAF50); // Online status
  static const Color offline = Color(0xFF757575); // Offline status
  static const Color pending = Color(0xFFFF9800); // Pending status
  static const Color completed = Color(0xFF2196F3); // Completed status

  // Payment Method Colors
  static const Color cashOnDelivery = Color(0xFFE84D4F); // COD - red
  static const Color digitalPayment = Color(0xFF4CAF50); // Digital - green
  static const Color partialPayment = Color(0xFFFF9800); // Partial - orange

  // Order Type Colors
  static const Color foodOrder =
      Color(0xFF2A9849); // Food order - primary green
  static const Color parcelOrder = Color(0xFF2196F3); // Parcel order - blue

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
    ],
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // Light shadow
  static const Color shadowMedium = Color(0x33000000); // Medium shadow
  static const Color shadowDark = Color(0x4D000000); // Dark shadow

  // Elevation Colors
  static const Color elevationLow = Color(0x0A000000);
  static const Color elevationMedium = Color(0x14000000);
  static const Color elevationHigh = Color(0x1F000000);
  static const Color elevationHero = Color(0x33000000);

  // Interactive Colors
  static const Color ripple = Color(0x1A2A9849); // Ripple effect
  static const Color hover = Color(0x0A2A9849); // Hover state
  static const Color pressed = Color(0x1A2A9849); // Pressed state

  // Map Colors
  static const Color mapMarker = Color(0xFF2A9849); // Map marker
  static const Color mapRoute = Color(0xFF1ED7AA); // Route line
  static const Color mapBackground = Color(0xFFF5F5F5); // Map background

  // Notification Colors
  static const Color notificationInfo = Color(0xFF2196F3); // Info notification
  static const Color notificationSuccess =
      Color(0xFF4CAF50); // Success notification
  static const Color notificationWarning =
      Color(0xFFFF9800); // Warning notification
  static const Color notificationError =
      Color(0xFFE84D4F); // Error notification

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2A9849), // Primary green
    Color(0xFF1ED7AA), // Teal
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFFE84D4F), // Red
  ];

  // Glassmorphism Colors
  static const Color glassmorphismLight =
      Color(0x40FFFFFF); // Light glass effect
  static const Color glassmorphismMedium =
      Color(0x60FFFFFF); // Medium glass effect
  static const Color glassmorphismDark = Color(0x80FFFFFF); // Dark glass effect
  static const Color glassmorphismDarkMode =
      Color(0x20FFFFFF); // Dark mode glass

  // Glass Frost Effects
  static const Color glassFrostLight = Color(0x66FFFFFF); // 40% white
  static const Color glassFrostBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassFrostDark = Color(0x33FFFFFF); // Dark mode frost

  // Mesh Gradient Colors
  static const Color meshGradient1 = Color(0xFF2A9849); // Primary
  static const Color meshGradient2 = Color(0xFF1ED7AA); // Accent
  static const Color meshGradient3 = Color(0xFF54B46B); // Primary light
  static const Color meshGradient4 = Color(0xFF4DE5C4); // Accent light

  // Multi-layer Shadow Colors (Softer)
  static const Color shadowLayer1 = Color(0x08000000); // Subtle shadow
  static const Color shadowLayer2 = Color(0x0F000000); // Medium shadow
  static const Color shadowLayer3 = Color(0x15000000); // Strong shadow
  static const Color shadowLayer4 = Color(0x20000000); // Deep shadow

  // Card Gradient Definitions
  static const LinearGradient cardGradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient cardGradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient cardGradientGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassmorphismLight, glassmorphismMedium],
  );

  static const LinearGradient cardGradientDarkGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassmorphismDarkMode, Color(0x30FFFFFF)],
  );

  // Background Gradients
  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF000000), Color(0xFF121212)],
  );

  // Mesh Gradients for Premium Effects
  static const LinearGradient meshGradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [meshGradient1, meshGradient2, meshGradient3, meshGradient4],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Softer Mesh Gradient for Backgrounds
  static const LinearGradient meshGradientSoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1A2A9849), // 10% primary
      Color(0x0D1ED7AA), // 5% accent
      Color(0x1A54B46B), // 10% primary light
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return online;
      case 'offline':
        return offline;
      case 'pending':
        return pending;
      case 'completed':
        return completed;
      default:
        return onSurfaceVariant;
    }
  }

  static Color getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash_on_delivery':
        return cashOnDelivery;
      case 'digital_payment':
        return digitalPayment;
      case 'partial_payment':
        return partialPayment;
      default:
        return onSurfaceVariant;
    }
  }

  static Color getOrderTypeColor(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'food':
        return foodOrder;
      case 'parcel':
        return parcelOrder;
      default:
        return onSurfaceVariant;
    }
  }
}
