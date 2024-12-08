import 'package:chatgpt_flutter/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:login_sdk/dao/login_dao.dart';
import 'package:login_sdk/util/padding_extension.dart';
import 'package:provider/provider.dart';

///个人主页头部组件
class HeaderWidget extends StatelessWidget {
  final String? name;
  final String? avatar;
  final String? imoocId;

  const HeaderWidget({Key? key, this.name, this.avatar, this.imoocId})
      : super(key: key);

  get _avatar => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(avatar!, height: 60, width: 60));

  get _rightLayout => Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'imooc id：$imoocId',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          )
        ],
      ));

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    var color = themeProvider.themeColor;
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Row(
        children: [
          20.paddingWidth,
          if (avatar != null) _avatar,
          15.paddingWidth,
          _rightLayout,
          _logoutBtn(color),
          20.paddingWidth,
        ],
      ),
    );
  }

  _logoutBtn(MaterialColor color) {
    return GestureDetector(
      onTap: () => LoginDao.logOut(),
      child: Icon(
        Icons.logout,
        color: color,
      ),
    );
  }
}
