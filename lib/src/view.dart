part of dartsnake;


class SnakeView {
  final title = querySelector('#title');
  final game = querySelector('#snakegame');

  HtmlElement get startButton => querySelector('#start');

  void update(List<List<String>> field) {
    for (int row = 0; row < field.length; row++) {
      for (int col = 0; col < field[row].length; col++) {
        final td = game.querySelector("#field_${row}_${col}");
        if (td != null) {
          td.classes.clear();
          td.classes.add(field[row][col]);
        }
      }
    }
  }

}