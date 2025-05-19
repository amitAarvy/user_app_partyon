
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/utils/utils.dart';
import 'package:video_player/video_player.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoURL;
  final Text title;

  const VideoPlayerScreen(
      {super.key, required this.title, required this.videoURL});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    initializePlayer();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.network(widget.videoURL,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      allowPlaybackSpeedChanging: false,
      autoPlay: true,
      looping: true,
      allowMuting: true,
      allowedScreenSleep: false,
      fullScreenByDefault: true,
      materialProgressColors: ChewieProgressColors(playedColor: themeRed()),
      playbackSpeeds: [],
      overlay: Align(
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 200.h,
              width: 200.h,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset('assets/logo.png'),
              ),
            ).paddingAll(10.h),
            SizedBox(
              height: 200.h,
              width: 200.h,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.circle,
                      size: 50.h,
                      color: Colors.red,
                    ),
                    onPressed: () {},
                  ),
                  Text(
                    'Live Now',
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 35.sp,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: widget.title,
      backgroundColor: themeRed(),
    ),
    backgroundColor: matte(),
    body: SafeArea(
      // Add SafeArea
      child: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: chewieController != null &&
            chewieController
                .videoPlayerController.value.isInitialized
            ? AspectRatio(
          // Add AspectRatio
          aspectRatio: chewieController
              .videoPlayerController.value.aspectRatio,
          child: Chewie(controller: chewieController),
        )
            : const CircularProgressIndicator(),
      ),
    ),
  );
}
