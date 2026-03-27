import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Services/payments.dart';

class EnterAmount extends StatefulWidget {
  final String vendor;
  final String qrdata;
  const EnterAmount({super.key, required this.vendor, required this.qrdata});

  @override
  State<EnterAmount> createState() => _EnterAmountState();
}

class _EnterAmountState extends State<EnterAmount> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  final Services _services = Services();

  late FocusNode _pinFocus;
  late FocusNode _confirmPinFocus;
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _pinFocus = FocusNode();
    _confirmPinFocus = FocusNode();
    _activeController = _pinController;

    _pinFocus.addListener(() {
      if (_pinFocus.hasFocus)
        setState(() => _activeController = _pinController);
    });
    _confirmPinFocus.addListener(() {
      if (_confirmPinFocus.hasFocus)
        setState(() => _activeController = _confirmPinController);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (_pinController.text.isEmpty) return false;
    int x = int.parse(_pinController.text);
    if (x <= 0 || x > 4500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter valid amount',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Cinzel", fontSize: 20.r),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    } else if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must consent before proceeding.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Cinzel", fontSize: 20.r),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  void _onKeyPressed(String key) {
    if (_activeController == null) return;
    setState(() {
      if (key == '<') {
        if (_activeController!.text.isNotEmpty) {
          _activeController!.text = _activeController!.text.substring(
            0,
            _activeController!.text.length - 1,
          );
        }
      } else {
        if (_activeController!.text.length < 4) {
          _activeController!.text += key;
        }
      }
    });
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
  }) {
    bool isActive = focusNode.hasFocus;
    return Container(
      width: 343.w,
      height: 72.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark mode surface
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          width: 1.w,
          color: isActive ? const Color(0xFF2563EB) : const Color(0xFF334155),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 0, 0),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: true, // Prevents system keyboard from popping up
            showCursor: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.r,
              color: const Color(0xFFF1F5F9), // Digits color requested
              fontFamily: 'Albert',
            ),
            decoration: InputDecoration(
              prefixText: "₹ ",
              prefixStyle: TextStyle(
                fontSize: 30.h,
                color: const Color(0xFFF1F5F9),
                fontFamily: 'Albert',
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 20.r,
                color: const Color(0xFF94A3B8),
                fontFamily: 'Albert',
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyPad() {
    return Column(
      children: [
        _buildKeyPadRow(['1', '2', '3']),
        SizedBox(height: 16.h),
        _buildKeyPadRow(['4', '5', '6']),
        SizedBox(height: 16.h),
        _buildKeyPadRow(['7', '8', '9']),
        SizedBox(height: 16.h),
        _buildKeyPadRow(['.', '0', '<']),
      ],
    );
  }

  bool _isChecked = false;

  Widget _buildConsentBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isChecked = !_isChecked;
              });
            },
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: _isChecked
                    ? const Color(0xFF2563EB)
                    : Colors.transparent,
                border: Border.all(
                  color: _isChecked
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: _isChecked
                  ? Icon(Icons.check, size: 14.r, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "I consent for the amount to be deducted from my SWD balance",
              style: TextStyle(
                fontSize: 14.r,
                color: const Color(0xFFCBD5F5),
                fontFamily: 'Albert',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPadRow(List<String> keys) {
    return SizedBox(
      width: 342.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) {
      return SizedBox(width: 103.33.w, height: 64.h);
    }
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 103.33.w, // Dimensions requested
        height: 64.h, // Dimensions requested
        alignment: Alignment.center,
        child: key == '<'
            ? Icon(
                Icons.backspace_outlined,
                color: const Color(0xFFF1F5F9),
                size: 28.r,
              )
            : Text(
                key,
                style: TextStyle(
                  fontSize: 32.h,
                  color: const Color(0xFFF1F5F9), // White color for digits
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF111111), // Dark mode background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 375.w,
                  height: 54.h,
                  child: Center(
                    child: Text(
                      "ENTER AMOUNT",
                      style: TextStyle(
                        fontSize: 36.r,
                        color: Colors.white,
                        fontFamily: 'Orbitron_Bold',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 36.h),
                Center(
                  child: Text(
                    "Paying to ${widget.vendor}",
                    style: TextStyle(
                      fontSize: 20.r,
                      color: Colors.grey,
                      fontFamily: 'Orbitron_Bold',
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildInputBox(
                  controller: _pinController,
                  focusNode: _pinFocus,
                  hint: "ENTER YOUR AMOUNT",
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w),
                  child: _buildConsentBox(),
                ),
                SizedBox(height: 40.h),
                _buildKeyPad(),
                SizedBox(height: 40.h),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          if (_validateFields()) {
                            //navigate to next page
                          }
                        },
                  child: Container(
                    height: 56.h, // Requested container dimension
                    width: 342.w, // Requested container dimension
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? const Color(0xFF334155)
                          : const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'PAY',
                              style: TextStyle(
                                fontFamily: 'Orbitron_Bold',
                                color: Colors.white,
                                fontSize: 20.r,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
