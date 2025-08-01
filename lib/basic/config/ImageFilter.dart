import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "imageFilter";
late ImageFilter imageFilter;

Widget processImageFilter(Widget child) => imageFilter.process(child);

Future<void> initImageFilter() async {
  imageFilter = _imageFilterFromString(await method.loadProperty(
    _propertyName,
    _filters[0].name,
  ));
}

ImageFilter _imageFilterFromString(String string) {
  for (var value in _filters) {
    if (string == value.name) {
      return value;
    }
  }
  return _filters[0];
}

class ImageFilter {
  final String name;
  final Widget Function(Widget widget) process;

  ImageFilter(this.name, this.process);
}

final List<ImageFilter> _filters = [
  ImageFilter(
    tr("settings.image_filter.normal"),
    (child) {
      return child;
    },
  ),
  ImageFilter(
    tr("settings.image_filter.gray"),
        (child) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color),
        child: child,
      );
    },
  ),
  ImageFilter(
    tr("settings.image_filter.brown"),
        (child) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[ 0.393, 0.769, 0.189, 0, 0, 0.349, 0.686, 0.168, 0, 0, 0.272, 0.534, 0.131, 0, 0, 0, 0, 0, 1, 0, ]),
        child: child,
      );
    },
  ),
  ImageFilter(
    "srgbToLinearGamma",
        (child) {
      return ColorFiltered(
        colorFilter: const ColorFilter.srgbToLinearGamma(),
        child: child,
      );
    },
  ),
  ImageFilter(
    "linearToSrgbGamma",
        (child) {
      return ColorFiltered(
        colorFilter: const ColorFilter.linearToSrgbGamma(),
        child: child,
      );
    },
  ),
];

Future<void> chooseImageFilter(BuildContext context) async {
  Map<String, ImageFilter> map = {};
  for (var element in _filters) {
    map[element.name] = element;
  }
  ImageFilter? result = await chooseMapDialog<ImageFilter>(
    context,
    map,
    tr("settings.image_filter.choose"),
  );
  if (result != null) {
    await method.saveProperty(_propertyName, result.name);
    imageFilter = result;
  }
}

Widget imageFilterSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.image_filter.title")),
        subtitle: Text(imageFilter.name),
        onTap: () async {
          await chooseImageFilter(context);
          setState(() {});
        },
      );
    },
  );
}
