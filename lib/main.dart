import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() {
  runApp(flare_blink_bug());
}

class flare_blink_bug extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> list = List.generate(1000, (idx) => idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, idx) {
              return ListTile(
                title: Text(idx.toString()),
              );
            },
          ),
          Center(
            child: AnimatedPlayPauseButton(),
          ),
        ],
      ),
    );
  }
}

const double _kIconSize = 22.0;

class AnimatedPlayPauseButton extends StatefulWidget {
  AnimatedPlayPauseButton({Key key, this.iconSize, this.size, this.iconColor})
      : super(key: key);

  final double iconSize;
  final double size;
  final Color iconColor;

  AnimatedPlayPauseButtonState createState() => AnimatedPlayPauseButtonState();
}

class AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
    with TickerProviderStateMixin {
  AnimationController controller;
  bool playing = false;

  String _flareAnimation;
  set animation(String value) {
    setState(() {
      _flareAnimation = value;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initial render (I determine this in my app).
    if (playing) {
      _flareAnimation = 'pause';
    } else {
      controller.value = 1.0;
      _flareAnimation = 'play';
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _play() {
    controller.forward();
    animation = 'pause_play';
  }

  void _pause() {
    controller.reverse();
    animation = 'play_pause';
  }

  void _handlePress() {
    if (playing) {
      _pause();
    } else {
      _play();
    }
    playing = !playing;
  }

  @override
  Widget build(BuildContext context) {
    final baseAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slideAnimation =
        Tween(begin: Offset.zero, end: const Offset(0.05, 0.0))
            .animate(baseAnimation);
    final scaleAnimation = Tween(begin: 1.05, end: 0.89).animate(baseAnimation);

    return IconButton(
      iconSize: widget.iconSize ?? _kIconSize,
      onPressed: _handlePress,
      icon: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: FlareActor(
            'assets/play_pause.flr',
            animation: _flareAnimation,
            callback: (value) {
              if (value == 'pause_play' && _flareAnimation != 'play_pause') {
                animation = 'play';
              } else if (value == 'play_pause' &&
                  _flareAnimation != 'pause_play') {
                animation = 'pause';
              }
            },
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
