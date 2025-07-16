import 'package:flutter/material.dart';

class BarcodeScannerWidget extends StatefulWidget {
  const BarcodeScannerWidget({super.key, required this.onBarcodeScanned});

  final Function(String) onBarcodeScanned;

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 전역 키보드 리스너가 있으므로 자동 포커스 제거
    // _barcodeFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  void _handleBarcodeSubmit() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      widget.onBarcodeScanned(barcode);
      _barcodeController.clear();
      _barcodeFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.blue[600], size: 16),
                const SizedBox(width: 6),
                const Text(
                  '바코드 스캔',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          // 바코드 입력 필드
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocusNode,
                    decoration: InputDecoration(
                      hintText: '바코드 입력',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    onSubmitted: (_) => _handleBarcodeSubmit(),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: _handleBarcodeSubmit,
                  icon: const Icon(Icons.qr_code_scanner, size: 14),
                  label: const Text('스캔', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: const Size(60, 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
