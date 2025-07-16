import 'package:flutter/material.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerWidget({super.key, required this.onBarcodeScanned});

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _barcodeFocusNode.requestFocus();
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
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  '바코드 스캔',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          // 바코드 입력 필드
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocusNode,
                    decoration: InputDecoration(
                      hintText: '바코드를 스캔하거나 수동으로 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _handleBarcodeSubmit,
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    onSubmitted: (_) => _handleBarcodeSubmit(),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _handleBarcodeSubmit,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('스캔'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // 테스트 바코드 버튼들
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTestBarcodeButton('콜라', '8801234567890'),
                _buildTestBarcodeButton('사이다', '8801234567891'),
                _buildTestBarcodeButton('초코바', '8801234567895'),
                _buildTestBarcodeButton('생수', '8801234567898'),
                _buildTestBarcodeButton('에너지드링크', '8801234567901'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestBarcodeButton(String label, String barcode) {
    return ElevatedButton(
      onPressed: () {
        widget.onBarcodeScanned(barcode);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}
