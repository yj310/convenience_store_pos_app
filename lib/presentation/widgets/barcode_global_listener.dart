import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class BarcodeGlobalListener extends StatefulWidget {
  final Widget child;
  final Function(String) onBarcodeScanned;

  const BarcodeGlobalListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
  });

  @override
  State<BarcodeGlobalListener> createState() => _BarcodeGlobalListenerState();
}

class _BarcodeGlobalListenerState extends State<BarcodeGlobalListener> {
  final TextEditingController _barcodeBuffer = TextEditingController();
  Timer? _barcodeTimer;
  bool _isProcessing = false;

  @override
  void dispose() {
    _barcodeTimer?.cancel();
    _barcodeBuffer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        print('키보드 이벤트 감지: ${event.logicalKey.keyLabel}');
        if (event is KeyDownEvent && !_isProcessing) {
          _handleKeyPress(event);
        }
        return KeyEventResult.handled;
      },
      child: widget.child,
    );
  }

  void _handleKeyPress(KeyEvent event) {
    // 숫자 키만 처리 (바코드는 숫자로만 구성)
    if (event.logicalKey.keyLabel.length == 1 &&
        RegExp(r'[0-9]').hasMatch(event.logicalKey.keyLabel)) {
      _barcodeBuffer.text += event.logicalKey.keyLabel;
      print(
        '바코드 입력 감지: ${event.logicalKey.keyLabel} (현재 버퍼: ${_barcodeBuffer.text})',
      );

      // 타이머 리셋
      _barcodeTimer?.cancel();
      _barcodeTimer = Timer(const Duration(milliseconds: 200), () {
        // 200ms 후에 바코드 처리
        _processBarcode();
      });
    }

    // 엔터키 처리
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      print('엔터키 감지 - 바코드 처리 시작');
      _processBarcode();
    }
  }

  void _processBarcode() {
    if (_isProcessing) return;

    final barcode = _barcodeBuffer.text.trim();
    print('바코드 처리 시작: $barcode (길이: ${barcode.length})');

    if (barcode.isNotEmpty && barcode.length >= 10) {
      // 최소 길이 체크
      _isProcessing = true;
      print('바코드 스캔 완료: $barcode');

      // 바코드 처리
      widget.onBarcodeScanned(barcode);

      // 처리 완료 후 버퍼 클리어
      _barcodeBuffer.clear();

      // 잠시 후 처리 상태 해제
      Timer(const Duration(milliseconds: 500), () {
        _isProcessing = false;
        print('바코드 처리 상태 해제');
      });
    } else {
      print('바코드 길이 부족 또는 빈 바코드: $barcode');
    }
    _barcodeTimer?.cancel();
  }
}
