import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';

/// 재사용 가능한 검색창 위젯
/// Debounce 처리 포함
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int debounceDuration; // milliseconds

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.debounceDuration = 300,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // 기존 타이머 취소
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // 새로운 타이머 시작
    _debounce = Timer(Duration(milliseconds: widget.debounceDuration), () {
      widget.onChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '골프장 이름 검색 (예: 스카이72)',
        hintStyle: TextStyles.body1(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textMuted),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
              )
            : null,
      ),
      onChanged: _onSearchChanged,
      style: TextStyles.body1(),
    );
  }

  @override
  void initState() {
    super.initState();
    // 텍스트 변경 리스너 추가 (clear 버튼 표시용)
    widget.controller.addListener(() {
      setState(() {});
    });
  }
}
