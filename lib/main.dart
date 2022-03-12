import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:maskdetection/result_provider.dart';
import 'package:provider/provider.dart';
import 'package:tflite/tflite.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => ResultProvider(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int page = 0;
  CameraImage? cameraImage;
  int y = 0;
  CameraController? cameraController;
  String result = "";
  changecamera() {
    setState(() {
      y = (y == 0) ? 1 : 0;
      initCamera();
    });
  }

  initCamera() {
    cameraController = CameraController(cameras![y], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) return;
      setState(() {
        cameraController!.startImageStream((imageStream) {
          cameraImage = imageStream;
        });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  runModel() async {
    if (cameraImage != null) {
      result = "without_mask";
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true);
      debugPrint(recognitions.toString());
      Provider.of<ResultProvider>(context, listen: false).change(recognitions!);
    }
  }

  @override
  void dispose() {
    cameraController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Face Mask Detector"),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  changecamera();
                },
                icon: const Icon(Icons.cameraswitch_outlined))
          ],
        ),
        bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        page = 0;
                      });
                    },
                    icon: Icon(
                      Icons.home,
                      color: (page == 0) ? Colors.red : Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      page = 1;
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.info,
                      color: (page == 1) ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            )),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () {
              runModel();
            },
            child: const Icon(Icons.camera),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: IndexedStack(
          index: page,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 118,
                    width: MediaQuery.of(context).size.width,
                    child: !cameraController!.value.isInitialized
                        ? Container()
                        : AspectRatio(
                            aspectRatio: cameraController!.value.aspectRatio,
                            child: CameraPreview(cameraController!),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 30,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Consumer<ResultProvider>(
                        builder: (_, value, __) => Text(
                          value.ismask ? value.withmask.replaceAll("_", " ") : value.withoutmask.replaceAll("_", " "),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListView(
              physics: const BouncingScrollPhysics(),
              children:  [
                Image.asset("assets/ic_launcher.png"),
                const ListTile(
                  title: Text("Made by"),
                  subtitle: Text("Yogesh Pandit"),
                ),
                const ListTile(
                  title: Text("Tools Used:"),
                  subtitle: Text("Flutter"),
                ),
                const ListTile(
                  title: Text("Machine Learning:"),
                  subtitle: Text("Google Teachable (Tensorflow)"),
                ),
                const ListTile(
                  title: Text("Training Samples:"),
                  subtitle: Text("with mask : 3850 \nwithout mask : 2998 "),
                ),
                const ListTile(
                  title: Text("Accuracy:"),
                  subtitle: Text("20%"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
