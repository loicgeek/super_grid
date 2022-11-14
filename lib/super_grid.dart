import './custom_finger_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SuperGrid extends StatefulWidget {
  const SuperGrid({super.key});

  @override
  State<SuperGrid> createState() => _SuperGridState();
}

class _SuperGridState extends State<SuperGrid> {
  int _crossAxisCount = 3;
  int _baseCrossAxisCount = 3;
  double _baseScale = 1;
  double _currentScale = 1;
  int _pointers = 0;
  //Vertical drag details
  DragStartDetails? startVerticalDragDetails;
  DragUpdateDetails? updateVerticalDragDetails;

  final controller = CustomFingerListViewController(fingerCount: 2);

  @override
  void initState() {
    super.initState();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    print("Pointers: $_pointers");
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }
    print("details.scale: ${details.scale}");
    _currentScale = (_baseScale * details.scale).clamp(1, 3);
    _crossAxisCount = (_baseCrossAxisCount * _currentScale).toInt();
    print("_baseCrossAxisCount ${_baseCrossAxisCount}");
    print("Current scale ${_currentScale}");
    print("_crossAxisCount ${_crossAxisCount}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Super Grid"),
      ),
      body: Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          child: CustomFingerListViewParent(
            controller: controller,
            child: GridView.builder(
              physics: CustomFingerScrollPhysics(controller: controller),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
              ),
              itemCount: 50,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
