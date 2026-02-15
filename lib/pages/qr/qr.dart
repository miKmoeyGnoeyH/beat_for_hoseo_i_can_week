import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/point/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';

import '../../widgets/index.dart';

class QR extends StatefulWidget {
  const QR({super.key, ScrollController? scrollController})
    : _scrollController = scrollController;

  @override
  State<QR> createState() => _QRState();

  final ScrollController? _scrollController;
}

class _QRState extends State<QR> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;

  final QuestListController questListController = QuestListController.to;

  final PointController pointController = PointController.to;

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  MobileScannerController mobileScannerController = MobileScannerController();

  Timer? scanTimer;

  @override
  void initState() {
    mobileScannerController = MobileScannerController();
    super.initState();
  }

  void startScanTimer() {
    scanTimer = Timer(const Duration(seconds: 3), () {
      scanTimer?.cancel();
    });
  }

  Future<void> requestMissionCheck(
    String requestUrl,
    double latitude,
    double longitude,
  ) async {
    final String authorization = authenticationController.state!.authorization;

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 100));
          return await APIService().post(
            endpoint: requestUrl,
            header: {
              "Content-Type": "application/json",
              "authorization": authorization,
            },
            body: jsonEncode({"latitude": latitude, "longitude": longitude}),
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      log(response.body);

      switch (response.statusCode) {
        case 200:
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService.instance.qrScanSuccessTitle,
              message: LocalizationService
                  .instance
                  .qrScanSuccessQuestCompleteContent,
              onConfirm: () => pointController.fetchPointBalance(authorization),
            ),
          );
          break;
        default:
          throw BEATException(
            title: LocalizationService.instance.errorQRScanFailed,
            message:
                LocalizationService.instance.errorQRScanFailedDefaultContent,
          );
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATException catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(e);
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(
        BEATException(
          title: LocalizationService.instance.errorValidateNicknameFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

  Future<void> requestCreditCheck(String requestUrl) async {
    final String authorization = authenticationController.state!.authorization;

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 100));
          return await APIService().post(
            endpoint: requestUrl,
            header: {
              "Content-Type": "application/json",
              "authorization": authorization,
            },
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      log(response.body);

      switch (response.statusCode) {
        case 200:
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService.instance.qrScanSuccessTitle,
              message: LocalizationService
                  .instance
                  .qrScanSuccessQuestCompleteContent,
              onConfirm: () =>
                  questListController.fetchQuestList(authorization),
            ),
          );
          break;
        default:
          throw BEATException(
            title: LocalizationService.instance.errorQRScanFailed,
            message:
                LocalizationService.instance.errorQRScanFailedDefaultContent,
          );
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATException catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(e);
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(
        BEATException(
          title: LocalizationService.instance.errorValidateNicknameFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    mobileScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: mobileScannerController,
          scanWindow: Rect.fromCenter(
            center: MediaQuery.sizeOf(context).center(const Offset(0, -100)),
            width: 220,
            height: 220,
          ),
          onDetect: (BarcodeCapture capture) async {
            if (scanTimer != null && scanTimer!.isActive) return;

            if (_isScanning) return;
            _isScanning = true;

            final List<Barcode> barcodes = capture.barcodes;
            final Barcode barcode = barcodes.first;
            if (barcode.rawValue == null) return;

            final String requestUrl = barcode.rawValue!;

            log("requestUrl : $requestUrl");

            if (missionCheckQR.hasMatch(requestUrl)) {
              Position position = await Geolocator.getCurrentPosition(
                locationSettings: locationSettings,
              );
              await requestMissionCheck(
                requestUrl,
                position.latitude,
                position.longitude,
              );
              startScanTimer();
              _isScanning = false;
              return;
            } else if (creditQR.hasMatch(requestUrl)) {
              await requestCreditCheck(requestUrl);
              startScanTimer();
              _isScanning = false;
              return;
            } else {
              DialogService.to.addDialogEvent(
                AlertDialogEvent(
                  title: LocalizationService.instance.errorQRScanFailed,
                  message: LocalizationService.instance.errorInvalidQR,
                  onConfirm: () {
                    startScanTimer();
                    _isScanning = false;
                  },
                ),
              );
              return;
            }
          },
        ),
        Container(
          decoration: ShapeDecoration(
            shape: QROverlay(
              borderColor: AppColors.primary,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutWidth: 200,
              cutOutHeight: 200,
            ),
          ),
        ),
      ],
    );
  }

  bool _isScanning = false;
}
