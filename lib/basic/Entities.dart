class PicaImage {
  late String originalName;
  late String path;
  late String fileServer;

  PicaImage.fromJson(Map<String, dynamic> json) {
    this.originalName = json["originalName"];
    this.path = json["path"];
    this.fileServer = json["fileServer"];
  }
}

class BasicUser {
  late String id;
  late String gender;
  late String name;
  late String title;
  late bool verified;
  late int exp;
  late int level;
  late List<String> characters;
  late PicaImage avatar;

  BasicUser.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.gender = json["gender"];
    this.name = json["name"];
    this.title = json["title"];
    this.verified = json["verified"];
    this.exp = json["exp"];
    this.level = json["level"];
    this.characters = List.of(json["characters"]).map((e) => "$e").toList();
    this.avatar = PicaImage.fromJson(Map<String, dynamic>.of(json["avatar"]));
  }
}

class UserProfile extends BasicUser {
  late String birthday;
  late String email;
  late String createdAt;
  late bool isPunched;

  UserProfile.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.birthday = json["birthday"];
    this.email = json["email"];
    this.createdAt = json["created_at"];
    this.isPunched = json["isPunched"];
  }
}

class Page {
  late int total;
  late int limit;
  late int page;
  late int pages;

  Page.fromJson(Map<String, dynamic> json) {
    this.total = json["total"];
    this.limit = json["limit"];
    this.page = json["page"];
    this.pages = json["pages"];
  }
}

class Category {
  late String id;
  late String title;
  late String description;
  late PicaImage thumb;
  late bool isWeb;
  late bool active;
  late String link;

  Category.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
    this.description = json["description"];
    this.thumb = PicaImage.fromJson(json["thumb"]);
    this.isWeb = json["isWeb"];
    this.active = json["active"];
    this.link = json["link"];
  }
}

class ComicsPage extends Page {
  late List<ComicSimple> docs;

  ComicsPage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.from(json["docs"])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => ComicSimple.fromJson(e))
        .toList();
  }
}

class ComicSimple {
  late String id;
  late String title;
  late String author;
  late int pagesCount;
  late int epsCount;
  late bool finished;
  late List<String> categories;
  late PicaImage thumb;
  late int likesCount;

  ComicSimple.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
    this.author = json["author"];
    this.pagesCount = json["pagesCount"];
    this.epsCount = json["epsCount"];
    this.finished = json["finished"];
    this.categories = List<String>.from(json["categories"]);
    this.thumb = PicaImage.fromJson(json["thumb"]);
    this.likesCount = json["likesCount"];
  }
}

class ComicInfo extends ComicSimple {
  late String description;
  late String chineseTeam;
  late List<String> tags;
  late String updatedAt;
  late String createdAt;
  late bool allowDownload;
  late int viewsCount;
  late bool isFavourite;
  late bool isLiked;
  late int commentsCount;
  late Creator creator;

  ComicInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.description = json["description"];
    this.chineseTeam = json["chineseTeam"];
    this.tags = List<String>.from(json["tags"]);
    this.updatedAt = (json["updated_at"]);
    this.createdAt = (json["created_at"]);
    this.allowDownload = json["allowDownload"];
    this.viewsCount = json["viewsCount"];
    this.isFavourite = json["isFavourite"];
    this.isLiked = json["isLiked"];
    this.commentsCount = json["commentsCount"];
    this.creator = Creator.fromJson(Map<String, dynamic>.of(json["_creator"]));
  }
}

class Creator extends BasicUser {
  late String slogan;
  late String role;
  late String character;

  Creator.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.slogan = json["slogan"];
    this.role = json["role"];
    this.character = json["character"];
  }
}

class Ep {
  late String id;
  late String title;
  late int order;
  late String updatedAt;

  Ep.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
    this.order = json["order"];
    this.updatedAt = (json["updated_at"]);
  }
}

class EpPage extends Page {
  late List<Ep> docs;

  EpPage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.from(json["docs"])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => Ep.fromJson(e))
        .toList();
  }
}

class PicturePage extends Page {
  late List<Picture> docs;

  PicturePage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.from(json["docs"])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => Picture.fromJson(e))
        .toList();
  }
}

class Picture {
  late String id;
  late PicaImage media;

  Picture.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.media = PicaImage.fromJson(json["media"]);
  }
}

class RemoteImageData {
  late int fileSize;
  late String format;
  late int width;
  late int height;
  late String finalPath;

  RemoteImageData.forData(
    this.fileSize,
    this.format,
    this.width,
    this.height,
    this.finalPath,
  );

  RemoteImageData.fromJson(Map<String, dynamic> json) {
    this.fileSize = json["fileSize"];
    this.format = json["format"];
    this.width = json["width"];
    this.height = json["height"];
    this.finalPath = json["finalPath"];
  }
}

class CommentPage extends Page {
  late List<Comment> docs;

  CommentPage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.from(json["docs"])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => Comment.fromJson(e))
        .toList();
  }
}

class Comment {
  late String id;
  late String content;
  late CommentUser user;
  late String comic;
  late bool isTop;
  late bool hide;
  late String createdAt;
  late int likesCount;
  late int commentsCount;
  late bool isLiked;

  Comment.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.content = json["content"];
    this.user = CommentUser.fromJson(Map<String, dynamic>.of(json["_user"]));
    this.comic = json["_comic"];
    this.isTop = json["isTop"];
    this.hide = json["hide"];
    this.createdAt = json["created_at"];
    this.likesCount = json["likesCount"];
    this.commentsCount = json["commentsCount"];
    this.isLiked = json["isLiked"];
  }
}

class CommentUser extends BasicUser {
  late String role;

  CommentUser.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.role = json["role"];
  }
}

class DownloadPicture {
  late int rankInEp;
  late String fileServer;
  late String path;
  late String localPath;
  late int width;
  late int height;
  late String format;
  late int fileSize;

  DownloadPicture.fromJson(Map<String, dynamic> json) {
    this.rankInEp = json["rankInEp"];
    this.fileServer = json["fileServer"];
    this.path = json["path"];
    this.localPath = json["localPath"];
    this.width = json["width"];
    this.height = json["height"];
    this.format = json["format"];
    this.fileSize = json["fileSize"];
  }
}

class ViewLog {
  late String id;
  late String title;
  late String author;
  late int pagesCount;
  late int epsCount;
  late bool finished;
  late String categories;
  late String thumbOriginalName;
  late String thumbFileServer;
  late String thumbPath;
  late String description;
  late String chineseTeam;
  late String tags;
  late String lastViewTime;
  late int lastViewEpOrder;
  late String lastViewEpTitle;
  late int lastViewPictureRank;

  ViewLog.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.title = json["title"];
    this.author = json["author"];
    this.pagesCount = json["pagesCount"];
    this.epsCount = json["epsCount"];
    this.finished = json["finished"];
    this.categories = json["categories"];
    this.thumbOriginalName = json["thumbOriginalName"];
    this.thumbFileServer = json["thumbFileServer"];
    this.thumbPath = json["thumbPath"];
    this.description = json["description"];
    this.chineseTeam = json["chineseTeam"];
    this.tags = json["tags"];
    this.lastViewTime = json["lastViewTime"];
    this.lastViewEpOrder = json["lastViewEpOrder"];
    this.lastViewEpTitle = json["lastViewEpTitle"];
    this.lastViewPictureRank = json["lastViewPictureRank"];
  }
}

class DownloadComic {
  late String id;
  late String createdAt;
  late String updatedAt;
  late String title;
  late String author;
  late int pagesCount;
  late int epsCount;
  late bool finished;

  late String categories;
  late String thumbOriginalName;
  late String thumbFileServer;
  late String thumbPath;
  late String thumbLocalPath;

  late String description;
  late String chineseTeam;
  late String tags;
  late int selectedEpCount;
  late int selectedPictureCount;
  late int downloadEpCount;
  late int downloadPictureCount;
  late bool downloadFinished;
  late String downloadFinishedTime;
  late bool downloadFailed;
  late bool deleting;

  void copy(DownloadComic other) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.updatedAt = other.updatedAt;
    this.title = other.title;
    this.author = other.author;
    this.pagesCount = other.pagesCount;
    this.epsCount = other.epsCount;
    this.finished = other.finished;
    this.categories = other.categories;
    this.thumbOriginalName = other.thumbOriginalName;
    this.thumbFileServer = other.thumbFileServer;
    this.thumbPath = other.thumbPath;
    this.description = other.description;
    this.chineseTeam = other.chineseTeam;
    this.tags = other.tags;
    this.selectedEpCount = other.selectedEpCount;
    this.selectedPictureCount = other.selectedPictureCount;
    this.downloadEpCount = other.downloadEpCount;
    this.downloadPictureCount = other.downloadPictureCount;
    this.downloadFinished = other.downloadFinished;
    this.downloadFinishedTime = other.downloadFinishedTime;
    this.downloadFailed = other.downloadFailed;
    this.thumbLocalPath = other.thumbLocalPath;
    // this.deleting = other.deleting;
  }

  DownloadComic.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.createdAt = (json["createdAt"]);
    this.updatedAt = (json["updatedAt"]);
    this.title = json["title"];
    this.author = json["author"];
    this.pagesCount = json["pagesCount"];
    this.epsCount = json["epsCount"];
    this.finished = json["finished"];
    this.categories = json["categories"];
    this.thumbOriginalName = json["thumbOriginalName"];
    this.thumbFileServer = json["thumbFileServer"];
    this.thumbPath = json["thumbPath"];
    this.description = json["description"];
    this.chineseTeam = json["chineseTeam"];
    this.tags = json["tags"];
    this.selectedEpCount = json["selectedEpCount"];
    this.selectedPictureCount = json["selectedPictureCount"];
    this.downloadEpCount = json["downloadEpCount"];
    this.downloadPictureCount = json["downloadPictureCount"];
    this.downloadFinished = json["downloadFinished"];
    this.downloadFinishedTime = json["downloadFinishedTime"];
    this.downloadFailed = json["downloadFailed"];
    this.deleting = json["deleting"];
    this.thumbLocalPath = json["thumbLocalPath"];
  }
}

class DownloadEp {
  late String comicId;
  late String id;
  late String updatedAt;

  late int epOrder;
  late String title;

  late bool fetchedPictures;
  late int selectedPictureCount;
  late int downloadPictureCount;
  late bool downloadFinish;
  late String downloadFinishTime;
  late bool downloadFailed;

  DownloadEp.fromJson(Map<String, dynamic> json) {
    this.comicId = json["comicId"];
    this.id = json["id"];
    this.epOrder = json["epOrder"];
    this.title = json["title"];

    this.fetchedPictures = json["fetchedPictures"];
    this.selectedPictureCount = json["selectedPictureCount"];
    this.downloadPictureCount = json["downloadPictureCount"];
    this.downloadFinish = json["downloadFinish"];
    this.downloadFinishTime = json["downloadFinishTime"];
    this.downloadFailed = json["downloadFailed"];
  }
}

class GamePage extends Page {
  late List<GameSimple> docs;

  GamePage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.of(json["docs"])
        .map((e) => Map<String, dynamic>.of(e))
        .map((e) => GameSimple.fromJson(e))
        .toList();
  }
}

class GameSimple {
  late String id;
  late String title;
  late String version;
  late PicaImage icon;
  late String publisher;
  late bool adult;
  late bool suggest;
  late int likesCount;
  late bool android;
  late bool ios;

  GameSimple.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
    this.version = json["version"];
    this.icon = PicaImage.fromJson(json["icon"]);
    this.publisher = json["publisher"];
    this.adult = json["adult"];
    this.suggest = json["suggest"];
    this.likesCount = json["likesCount"];
    this.android = json["android"];
    this.ios = json["ios"];
  }
}

class GameInfo extends GameSimple {
  late String description;
  late String updateContent;
  late String videoLink;
  late List<PicaImage> screenshots;
  late int commentsCount;
  late int downloadsCount;
  late bool isLiked;
  late List<String> androidLinks;
  late double androidSize;
  late List<String> iosLinks;
  late double iosSize;
  late String updatedAt;
  late String createdAt;

  GameInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.description = json["description"];
    this.updateContent = json["updateContent"];
    this.videoLink = json["videoLink"];
    this.screenshots = List.of(json["screenshots"])
        .map((e) => Map<String, dynamic>.of(e))
        .map((e) => PicaImage.fromJson(e))
        .toList();
    this.commentsCount = json["commentsCount"];
    this.downloadsCount = json["downloadsCount"];
    this.isLiked = json["isLiked"];
    this.androidLinks = List.of(json["androidLinks"]).map((e) => "$e").toList();
    this.androidSize = double.parse(json["androidSize"].toString());
    this.iosLinks = List.of(json["iosLinks"]).map((e) => "$e").toList();
    this.iosSize = double.parse(json["iosSize"].toString());
    this.updatedAt = json["updated_at"];
    this.createdAt = json["created_at"];
  }
}

class MyCommentsPage extends Page {
  late List<MyComment> docs;

  MyCommentsPage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs =
        List.of(json["docs"]).map((e) => MyComment.fromJson(e)).toList();
  }
}

class MyComment {
  late String id;
  late String content;
  late bool hide;
  late String createdAt;
  late int likesCount;
  late int commentsCount;
  late bool isLiked;
  late MyCommentComic comic;

  MyComment.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.content = json["content"];
    this.hide = json["hide"];
    this.createdAt = json["created_at"];
    this.likesCount = json["likesCount"];
    this.commentsCount = json["commentsCount"];
    this.isLiked = json["isLiked"];
    this.comic = MyCommentComic.fromJson(json["_comic"]);
  }
}

class MyCommentComic {
  late String id;
  late String title;

  MyCommentComic.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
  }
}

class CommentChildrenPage extends Page {
  late List<CommentChild> docs;

  CommentChildrenPage.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    this.docs = [];
    if (json["docs"] != null) {
      docs.addAll(
          List.of(json["docs"]).map((e) => CommentChild.fromJson(e)).toList());
    }
  }
}

class CommentChild extends Comment {
  late String parent;

  CommentChild.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.parent = json["_parent"];
  }
}
