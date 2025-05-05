import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showConfirmationDialog(BuildContext context, String url) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Open Link'),
        content: const Text('Do you want to open this link in your browser?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Open'),
            onPressed: () async {
              Navigator.of(context).pop();
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ],
      );
    },
  );
}
