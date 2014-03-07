part of dartsnake;


class SnakeView {

  final game = querySelector('#snakegame');

  final gameover = querySelector('#gameover');
  final reasons = querySelector('#reasons');
  final points = querySelector('#points');

  HtmlElement get startButton => querySelector('#start');

  void update(SnakeGame model) {

    startButton.style.visibility = model.stopped ? "visible" : "hidden";

    points.innerHtml = "Points: ${model.miceCounter}";
    gameover.innerHtml = model.gameOver ? "Game Over" : "";
    reasons.innerHtml = "";
    if (model.gameOver) {
      final tangled = model.snake.tangled ? "Do not tangle your snake<br>" : "";
      final onfield = model.snake.notOnField ? "Keep your snake on the field<br>" : "";
      reasons.innerHtml = "$tangled$onfield";
    }

    // Updates the field
    final field = model.field;
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

  void generateField(SnakeGame model) {
    final field = model.field;
    String table = "";
    for (int row = 0; row < field.length; row++) {
      table += "<tr>";
      for (int col = 0; col < field[row].length; col++) {
        final assignment = field[row][col];
        final pos = "field_${row}_${col}";
        table += "<td id='$pos' class='$assignment'></td>";
      }
      table += "</tr>";
    }
    game.innerHtml = table;
  }
}