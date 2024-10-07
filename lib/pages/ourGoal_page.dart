import 'package:flutter/material.dart';
import 'package:myapps/pages/loading_Screen.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart' show rootBundle;

class OurGoalPage extends StatefulWidget {
  const OurGoalPage({Key? key}) : super(key: key);

  @override
  _OurGoalPageState createState() => _OurGoalPageState();
}

class _OurGoalPageState extends State<OurGoalPage>
    with SingleTickerProviderStateMixin {
  bool _showText = true;
  bool _pdfLoaded = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(curve);

    _positionAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0), weight: 30),
    ]).animate(curve);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showText = false;
        });
      }
    });

    _controller.forward();
    _loadPdf(); // Immediately start loading the PDF
  }

  Future<void> _loadPdf() async {
    try {
      final bytes = await rootBundle.load('assets/ourGoal.pdf');
      print('PDF 로드 성공: ${bytes.lengthInBytes} bytes');
      setState(() {
        _pdfLoaded = true;
      });
    } catch (e) {
      print('PDF 로드 실패: $e');
      setState(() {
        _pdfLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _pdfLoaded
        ? Scaffold(
            backgroundColor: Colors.white,
            drawerScrimColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(40.0),
              child: AppBar(
                centerTitle: true,
                title: Text(
                  "해실이의 목표!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.white,
              ),
            ),
            body: Center(
              child: Stack(
                children: [
                  if (_showText)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Positioned(
                          left: 0,
                          right: 0,
                          top: MediaQuery.of(context).size.height / 3 +
                              _positionAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: const Center(
                              child: Text(
                                "우리의 목표를 소개할게요!",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (!_showText)
                    Positioned.fill(
                      child: SfPdfViewer.asset(
                        'assets/ourGoal.pdf',
                        canShowPaginationDialog: false,
                        canShowPageLoadingIndicator: false,
                        pageSpacing: 0,
                        otherSearchTextHighlightColor: Colors.white,
                        currentSearchTextHighlightColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          )
        : LoadingScreen(
            text: 'PDF 불러오는중',
          );
  }
}
