import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AR"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ARPage()),
        ),
      ),
    );
  }
}

class ARPage extends StatefulWidget {
  @override
  _ARPageState createState() => _ARPageState();
}

class _ARPageState extends State<ARPage> {
  ArCoreController arCoreController;
  Map<int, ArCoreAugmentedImage> augmentedImagesMap = Map();

  void _onArCoreViewCreated(ArCoreController _arcoreController) async {
    arCoreController = _arcoreController;
    arCoreController.onTrackingImage = _handleOnTrackingImage;
    loadImagesDatabase();
  }

  loadImagesDatabase() async {
    final ByteData bytes = await rootBundle.load('assets/earth.imgdb');
    arCoreController.loadAugmentedImagesDatabase(
        bytes: bytes.buffer.asUint8List());
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    if (!augmentedImagesMap.containsKey(augmentedImage.index)) {
      augmentedImagesMap[augmentedImage.index] = augmentedImage;
      _addSphere(augmentedImage);
    }
  }

  Future _addSphere(ArCoreAugmentedImage augmentedImage) async {
    final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');

    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      textureBytes: textureBytes.buffer.asUint8List(),
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: augmentedImage.extentX / 2,
    );
    final node = ArCoreNode(
      shape: sphere,
    );
    arCoreController.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter AR"),
      ),
      body: ArCoreView(
        type: ArCoreViewType.AUGMENTEDIMAGES,
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
    );
  }
}
