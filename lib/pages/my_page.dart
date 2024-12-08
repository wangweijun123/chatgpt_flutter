import 'dart:convert';
import 'dart:io';

import 'package:chatgpt_flutter/dao/apk_update_dao.dart';
import 'package:chatgpt_flutter/model/apk_model.dart';
import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:chatgpt_flutter/util/hi_const.dart';
import 'package:chatgpt_flutter/util/hi_dialog.dart';
import 'package:chatgpt_flutter/util/hi_progress_dialog.dart';
import 'package:chatgpt_flutter/util/hi_utils.dart';
import 'package:chatgpt_flutter/widget/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hi_cache/flutter_hi_cache.dart';
import 'package:hi_download/hi_download.dart';
import 'package:login_sdk/dao/login_dao.dart';
import 'package:login_sdk/util/padding_extension.dart';
import 'package:open_filex/open_filex.dart';
import 'package:openai_flutter/http/ai_config.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'package:provider/provider.dart';

import '../widget/theme_widget.dart';

///我的页面
class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? avatar;
  String? userName;
  String? imoocId;
  static const titleStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  get _buildTitle => Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            15.paddingWidth,
            const Text('设置主题', style: titleStyle),
            10.paddingWidth,
            Text('请选择你喜欢的主题',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    var color = themeProvider.themeColor;
    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(
            avatar: avatar,
            name: userName,
            imoocId: imoocId,
          ),
          20.paddingHeight,
          const Divider(),
          ..._itemWidget(
              color: color,
              title: '检测更新',
              icon: Icons.update,
              onTap: _checkUpdate),
          ..._itemWidget(
              color: color,
              title: '设置代理',
              icon: Icons.network_check,
              onTap: _setProxy),
          _buildTitle,
          ThemeWidget(onThemeChange: _onThemeChange)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Map<String, dynamic>? userInfo = LoginDao.getUserInfo();
    if (userInfo != null) {
      setState(() {
        userName = userInfo['userName'];
        imoocId = userInfo['imoocId'];
        avatar = userInfo['avatar'];
      });
    }
  }

  void _onThemeChange(String value) {
    context.read<ThemeProvider>().setTheme(colorName: value);
  }

  _itemWidget(
          {required Color color,
          required String title,
          required IconData icon,
          GestureTapCallback? onTap}) =>
      [
        10.paddingHeight,
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 15, bottom: 10, right: 20),
          child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: titleStyle,
                ),
                Icon(icon, color: color)
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Divider(),
        )
      ];

  void _checkUpdate() async {
    if (!Platform.isAndroid) {
      HiDialog.showSnackBar(context, '仅支持Android，其他平台敬请期待');
      return;
    }
    try {
      var model = await ApkUpdateDao.checkUpdate();
      AILogger.log(jsonEncode(model));
      _showUpdateDialog(model);
    } catch (e) {
      AILogger.log(e.toString());
      HiDialog.showSnackBar(context, '已是最新版本');
    }
  }

  void _setProxy() async {
    //获取之前设置过的代理
    var cacheProxy = HiCache.getInstance().get(HiConst.keyHiProxy);
    var result = await HiDialog.showProxySettingDialog(context,
        proxyText: cacheProxy,
        onTap: () => HiUtils.openH5(
            'https://doc.devio.org/api-help/docs/ChatGPT-ProxySetting.html'));
    //点击取消
    if (!result[0]) {
      return;
    }
    String? proxy = result[1];
    AIConfigBuilder.instance.setProxy(proxy);
    if (proxy == null || proxy.isEmpty) {
      HiCache.getInstance().remove(HiConst.keyHiProxy);
    } else {
      HiCache.getInstance().setString(HiConst.keyHiProxy, proxy);
    }
    debugPrint('proxy:$proxy');
  }

  void _showUpdateDialog(ApkModel model) async {
    var result = await HiDialog.showDownloadDialog(context,
        title: '有新版本啦',
        content: model.description ?? "",
        confirmText: "立即更新",
        cancelText: "取消");
    AILogger.log('result:$result');
    if (!(result ?? false) || !mounted) {
      return;
    }
    var dialog = HiProgressDialog();
    dialog.show(context, cancellable: false);
    String? path;
    path = await HiDownLoad().download(
        downLoadUrl: model.url!,
        fileName: 'ChatGPT.apk',
        listener: (int total, int received, bool done) {
          AILogger.log('total$total,received:$received');
          dialog.update((received / total * 100).toInt());
          if (done) {
            dialog.close();
            installAPK(path);
          }
        });
    AILogger.log('path:$path');
  }
}

void installAPK(String? path) async {
  var result = await OpenFilex.open(path);
  AILogger.log('installAPK:${result.type} message:${result.message}');
}
