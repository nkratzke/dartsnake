import 'package:start/start.dart';

/**
 * Micro Web Server to host the Snake Game as a single page app.
 */
main() {
  start(host: '0.0.0.0', port: 3000).then((Server app) {
    app.static('../build/web');
  });
}