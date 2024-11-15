import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Streaming App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LiveStreamPage(),
    );
  }
}

class LiveStreamPage extends StatefulWidget {
  @override
  _LiveStreamPageState createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  bool isRecording = false;
  bool isStreaming = false;
  late FlutterAudioRecorder2 audioRecorder;
  late ZegoExpressEngine zegoEngine;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    initZego();
    initAudioRecorder(); // Initialize the audio recorder
  }

  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.storage].request();
  }

  void initZego() async {
    // Initialize ZegoEngineProfile with required and optional parameters
    ZegoEngineProfile profile = ZegoEngineProfile(
      1234567890,              // Replace with your actual App ID
      ZegoScenario.General,     // Set the scenario
      appSign: "YOUR_APP_SIGN", // Replace with your actual App Sign
    );

    // Initialize the ZegoExpressEngine with the profile (no assignment needed)
    ZegoExpressEngine.createEngineWithProfile(profile);

    // Access the singleton instance of ZegoExpressEngine
    zegoEngine = ZegoExpressEngine.instance;
  }



  void initAudioRecorder() async {
    // Initialize the audio recorder
    audioRecorder = FlutterAudioRecorder2('audio_recording.wav', audioFormat: AudioFormat.WAV);
    await audioRecorder.initialized; // Ensure the recorder is initialized
  }

  Future<void> startRecording() async {
    if (!isRecording) {
      await audioRecorder.start(); // Use the instance method
      setState(() {
        isRecording = true;
      });
    }
  }

  Future<void> stopRecording() async {
    if (isRecording) {
      var recording = await audioRecorder.stop(); // Use the instance method
      print("Path : ${recording?.path}, Duration : ${recording?.duration}");
      setState(() {
        isRecording = false;
      });
    }
  }

  Future<void> startStreaming() async {
    if (!isStreaming) {
      String streamID = "your_stream_id"; // Replace with your actual stream ID
      await zegoEngine.startPublishingStream(streamID); // Start publishing stream using instance method
      setState(() {
        isStreaming = true;
      });
    }
  }

  Future<void> stopStreaming() async {
    if (isStreaming) {
      await zegoEngine.stopPublishingStream(); // Stop publishing stream using instance method
      setState(() {
        isStreaming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Streaming'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(isRecording ? 'Recording...' : 'Not Recording'),
            ElevatedButton(
              onPressed: isRecording ? stopRecording : startRecording,
              child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            Text(isStreaming ? 'Streaming...' : 'Not Streaming'),
            ElevatedButton(
              onPressed: isStreaming ? stopStreaming : startStreaming,
              child: Text(isStreaming ? 'Stop Streaming' : 'Start Streaming'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ZegoExpressEngine.destroyEngine(); // Clean up resources when done
    super.dispose();
  }
}
