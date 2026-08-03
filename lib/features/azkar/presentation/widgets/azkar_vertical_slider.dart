import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/azkar_entity.dart';
import '../../../../core/services/azkar_audio_service.dart';
import '../../../settings/presentation/controllers/settings_cubit.dart';
import 'zekr_widget.dart';

class AzkarVerticalSlider extends StatefulWidget {
  const AzkarVerticalSlider({
    super.key,
    required this.azkarList,
    required this.onTapCounter,
    required this.totalAzkarCount,
  });

  final List<AzkarEntity> azkarList;
  final void Function(AzkarEntity azkar) onTapCounter;
  final int totalAzkarCount;

  @override
  State<AzkarVerticalSlider> createState() => _AzkarVerticalSliderState();
}

class _AzkarVerticalSliderState extends State<AzkarVerticalSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSession? _audioSession;
  Future<void>? _audioSessionReady;
  int _activeIndex = 0;
  int? _audioIndex;
  int _playbackId = 0;
  bool _isAudioPlaying = false;
  String? _downloadingUrl;
  double? _downloadProgress;
  bool _allAudioDownloaded = false;
  final Map<String, String> _localAudioPaths = {};
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _cardKeys = [];
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _ensureCardKeys();
    _refreshAudioStatus();
    _audioSessionReady = _configureAudioSession();
  }

  @override
  void didUpdateWidget(covariant AzkarVerticalSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureCardKeys();
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureCardKeys() {
    while (_cardKeys.length < widget.azkarList.length) {
      _cardKeys.add(GlobalKey());
    }
    if (_cardKeys.length > widget.azkarList.length) {
      _cardKeys.removeRange(widget.azkarList.length, _cardKeys.length);
    }
  }

  Future<void> _refreshAudioStatus() async {
    final urls = widget.azkarList
        .map((azkar) => azkar.audioUrl)
        .whereType<String>()
        .toSet();
    final downloaded = await AzkarAudioService.areAllDownloaded(urls);
    if (mounted) setState(() => _allAudioDownloaded = downloaded);
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _audioSession = session;
  }

  void _scrollToActive() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardContext = _cardKeys[_activeCurrentIndex].currentContext;
      if (mounted && cardContext != null) {
        Scrollable.ensureVisible(
          cardContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
    });
  }

  void _finishSession() {
    if (_finished) return;
    _playbackId++;
    _isAudioPlaying = false;
    unawaited(_audioPlayer.stop());
    setState(() => _finished = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _cancelPlayback() {
    _playbackId++;
    _isAudioPlaying = false;
    unawaited(_audioPlayer.stop());
  }

  Future<void> _playAudioSequenceFrom(int startIndex) async {
    if (_finished || !mounted) return;
    final playbackId = ++_playbackId;
    var index = startIndex;
    setState(() => _isAudioPlaying = true);
    try {
      while (mounted &&
          !_finished &&
          _isAudioPlaying &&
          playbackId == _playbackId &&
          index < widget.azkarList.length) {
        final azkar = widget.azkarList[index];
        final url = azkar.audioUrl;
        if (url == null) {
          if (index == widget.azkarList.length - 1) {
            _finishSession();
            return;
          }
          index++;
          setState(() => _activeIndex = index);
          _scrollToActive();
          continue;
        }

        final path =
            _localAudioPaths[url] ?? await AzkarAudioService.localPathFor(url);
        if (path == null) {
          if (mounted && playbackId == _playbackId) {
            _cancelPlayback();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('حمّل المجموعة كاملة أولاً')),
            );
          }
          return;
        }
        _localAudioPaths[url] = path;

        if (mounted) {
          setState(() {
            _audioIndex = index;
            _isAudioPlaying = true;
          });
        }

        for (
          var repetition = 0;
          repetition < azkar.repeat &&
              mounted &&
              !_finished &&
              _isAudioPlaying &&
              playbackId == _playbackId;
          repetition++
        ) {
          await _audioSessionReady;
          await _audioSession?.setActive(true);
          await _audioPlayer.stop();
          await _audioPlayer.setFilePath(path);
          await _audioPlayer.play();
          if (!mounted || !_isAudioPlaying || playbackId != _playbackId) {
            return;
          }
          widget.onTapCounter(azkar);
        }

        if (index == widget.azkarList.length - 1) {
          _finishSession();
          return;
        }
        index++;
        setState(() => _activeIndex = index);
        _scrollToActive();
      }
    } on PlayerException {
      if (mounted && playbackId == _playbackId) {
        _cancelPlayback();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر تشغيل الصوت')));
      }
    } finally {
      if (mounted && !_finished && playbackId == _playbackId) {
        setState(() => _isAudioPlaying = false);
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (_finished) return;
    if (_isAudioPlaying) {
      _cancelPlayback();
      if (mounted) setState(() {});
      return;
    }
    unawaited(_playAudioSequenceFrom(_activeCurrentIndex));
  }

  Future<void> _downloadAudio(String url) async {
    if (_downloadingUrl != null) return;
    setState(() => _downloadingUrl = url);
    try {
      _localAudioPaths[url] = await AzkarAudioService.download(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر تحميل الصوت')));
      }
    } finally {
      if (mounted) setState(() => _downloadingUrl = null);
    }
  }

  Future<void> _downloadAllAudio() async {
    if (_downloadProgress != null) return;
    final urls = widget.azkarList
        .map((azkar) => azkar.audioUrl)
        .whereType<String>()
        .toSet()
        .toList();
    if (urls.isEmpty) return;

    setState(() => _downloadProgress = 0);
    try {
      for (var i = 0; i < urls.length; i++) {
        _localAudioPaths[urls[i]] = await AzkarAudioService.download(urls[i]);
        if (mounted) setState(() => _downloadProgress = (i + 1) / urls.length);
      }
      if (mounted) setState(() => _allAudioDownloaded = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر تحميل بعض الأصوات')));
      }
    } finally {
      if (mounted) setState(() => _downloadProgress = null);
    }
  }

  int get _activeCurrentIndex {
    return _activeIndex.clamp(
      0,
      widget.azkarList.isEmpty ? 0 : widget.azkarList.length - 1,
    );
  }

  void _handleTapActiveItem() {
    if (_finished || widget.azkarList.isEmpty) return;
    final index = _activeCurrentIndex;
    final activeAzkar = widget.azkarList[index];

    if (_isAudioPlaying) {
      _cancelPlayback();
    }

    final haptics = context.read<SettingsCubit>().state.hapticsEnabled;
    if (haptics) {
      HapticFeedback.lightImpact();
    }

    _animController.forward().then((_) {
      _animController.reverse();
    });

    widget.onTapCounter(activeAzkar);

    // If this tap will complete the repeat count (meaning repeat is now 1 before tap)
    if (activeAzkar.repeat == 1) {
      if (index == widget.azkarList.length - 1) {
        _finishSession();
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_finished) {
            setState(() => _activeIndex = index + 1);
            _scrollToActive();
            unawaited(_playAudioSequenceFrom(index + 1));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.totalAzkarCount;
    final activeIndex = _activeCurrentIndex;
    final activeAzkar = widget.azkarList.isNotEmpty
        ? widget.azkarList[activeIndex]
        : null;

    final completedCount = widget.azkarList.where((e) => e.repeat == 0).length;
    if (_finished) {
      return Center(
        child: Text(
          'تم الانتهاء من الأذكار',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Top Progress Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Row(
            children: [
              Text(
                'الذكر ${activeIndex + 1} من $total',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : (completedCount / total),
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _downloadProgress == null
                  ? IconButton(
                      tooltip: _allAudioDownloaded
                          ? 'تم تحميل كل الأصوات'
                          : 'تحميل كل الأصوات',
                      onPressed: _allAudioDownloaded ? null : _downloadAllAudio,
                      icon: Icon(
                        _allAudioDownloaded
                            ? Icons.check_circle_rounded
                            : Icons.download_rounded,
                      ),
                    )
                  : SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        value: _downloadProgress,
                        strokeWidth: 3,
                      ),
                    ),
            ],
          ),
        ),

        // All cards stay on the page; only the active card is interactive.
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                for (var index = 0; index < widget.azkarList.length; index++)
                  _buildCard(context, widget.azkarList[index], index),
              ],
            ),
          ),
        ),

        // Fixed Bottom Tasbeeh Action Panel (Thumb Accessible)
        if (activeAzkar != null)
          Material(
            elevation: 12,
            color: theme.colorScheme.surface,
            shadowColor: Colors.black38,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: InkWell(
                onTap: _handleTapActiveItem,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Label & Instructions
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.touch_app_rounded,
                                color: theme.colorScheme.secondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'اضغط للتسبيح',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'المس بأي مكان للتكرار',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Fixed Animated Thumb Counter Button
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 68,
                                height: 68,
                                child: CircularProgressIndicator(
                                  value: activeAzkar.counter == 0
                                      ? 1.0
                                      : activeAzkar.repeat /
                                            activeAzkar.counter,
                                  strokeWidth: 5,
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.secondary,
                                  ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${activeAzkar.repeat}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      'من ${activeAzkar.counter}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, AzkarEntity azkar, int index) {
    final isActive = index == _activeCurrentIndex;
    final card = _buildActiveCard(context, azkar, isActive: isActive);

    return Padding(
      key: _cardKeys[index],
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IgnorePointer(
        ignoring: !isActive,
        child: isActive
            ? card
            : ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Opacity(opacity: 0.58, child: card),
              ),
      ),
    );
  }

  Widget _buildActiveCard(
    BuildContext context,
    AzkarEntity azkar, {
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final maxHeight =
        MediaQuery.sizeOf(context).height * (isActive ? 0.62 : 0.2);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: azkar.isQuran
                  ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                  : const Color(0x220F3D34),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: azkar.isQuran
                ? theme.colorScheme.secondary.withValues(alpha: 0.5)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            width: azkar.isQuran ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: isActive ? _handleTapActiveItem : null,
          borderRadius: BorderRadius.circular(22),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (azkar.audioUrl != null)
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: FutureBuilder<String?>(
                      future: AzkarAudioService.localPathFor(azkar.audioUrl!),
                      builder: (context, snapshot) {
                        final localPath =
                            _localAudioPaths[azkar.audioUrl!] ?? snapshot.data;
                        if (localPath != null) {
                          _localAudioPaths[azkar.audioUrl!] = localPath;
                        }
                        if (_downloadingUrl == azkar.audioUrl) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return IconButton.filledTonal(
                          tooltip: localPath == null
                              ? 'تحميل الصوت على الجهاز'
                              : _isAudioPlaying &&
                                    _audioIndex == _activeCurrentIndex
                              ? 'إيقاف الصوت'
                              : 'استمع بدون إنترنت',
                          onPressed: localPath == null
                              ? () => _downloadAudio(azkar.audioUrl!)
                              : _toggleAudio,
                          icon: Icon(
                            localPath == null
                                ? Icons.download_rounded
                                : _isAudioPlaying &&
                                      _audioIndex == _activeCurrentIndex
                                ? Icons.pause_rounded
                                : Icons.volume_up_rounded,
                          ),
                        );
                      },
                    ),
                  ),
                if (azkar.isQuran) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: theme.colorScheme.secondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            azkar.surah ?? 'آية قرآنية',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(height: 10),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ZekrText(text: azkar.zekr, isQuran: azkar.isQuran),
                ),
                if (azkar.bless.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: Text(
                      azkar.bless,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
