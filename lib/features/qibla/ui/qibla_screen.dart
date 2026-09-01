import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/features/qibla/domain/qibla_bearing.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:provider/provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _sensorTimeout;
  double? _qiblaAngle;
  double? _lastHeading;
  bool _sensorAvailable = true;
  bool _needsCalibration = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    final lat = settings.lat;
    final lon = settings.lon;
    if (lat == null || lon == null) {
      return;
    }

    _qiblaAngle = qiblaBearing(lat, lon);
    final compassEvents = FlutterCompass.events;
    if (compassEvents == null) {
      _sensorAvailable = false;
      return;
    }

    _compassSubscription = compassEvents.listen(
      _handleCompassEvent,
      onError: (_) => _showStaticBearing(),
    );
    _sensorTimeout = Timer(const Duration(seconds: 3), () {
      if (_lastHeading == null) {
        _showStaticBearing();
      }
    });
  }

  void _handleCompassEvent(CompassEvent event) {
    final heading = event.heading;
    if (heading == null || !mounted) {
      return;
    }

    _sensorTimeout?.cancel();
    setState(() {
      _lastHeading = heading;
      _sensorAvailable = true;
      final accuracy = event.accuracy;
      _needsCalibration = accuracy != null && accuracy >= 45;
    });
  }

  void _showStaticBearing() {
    if (!mounted) {
      return;
    }
    setState(() {
      _sensorAvailable = false;
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _sensorTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qiblaAngle = _qiblaAngle;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qiblaTitle)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: qiblaAngle == null
                ? Text(l10n.locationUnknownLabel, textAlign: TextAlign.center)
                : _buildCompassContent(l10n, qiblaAngle),
          ),
        ),
      ),
    );
  }

  Widget _buildCompassContent(AppLocalizations l10n, double qiblaAngle) {
    if (!_sensorAvailable) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.qiblaBearingLabel(qiblaAngle.round()),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(l10n.qiblaNoSensorMessage, textAlign: TextAlign.center),
        ],
      );
    }

    final heading = _lastHeading;
    if (heading == null) {
      return const CircularProgressIndicator();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: l10n.qiblaBearingLabel(qiblaAngle.round()),
          child: Transform.rotate(
            angle: (qiblaAngle - heading) * pi / 180,
            child: const Icon(Icons.navigation, size: 80),
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.qiblaBearingLabel(qiblaAngle.round())),
        if (_needsCalibration) ...[
          const SizedBox(height: 12),
          Text(l10n.qiblaCalibrateHint, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
