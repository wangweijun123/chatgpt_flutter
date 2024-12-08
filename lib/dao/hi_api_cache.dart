import 'package:flutter_hi_cache/flutter_hi_cache.dart';
import 'package:openai_flutter/utils/ai_logger.dart';

///接口缓存
class HiAPICache {
  late HiCache _hiCache;

  HiAPICache._();

  static HiAPICache? _instance;

  get _timeNow => DateTime.now().millisecondsSinceEpoch;

  static HiAPICache getInstance() {
    _instance ??= HiAPICache._();
    return _instance!;
  }

  static init(HiCache hiCache) {
    getInstance()._hiCache = hiCache;
  }

  /// 获取缓存
  /// [url] 请求URL
  /// [expire] 缓存过期时间，单位毫秒
  String? getCache(String url, {int? expire}) {
    var key = _fixedKey(url);
    var list = _hiCache.get(key);
    if (list == null) return null;
    var cacheTime = list[0];
    if (expire == null || _timeNow - int.parse(cacheTime) <= expire) {
      AILogger.log('key:$key has cache.');
      return list[1];
    } else {
      ///移除过期的缓存
      _hiCache.remove(key);
      AILogger.log('remove key$key .');
      return null;
    }
  }

  ///设置缓存
  void setCache(String url, String cache) {
    _hiCache.setStringList(_fixedKey(url), ['$_timeNow', cache]);
  }

  ///统一缓存前缀
  String _fixedKey(String url) {
    return 'urlCache_$url';
  }
}
