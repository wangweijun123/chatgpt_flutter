import 'package:openai_flutter/http/ai_exception.dart';

///openai_flutter SDK配置工具类
class AIConfigBuilder {
  ///开发者API key，从https://platform.openai.com/account/api-keys 上获取
  String? _apiKey;

  ///注意：1、使用电脑的IP地址，不要用127.0.0.1（在Android上会被识别成Android设备的本地机）
  ///2、如果使用clashx需要开启Allow connect from Lan，否则会：Connection refused
  ///eg:192.168.1.150:7890
  String? _proxy;

  /// 开发者后台设置的组织ID，可不传
  String? _organization;

  ///用于会话的接口地址，从 https://platform.openai.com/docs/api-reference/chat  上获取
  late String _chatUrl;
  static final AIConfigBuilder _instance = AIConfigBuilder._();

  static void init(String apiKey,
      {String? organization,
      String? proxy,
      String chatUrl = 'https://api.openai.com/v1/chat/completions'}) {
    _instance._apiKey = apiKey;
    _instance._organization = organization;
    _instance._proxy = proxy;
    _instance._chatUrl = chatUrl;
  }

  static AIConfigBuilder get instance {
    if (_instance._apiKey == null) {
      throw AIException('Please call AIHeadersBuilder.init() first');
    }
    return _instance;
  }

  /// 这用于为所有请求构建头部，它将返回一个 [Map<String, String>]。
  /// 如果设置了组织ID，它也将被添加到头部中。
  /// 如果 API 密钥未设置，它将抛出一个 [AssertionError]。
  Map<String, String> headers() {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json'
    };
    assert(_apiKey != null, "需要设置API key才能发送请求");
    if (_organization != null) {
      headers['OpenAI-Organization'] = _organization!;
    }
    if (_apiKey?.startsWith('Bearer ') ?? false) {
      headers['Authorization'] = _apiKey!;
    } else {
      headers['Authorization'] = "Bearer $_apiKey";
    }
    return headers;
  }

  String get chatUrl => _chatUrl;

  String? get proxy => _proxy;

  ///set proxy
  void setProxy(String? proxy) {
    _proxy = proxy;
  }

  AIConfigBuilder._();
}
