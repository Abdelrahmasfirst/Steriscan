import 'package:dio/dio.dart';
import '../models/models.dart';

/// Dio-based API service for SteriScan backend communication.
class ApiService {
  final Dio _dio;

  ApiService({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? 'http://localhost:3000/api',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  // ── Cycles ──────────────────────────────────────────────────────

  Future<Cycle> createCycle(Cycle cycle) async {
    final resp = await _dio.post('/cycles', data: cycle.toJson());
    return Cycle.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<Cycle>> getCycles() async {
    final resp = await _dio.get('/cycles');
    return (resp.data as List<dynamic>)
        .map((e) => Cycle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Cycle> getCycleById(String id) async {
    final resp = await _dio.get('/cycles/$id');
    return Cycle.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Kits ────────────────────────────────────────────────────────

  Future<List<Kit>> getKits() async {
    final resp = await _dio.get('/kits');
    return (resp.data as List<dynamic>)
        .map((e) => Kit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Kit> getKitById(String id) async {
    final resp = await _dio.get('/kits/$id');
    return Kit.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Scan Results ────────────────────────────────────────────────

  Future<ScanResult> submitScan(String kitId, {String? imagePath}) async {
    final resp = await _dio.post('/scans', data: {
      'kitId': kitId,
      if (imagePath != null) 'imagePath': imagePath,
    });
    return ScanResult.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<ScanResult>> getScanHistory() async {
    final resp = await _dio.get('/scans');
    return (resp.data as List<dynamic>)
        .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ScanResult> getScanById(String id) async {
    final resp = await _dio.get('/scans/$id');
    return ScanResult.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Export ──────────────────────────────────────────────────────

  Future<String> exportReportPdf(String scanId) async {
    final resp = await _dio.get('/scans/$scanId/export/pdf');
    return resp.data['url'] as String;
  }

  Future<String> exportReportCsv(String scanId) async {
    final resp = await _dio.get('/scans/$scanId/export/csv');
    return resp.data['url'] as String;
  }
}
