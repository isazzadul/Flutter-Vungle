import 'dart:async';
import 'package:flutter/services.dart';

/// User Consent status
///
/// This is for GDPR Users
enum UserConsentStatus {
  Accepted,
  Denied,
}

typedef void OnInitilizeListener();
typedef void OnAdPlayableListener(String placementId, bool playable);
typedef void OnAdStartedListener(String placementId);
// Deprecated
typedef void OnAdFinishedListener(String placementId, bool isCTAClicked, bool isCompletedView);
typedef void OnAdEndListener(String placementId);
typedef void OnAdClickedListener(String placementId);
typedef void OnAdViewedListener(String placementId);
typedef void OnAdRewardedListener(String placementId);
typedef void OnAdLeftApplicationListener(String placementId);

// New native ad listeners
typedef void OnNativeAdLoadedListener(String placementId);
typedef void OnNativeAdLoadFailedListener(String placementId, String error);

class Vungle {
  static const MethodChannel _channel = const MethodChannel('flutter_vungle');

  // Existing listeners
  static OnInitilizeListener? onInitilizeListener;
  static OnAdPlayableListener? onAdPlayableListener;
  static OnAdStartedListener? onAdStartedListener;
  // Deprecated
  static late OnAdFinishedListener onAdFinishedListener;
  static late OnAdEndListener onAdEndListener;
  static late OnAdClickedListener onAdClickedListener;
  static late OnAdViewedListener onAdViewedListener;
  static late OnAdRewardedListener onAdRewardedListener;
  static late OnAdLeftApplicationListener onAdLeftApplicationListener;

  // New native ad listeners
  static late OnNativeAdLoadedListener onNativeAdLoadedListener;
  static late OnNativeAdLoadFailedListener onNativeAdLoadFailedListener;

  /// Get version of Vungle native SDK
  static Future<String> getSDKVersion() async {
    final String? version = await _channel.invokeMethod('sdkVersion');
    return version ?? "";
  }

  /// Initialize the flutter plugin for Vungle SDK.
  static void init(String appId) {
    // Register callback method handler
    _channel.setMethodCallHandler(_handleMethod);

    _channel.invokeMethod('init', <String, dynamic>{
      'appId': appId,
    });
  }

  /// Enable background download for Vungle iOS SDK.
  static void enableBackgroundDownload(bool enabled) {
    _channel.invokeMethod('enableBackgroundDownload', <String, dynamic>{
      'enabled': enabled,
    });
  }

  /// Load Ad by a [placementId]
  static void loadAd(String placementId) {
    _channel.invokeMethod('loadAd', <String, dynamic>{
      'placementId': placementId,
    });
  }

  /// Play ad by a [placementId]
  static void playAd(String placementId) {
    _channel.invokeMethod('playAd', <String, dynamic>{
      'placementId': placementId,
    });
  }

  /// Check if ad is playable by a [placementId]
  static Future<bool> isAdPlayable(String placementId) async {
    final bool? isAdAvailable =
    await _channel.invokeMethod('isAdPlayable', <String, dynamic>{
      'placementId': placementId,
    });
    return isAdAvailable ?? false;
  }

  /// Update Consent Status
  static void updateConsentStatus(UserConsentStatus status, String consentMessageVersion) {
    _channel.invokeMethod('updateConsentStatus', <String, dynamic>{
      'consentStatus': status.name,
      'consentMessageVersion': consentMessageVersion,
    });
  }

  /// Get Consent Status
  static Future<UserConsentStatus> getConsentStatus() async {
    final String? status = await _channel.invokeMethod('getConsentStatus', null);
    if (status == null) {
      return UserConsentStatus.Denied;
    }
    if (_statusStringToUserConsentStatus.containsKey(status)) {
      return _statusStringToUserConsentStatus[status] ?? UserConsentStatus.Denied;
    }
    return UserConsentStatus.Denied;
  }

  /// Get Consent Message version
  static Future<String> getConsentMessageVersion() async {
    final String? version = await _channel.invokeMethod('getConsentMessageVersion', null);
    return version ?? "";
  }

  // Map to convert consent status from string to enum
  static const Map<String, UserConsentStatus> _statusStringToUserConsentStatus = {
    'Accepted': UserConsentStatus.Accepted,
    'Denied': UserConsentStatus.Denied,
  };

  /// Load Native Ad by a [placementId]
  static void loadNativeAd(String placementId) {
    _channel.invokeMethod('loadNativeAd', <String, dynamic>{
      'placementId': placementId,
    });
  }

  /// Method Call Handler for different events from the native side
  static Future<dynamic> _handleMethod(MethodCall call) {
    print('_handleMethod: ${call.method}, ${call.arguments}');
    final Map<dynamic, dynamic>? arguments = call.arguments;
    final String method = call.method;

    if (method == 'onInitialize') {
      if (onInitilizeListener != null) {
        onInitilizeListener!();
      }
    } else if (method == 'onAdPlayable') {
      final String placementId = arguments!['placementId'] ?? "";
      final bool playable = arguments['playable'] ?? false;
      if (onAdPlayableListener != null) {
        onAdPlayableListener!(placementId, playable);
      }
    } else if (method == 'onAdStarted') {
      final String placementId = arguments!['placementId'] ?? "";
      if (onAdStartedListener != null) {
        onAdStartedListener!(placementId);
      }
    } else if (method == 'onAdFinished') {
      final String placementId = arguments!['placementId'] ?? "";
      final bool isCTAClicked = arguments['isCTAClicked'] ?? false;
      final bool isCompletedView = arguments['isCompletedView'] ?? false;
      onAdFinishedListener(placementId, isCTAClicked, isCompletedView);
    } else if (method == 'onAdEnd') {
      final String placementId = arguments!['placementId'] ?? "";
      onAdEndListener(placementId);
    } else if (method == 'onAdClicked') {
      final String placementId = arguments!['placementId'] ?? "";
      onAdClickedListener(placementId);
    } else if (method == 'onAdViewed') {
      final String placementId = arguments!['placementId'] ?? "";
      onAdViewedListener(placementId);
    } else if (method == 'onAdRewarded') {
      final String placementId = arguments!['placementId'] ?? "";
      onAdRewardedListener(placementId);
    } else if (method == 'onAdLeftApplication') {
      final String placementId = arguments!['placementId'] ?? "";
      onAdLeftApplicationListener(placementId);
    } else if (method == 'onNativeAdLoaded') {
      final String placementId = arguments!['placementId'] ?? "";
      onNativeAdLoadedListener(placementId);
    } else if (method == 'onNativeAdLoadFailed') {
      final String placementId = arguments!['placementId'] ?? "";
      final String error = arguments['error'] ?? "Unknown error";
      onNativeAdLoadFailedListener(placementId, error);
    } else {
      throw new MissingPluginException("Method not implemented: $method");
    }
    return Future<dynamic>.value(null);
  }
}
