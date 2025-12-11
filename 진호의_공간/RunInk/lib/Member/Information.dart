import 'package:flutter/material.dart';

import 'Watch.dart';


class Information extends StatelessWidget {
  const Information({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TermsOfServiceAgreement(),
    );
  }
}

class TermsOfServiceAgreement extends StatefulWidget {
  const TermsOfServiceAgreement({super.key});

  @override
  State<TermsOfServiceAgreement> createState() => _TermsOfServiceAgreementState();
}

class _TermsOfServiceAgreementState extends State<TermsOfServiceAgreement> {
  List<bool> _isChecked = List.generate(5, (_) => false);

  bool get _buttonActive => _isChecked[1] && _isChecked[2] && _isChecked[3];

  void _updateCheckState(int index) {
    setState(() {
      // 모두 동의 체크박스일 경우
      if (index == 0) {
        bool isAllChecked = !_isChecked.every((element) => element);
        _isChecked = List.generate(5, (index) => isAllChecked);
      } else {
        _isChecked[index] = !_isChecked[index];
        _isChecked[0] = _isChecked.getRange(1, 5).every((element) => element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('회원가입 약관 동의', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700)),
            const SizedBox(height: 50),
            ..._renderCheckList(),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: _buttonActive ? Color(0xFF1287AE) : Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Watch()),
                      );
                    },
                    child: const Text('가입하기',style: TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.white),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderCheckList() {
    List<String> labels = [
      '모두 동의',
      '만 14세 이상입니다.(필수)',
      '개인정보처리방침(필수)',
      '서비스 이용 약관(필수)',
      '이벤트 및 할인 혜택 안내 동의(선택)',
    ];

    List<Widget> list = [
      renderContainer(_isChecked[0], labels[0], () => _updateCheckState(0)),
      const Divider(thickness: 1.0),
    ];

    list.addAll(List.generate(4, (index) => renderContainer(_isChecked[index + 1], labels[index + 1], () => _updateCheckState(index + 1))));

    return list;
  }

  Widget renderContainer(bool checked, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),

        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: checked ? Color(0xFF1287AE) : Colors.grey, width: 2.0),
                color: checked ? Color(0xFF1287AE) : Colors.white,
              ),
              child: Icon(Icons.check, color: checked ? Colors.white : Colors.grey, size: 18),
            ),
            const SizedBox(width: 15),
            Text(text, style: const TextStyle(color: Colors.grey, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
