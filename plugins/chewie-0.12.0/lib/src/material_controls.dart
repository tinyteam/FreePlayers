import 'dart:async';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/material_progress_bar.dart';
import 'package:chewie/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MaterialControls extends StatefulWidget {
  const MaterialControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls>
    with SingleTickerProviderStateMixin {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  bool _hideTime = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  final barHeight = 100.0;
  final marginSize = 5.0;

  VideoPlayerController controller;
  ChewieController chewieController;
  AnimationController playPauseIconAnimationController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        onDoubleTap: () => _onExpandCollapse(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Container(
            child: Stack(
              children: <Widget>[
                _latestValue != null &&
                            !_latestValue.isPlaying &&
                            _latestValue.duration == null ||
                        _latestValue.isBuffering
                    ? const Expanded(
                        child: const Center(
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    : _buildHitArea(),
                Positioned(
                  bottom: 0,
                  child: _buildBottomBar(context),
                ),
                // Positioned(
                //   bottom: 0,
                //   child: chewieController.allowFullScreen
                //       ? _buildExpandButton()
                //       : Container(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (playPauseIconAnimationController == null) {
      playPauseIconAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
        reverseDuration: Duration(milliseconds: 400),
      );
    }

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return AnimatedOpacity(
      // opacity: _hideStuff ? 0.0 : 1.0,
      opacity: 1.0,

      duration: Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 60,
              child: AnimatedOpacity(
                opacity: _hideTime ? 0.0 : 1.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  child: chewieController.isLive
                      ? Expanded(child: const Text('LIVE'))
                      : _buildPosition(iconColor),
                ),
              ),
            ),
            GestureDetector(
              onTapDown: (details) {
                setState(() {
                  this._hideTime = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  this._hideTime = true;
                });
              },
              child: Container(
                height: 10,
                child: chewieController.isLive
                    ? const SizedBox()
                    : _buildProgressBar(),
              ),
            ),
            !chewieController.isFullScreen
                ? Container()
                : Container(
                    height: 40,
                    child: Row(
                      children: <Widget>[
                        _buildPlayPause(controller),
                        chewieController.allowPlaybackSpeedChanging
                            ? _buildSpeedButton(controller)
                            : Container(),
                        chewieController.allowMuting
                            ? _buildMuteButton(controller)
                            : Container(),
                        chewieController.allowFullScreen
                            ? _buildExpandButton()
                            : Container(),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        // opacity: _hideStuff ? 0.0 : 1.0,
        opacity: 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          margin: EdgeInsets.only(right: 12.0),
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
            ),
          ),
        ),
      ),
    );
  }

  Container _buildHitArea() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    return Container(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null && _latestValue.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else
              _cancelAndRestartTimer();
          } else {
            _playPause();

            setState(() {
              _hideStuff = true;
            });
          }
          print("sdfaaaaaaaddddddddddddddddddd");
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: IconButton(
                        icon: isFinished
                            ? Icon(Icons.replay, size: 32.0)
                            : AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: playPauseIconAnimationController,
                                size: 32.0,
                              ),
                        onPressed: () {
                          _playPause();
                        }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final chosenSpeed = await showModalBottomSheet<double>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _PlaybackSpeedDialog(
            speeds: chewieController.playbackSpeeds,
            selected: _latestValue.playbackSpeed,
          ),
        );

        if (chosenSpeed != null) {
          controller.setPlaybackSpeed(chosenSpeed);
        }

        if (_latestValue.isPlaying) {
          _startHideTimer();
        }
      },
      child: AnimatedOpacity(
        // opacity: _hideStuff ? 0.0 : 1.0,
        opacity: 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(Icons.speed),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        // opacity: _hideStuff ? 0.0 : 1.0,
        opacity: 1.0,

        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(
                (_latestValue != null && _latestValue.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 8.0, right: 4.0),
        padding: EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(right: 24.0),
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished;
    if (_latestValue.duration != null) {
      isFinished = _latestValue.position >= _latestValue.duration;
    } else {
      isFinished = false;
    }

    setState(() {
      if (controller.value.isPlaying) {
        playPauseIconAnimationController.reverse();
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
            playPauseIconAnimationController.forward();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          playPauseIconAnimationController.forward();
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: EdgeInsets.only(right: 10.0, left: 10.0),
      child: MaterialVideoProgressBar(
        controller,
        onDragStart: () {
          setState(() {
            _dragging = true;
            this._hideTime = false;
          });

          _hideTimer?.cancel();
        },
        onDragEnd: () {
          setState(() {
            _dragging = false;
            this._hideTime = true;
          });

          _startHideTimer();
        },
        colors: chewieController.materialProgressColors ??
            ChewieProgressColors(
                playedColor: Theme.of(context).disabledColor,
                handleColor: Theme.of(context).accentColor,
                bufferedColor: Colors.grey[800],
                backgroundColor: Colors.grey[800]),
      ),
    );
  }
}

class _PlaybackSpeedDialog extends StatelessWidget {
  const _PlaybackSpeedDialog({
    Key key,
    @required List<double> speeds,
    @required double selected,
  })  : _speeds = speeds,
        _selected = selected,
        super(key: key);

  final List<double> _speeds;
  final double _selected;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).primaryColor;

    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemBuilder: (context, index) {
        final _speed = _speeds[index];
        return ListTile(
          dense: true,
          title: Row(
            children: [
              _speed == _selected
                  ? Icon(
                      Icons.check,
                      size: 20.0,
                      color: selectedColor,
                    )
                  : Container(width: 20.0),
              SizedBox(width: 16.0),
              Text(_speed.toString()),
            ],
          ),
          selected: _speed == _selected,
          onTap: () {
            Navigator.of(context).pop(_speed);
          },
        );
      },
      itemCount: _speeds.length,
    );
  }
}
