import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/config/Quality.dart';

final method = Method._();

class Method {
  Method._();

  MethodChannel _channel = MethodChannel("method");

  Future<dynamic> _flatInvoke(String method, dynamic params) {
    return _channel.invokeMethod("flatInvoke", {
      "method": method,
      "params": params is String ? params : jsonEncode(params),
    });
  }

  Future<String> loadTheme() async {
    return await _flatInvoke("loadProperty", {
      "name": "theme",
      "defaultValue": "pink",
    });
  }

  Future<dynamic> saveTheme(String code) async {
    return await _flatInvoke("saveProperty", {
      "name": "theme",
      "value": code,
    });
  }

  Future<String> loadProperty(String propertyName, String defaultValue) async {
    return await _flatInvoke("loadProperty", {
      "name": propertyName,
      "defaultValue": defaultValue,
    });
  }

  Future<dynamic> saveProperty(String propertyName, String value) {
    return _flatInvoke("saveProperty", {
      "name": propertyName,
      "value": value,
    });
  }

  Future<String> loadQuality() async {
    return await _flatInvoke("loadProperty", {
      "name": "quality",
      "defaultValue": ImageQualityOriginal,
    });
  }

  Future<dynamic> saveQuality(String code) async {
    return await _flatInvoke("saveProperty", {
      "name": "quality",
      "value": code,
    });
  }

  Future<String> getSwitchAddress() async {
    return await _flatInvoke("getSwitchAddress", "");
  }

  Future<dynamic> setSwitchAddress(String switchAddress) async {
    return await _flatInvoke("setSwitchAddress", switchAddress);
  }

  Future<String> getProxy() async {
    return await _flatInvoke("getProxy", "");
  }

  Future<dynamic> setProxy(String proxy) async {
    return await _flatInvoke("setProxy", proxy);
  }

  Future<String> getUsername() async {
    return await _flatInvoke("getUsername", "");
  }

  Future<dynamic> setUsername(String username) async {
    return await _flatInvoke("setUsername", username);
  }

  Future<String> getPassword() async {
    return await _flatInvoke("getPassword", "");
  }

  Future<dynamic> setPassword(String password) async {
    return await _flatInvoke("setPassword", password);
  }

  Future<bool> preLogin() async {
    String rsp = await _flatInvoke("preLogin", "");
    return rsp == "true";
  }

  Future<dynamic> login() async {
    return _flatInvoke("login", "");
  }

  Future<dynamic> register(
      String email,
      String name,
      String password,
      String gender,
      String birthday,
      String question1,
      String answer1,
      String question2,
      String answer2,
      String question3,
      String answer3) {
    return _flatInvoke("register", {
      "email": email,
      "name": name,
      "password": password,
      "gender": gender,
      "birthday": birthday,
      "question1": question1,
      "answer1": answer1,
      "question2": question2,
      "answer2": answer2,
      "question3": question3,
      "answer3": answer3,
    });
  }

  Future<dynamic> clearToken() {
    return _flatInvoke("clearToken", "");
  }

  Future<UserProfile> userProfile() async {
    String rsp = await _flatInvoke("userProfile", "");
    return UserProfile.fromJson(json.decode(rsp));
  }

  Future<dynamic> punchIn() {
    return _flatInvoke("punchIn", "");
  }

  Future<RemoteImageData> remoteImageData(
      String fileServer, String path) async {
    var data = await _flatInvoke("remoteImageData", {
      "fileServer": fileServer,
      "path": path,
    });
    return RemoteImageData.fromJson(json.decode(data));
  }

  Future<dynamic> remoteImagePreload(String fileServer, String path) async {
    return _flatInvoke("remoteImagePreload", {
      "fileServer": fileServer,
      "path": path,
    });
  }

  Future<String> downloadImagePath(String path) async {
    return await _flatInvoke("downloadImagePath", path);
  }

  Future<List<Category>> categories() async {
    String rsp = await _flatInvoke("categories", "");
    List list = json.decode(rsp);
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<ComicsPage> comics(
    String sort,
    int page, {
    String category = "",
    String tag = "",
    String creatorId = "",
    String chineseTeam = "",
  }) async {
    String rsp = await _flatInvoke("comics", {
      "category": category,
      "tag": tag,
      "creatorId": creatorId,
      "chineseTeam": chineseTeam,
      "sort": sort,
      "page": page,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<ComicsPage> searchComics(String keyword, String sort, int page) {
    return searchComicsInCategories(keyword, sort, page, []);
  }

  Future<ComicsPage> searchComicsInCategories(
      String keyword, String sort, int page, List<String> categories) async {
    String rsp = await _flatInvoke("searchComics", {
      "keyword": keyword,
      "sort": sort,
      "page": page,
      "categories": categories,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<List<ComicSimple>> randomComics() async {
    String data = await _flatInvoke("randomComics", "");
    return List.of(jsonDecode(data))
        .map((e) => Map<String, dynamic>.of(e))
        .map((e) => ComicSimple.fromJson(e))
        .toList();
  }

  Future<List<ComicSimple>> leaderboard(String type) async {
    String data = await _flatInvoke("leaderboard", type);
    return List.of(jsonDecode(data))
        .map((e) => Map<String, dynamic>.of(e))
        .map((e) => ComicSimple.fromJson(e))
        .toList();
  }

  Future<ComicInfo> comicInfo(String comicId) async {
    String rsp = await _flatInvoke("comicInfo", comicId);
    return ComicInfo.fromJson(json.decode(rsp));
  }

  Future<EpPage> comicEpPage(String comicId, int page) async {
    String rsp = await _flatInvoke("comicEpPage", {
      "comicId": comicId,
      "page": page,
    });
    return EpPage.fromJson(json.decode(rsp));
  }

  Future<PicturePage> comicPicturePageWithQuality(
      String comicId, int epOrder, int page, String quality) async {
    String data = await _flatInvoke("comicPicturePageWithQuality", {
      "comicId": comicId,
      "epOrder": epOrder,
      "page": page,
      "quality": quality,
    });
    return PicturePage.fromJson(json.decode(data));
  }

  Future<String> switchLike(String comicId) async {
    return await _flatInvoke("switchLike", comicId);
  }

  Future<String> switchFavourite(String comicId) async {
    return await _flatInvoke("switchFavourite", comicId);
  }

  Future<ComicsPage> favouriteComics(String sort, int page) async {
    var rsp = await _flatInvoke("favouriteComics", {
      "sort": sort,
      "page": page,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<List<ComicSimple>> recommendation(String comicId) async {
    String rsp = await _flatInvoke("recommendation", comicId);
    List list = json.decode(rsp);
    return list.map((e) => ComicSimple.fromJson(e)).toList();
  }

  Future<dynamic> postComment(String comicId, String content) {
    return _flatInvoke("postComment", {
      "comicId": comicId,
      "content": content,
    });
  }

  Future<dynamic> postChildComment(String commentId, String content) {
    return _flatInvoke("postChildComment", {
      "commentId": commentId,
      "content": content,
    });
  }

  Future<CommentPage> comments(String comicId, int page) async {
    var rsp = await _flatInvoke("comments", {
      "comicId": comicId,
      "page": page,
    });
    return CommentPage.fromJson(json.decode(rsp));
  }

  Future<CommentChildrenPage> commentChildren(
    String comicId,
    String commentId,
    int page,
  ) async {
    var rsp = await _flatInvoke("commentChildren", {
      "comicId": comicId,
      "commentId": commentId,
      "page": page,
    });
    return CommentChildrenPage.fromJson(json.decode(rsp));
  }

  Future<MyCommentsPage> myComments(int page) async {
    String response = await _flatInvoke("myComments", "$page");
    print("RESPONSE");
    print(response);
    return MyCommentsPage.fromJson(jsonDecode(response));
  }

  Future<List<ViewLog>> viewLogPage(int offset, int limit) async {
    var data = await _flatInvoke("viewLogPage", {
      "offset": offset,
      "limit": limit,
    });
    List list = json.decode(data);
    return list.map((e) => ViewLog.fromJson(e)).toList();
  }

  Future<dynamic> clearAllViewLog() {
    return _flatInvoke("clearAllViewLog", "");
  }

  Future<dynamic> deleteViewLog(String id) {
    return _flatInvoke("deleteViewLog", id);
  }

  Future<GamePage> games(int page) async {
    var data = await _flatInvoke("games", "$page");
    return GamePage.fromJson(json.decode(data));
  }

  Future<GameInfo> game(String gameId) async {
    var data = await _flatInvoke("game", gameId);
    return GameInfo.fromJson(json.decode(data));
  }

  Future clean() {
    return _flatInvoke("clean", "");
  }

  Future autoClean(String expireSec) {
    return _flatInvoke("autoClean", expireSec);
  }

  Future storeViewEp(
      String comicId, int epOrder, String epTitle, int pictureRank) {
    return _flatInvoke("storeViewEp", {
      "comicId": comicId,
      "epOrder": epOrder,
      "epTitle": epTitle,
      "pictureRank": pictureRank,
    });
  }

  Future<ViewLog?> loadView(String comicId) async {
    String data = await _flatInvoke("loadView", comicId);
    if (data == "") {
      return null;
    }
    return ViewLog.fromJson(jsonDecode(data));
  }

  Future<bool> downloadRunning() async {
    String rsp = await _flatInvoke("downloadRunning", "");
    return rsp == "true";
  }

  Future<dynamic> setDownloadRunning(bool status) async {
    return _flatInvoke("setDownloadRunning", "$status");
  }

  Future<dynamic> createDownload(
      Map<String, dynamic> comic, List<Map<String, dynamic>> epList) async {
    return _flatInvoke("createDownload", {
      "comic": comic,
      "epList": epList,
    });
  }

  Future<dynamic> addDownload(
      Map<String, dynamic> comic, List<Map<String, dynamic>> epList) async {
    await _flatInvoke("addDownload", {
      "comic": comic,
      "epList": epList,
    });
  }

  Future<DownloadComic?> loadDownloadComic(String comicId) async {
    var data = await _flatInvoke("loadDownloadComic", comicId);
    // 未找到 且 未异常
    if (data == "") {
      return null;
    }
    return DownloadComic.fromJson(json.decode(data));
  }

  Future<List<DownloadComic>> allDownloads() async {
    var data = await _flatInvoke("allDownloads", "");
    data = jsonDecode(data);
    if (data == null) {
      return [];
    }
    List list = data;
    return list.map((e) => DownloadComic.fromJson(e)).toList();
  }

  Future<dynamic> deleteDownloadComic(String comicId) async {
    return _flatInvoke("deleteDownloadComic", comicId);
  }

  Future<List<DownloadEp>> downloadEpList(String comicId) async {
    var data = await _flatInvoke("downloadEpList", comicId);
    List list = json.decode(data);
    return list.map((e) => DownloadEp.fromJson(e)).toList();
  }

  Future<List<DownloadPicture>> downloadPicturesByEpId(String epId) async {
    var data = await _flatInvoke("downloadPicturesByEpId", epId);
    List list = json.decode(data);
    return list.map((e) => DownloadPicture.fromJson(e)).toList();
  }

  Future<dynamic> resetFailed() async {
    return _flatInvoke("resetAllDownloads", "");
  }

  Future<dynamic> exportComicDownload(String comicId, String dir) {
    return _flatInvoke("exportComicDownload", {
      "comicId": comicId,
      "dir": dir,
    });
  }

  Future<dynamic> exportComicDownloadToJPG(String comicId, String dir) {
    return _flatInvoke("exportComicDownloadToJPG", {
      "comicId": comicId,
      "dir": dir,
    });
  }

  Future<int> exportComicUsingSocket(String comicId) async {
    return int.parse(await _flatInvoke("exportComicUsingSocket", comicId));
  }

  Future<dynamic> exportComicUsingSocketExit() {
    return _flatInvoke("exportComicUsingSocketExit", "");
  }

  Future<dynamic> importComicDownload(String zipPath) {
    return _flatInvoke("importComicDownload", zipPath);
  }

  Future<dynamic> importComicDownloadUsingSocket(String addr) {
    return _flatInvoke("importComicDownloadUsingSocket", addr);
  }

  Future<String> clientIpSet() async {
    return await _flatInvoke("clientIpSet", "");
  }

  Future<List<String>> downloadGame(String url) async {
    if (url.startsWith("https://game.eroge.xyz/hhh.php")) {
      var data = await _flatInvoke("downloadGame", url);
      return List.of(jsonDecode(data)).map((e) => e.toString()).toList();
    }
    return [url];
  }

  Future<dynamic> iosSaveFileToImage(String path) async {
    return _channel.invokeMethod("iosSaveFileToImage", {
      "path": path,
    });
  }

  Future androidSaveFileToImage(String path) async {
    return _channel.invokeMethod("androidSaveFileToImage", {
      "path": path,
    });
  }

  Future convertImageToJPEG100(String path, String dir) async {
    return _flatInvoke("convertImageToJPEG100", {
      "path": path,
      "dir": dir,
    });
  }

  Future<bool> getAutoFullScreen() async {
    var value = await _flatInvoke("loadProperty", {
      "name": "autoFullScreen",
      "defaultValue": "false",
    });
    return value == "true";
  }

  Future<dynamic> setAutoFullScreen(bool value) async {
    return await _flatInvoke("saveProperty", {
      "name": "autoFullScreen",
      "value": "$value",
    });
  }

  Future<List<String>> getShadowCategories() async {
    var value = await _flatInvoke("loadProperty", {
      "name": "shadowCategories",
      "defaultValue": jsonEncode(<String>[]),
    });
    return List.of(jsonDecode(value)).map((e) => "$e").toList();
  }

  Future<dynamic> setShadowCategories(List<String> value) {
    return _flatInvoke("saveProperty", {
      "name": "shadowCategories",
      "value": jsonEncode(value),
    });
  }

  Future<List<String>> loadAndroidModes() async {
    return List.of(await _channel.invokeMethod("androidGetModes"))
        .map((e) => "$e")
        .toList();
  }

  Future setAndroidMode(String androidDisplayMode) {
    return _channel
        .invokeMethod("androidSetMode", {"mode": androidDisplayMode});
  }

  Future androidGetUiMode() {
    return _channel.invokeMethod("androidGetUiMode", {});
  }

  Future<int> androidGetVersion() async {
    return await _channel.invokeMethod("androidGetVersion", {});
  }
}
