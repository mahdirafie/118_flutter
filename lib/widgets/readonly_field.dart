import 'package:flutter/material.dart';

class ReadonlyTextField extends StatefulWidget {
  final String title;
  final String value;
  final IconData? prefixIcon;
  final String? actionText;
  final VoidCallback? actionCallback;
  final Widget? suffixWidget;
  final Color? focusedBorderColor;
  final Color? unfocusedBorderColor;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const ReadonlyTextField({
    super.key,
    required this.title,
    required this.value,
    this.prefixIcon,
    this.actionText,
    this.actionCallback,
    this.suffixWidget,
    this.focusedBorderColor,
    this.unfocusedBorderColor,
    this.titleStyle,
    this.valueStyle,
    this.readOnly = true,
    this.onTap,
    this.contentPadding,
  });

  @override
  State<ReadonlyTextField> createState() => _ReadonlyTextFieldState();
}

class _ReadonlyTextFieldState extends State<ReadonlyTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate consistent padding
    final hasPrefix = widget.prefixIcon != null || 
                     (widget.actionText != null && widget.actionCallback != null);
    final defaultPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    final adjustedPadding = widget.contentPadding ?? defaultPadding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The actual TextField
            TextField(
              readOnly: widget.readOnly,
              controller: TextEditingController(text: widget.value),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onTap: widget.onTap,
              decoration: InputDecoration(
                labelText: widget.title,
                labelStyle: TextStyle(
                  color: _isFocused
                      ? (widget.focusedBorderColor ?? colorScheme.primary)
                      : Colors.grey.shade700,
                  backgroundColor: Colors.white,
                  fontSize: _isFocused ? 13 : 16,
                  height: _isFocused ? 1.0 : 1.5,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelAlignment: FloatingLabelAlignment.start,
                alignLabelWithHint: true,
                // Use consistent content padding
                contentPadding: adjustedPadding,
                // Add prefix icon constraints to maintain alignment
                prefixIconConstraints: hasPrefix 
                    ? const BoxConstraints(minWidth: 0, minHeight: 0)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.unfocusedBorderColor ?? Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.unfocusedBorderColor ?? Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.focusedBorderColor ?? colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                prefixIcon: _buildPrefixContent(),
                suffixIcon: widget.suffixWidget,
                filled: false,
                isDense: true,
              ),
              style: widget.valueStyle ??
                  textTheme.bodyMedium!.copyWith(
                    fontSize: 16,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildPrefixContent() {
    if (widget.prefixIcon == null && 
        widget.actionText == null && 
        widget.actionCallback == null) {
      return null;
    }

    return Container(
      // This container ensures consistent width for both icon and action button
      constraints: const BoxConstraints(minWidth: 40),
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action button (if provided)
          if (widget.actionText != null && widget.actionCallback != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildActionButton(),
            ),
          
          // Prefix icon
          if (widget.prefixIcon != null)
            Icon(
              widget.prefixIcon,
              size: 20,
              color: _isFocused
                  ? (widget.focusedBorderColor ?? Theme.of(context).colorScheme.primary)
                  : Colors.grey.shade700,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: widget.actionCallback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          widget.actionText!,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}