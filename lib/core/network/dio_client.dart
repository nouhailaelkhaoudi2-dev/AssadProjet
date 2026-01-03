import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

/// Client HTTP configuré avec Dio
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: ApiConstants.defaultHeaders,
      ),
    );

    // Ajout des intercepteurs
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _RetryInterceptor(_dio),
    ]);
  }

  Dio get dio => _dio;

  /// Configuration pour l'API Football
  Dio get footballApi {
    final footballDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.footballBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          ...ApiConstants.defaultHeaders,
          ApiConstants.footballApiKeyHeader: ApiKeys.footballApiKey,
        },
      ),
    );
    footballDio.interceptors.addAll([
      _LoggingInterceptor(),
      _RetryInterceptor(footballDio),
    ]);
    return footballDio;
  }

  /// Configuration pour NewsAPI
  Dio get newsApi {
    final newsDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.newsBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          ...ApiConstants.defaultHeaders,
          ApiConstants.newsApiKeyHeader: ApiKeys.newsApiKey,
        },
      ),
    );
    newsDio.interceptors.addAll([
      _LoggingInterceptor(),
      _RetryInterceptor(newsDio),
    ]);
    return newsDio;
  }
}

/// Intercepteur de logging pour le debug
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────');
    print('│ REQUEST: ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Data: ${options.data}');
    }
    print('└─────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Data: ${response.data.toString().substring(0, response.data.toString().length.clamp(0, 500))}...');
    print('└─────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────');
    print('│ ERROR: ${err.type} ${err.message}');
    print('│ URL: ${err.requestOptions.uri}');
    print('└─────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// Intercepteur de retry automatique
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int _maxRetries;

  _RetryInterceptor(this._dio, {int maxRetries = 3}) : _maxRetries = maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    // Ne pas retry pour certaines erreurs
    if (err.response?.statusCode == 401 ||
        err.response?.statusCode == 403 ||
        err.response?.statusCode == 404) {
      return handler.next(err);
    }

    // Retry si erreur de connexion et pas encore max retries
    if (_shouldRetry(err) && retryCount < _maxRetries) {
      await Future.delayed(Duration(seconds: retryCount + 1));

      try {
        final options = err.requestOptions;
        options.extra['retryCount'] = retryCount + 1;

        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}

/// Extensions pour simplifier les appels API
extension DioExtensions on Dio {
  /// GET avec gestion d'erreur simplifiée
  Future<Response<T>> safeGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST avec gestion d'erreur simplifiée
  Future<Response<T>> safePost<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Connexion trop lente. Veuillez réessayer.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Non autorisé. Vérifiez votre authentification.');
        } else if (statusCode == 403) {
          return Exception('Accès refusé.');
        } else if (statusCode == 404) {
          return Exception('Ressource non trouvée.');
        } else if (statusCode == 429) {
          return Exception('Trop de requêtes. Veuillez patienter.');
        } else if (statusCode != null && statusCode >= 500) {
          return Exception('Erreur serveur. Veuillez réessayer plus tard.');
        }
        return Exception('Erreur: ${e.message}');
      case DioExceptionType.cancel:
        return Exception('Requête annulée.');
      case DioExceptionType.connectionError:
        return Exception('Pas de connexion internet.');
      default:
        return Exception('Une erreur est survenue: ${e.message}');
    }
  }
}
