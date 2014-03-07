part of dartsnake;

/**
 * A [SnakeView] object interacts with the DOM tree
 * to reflect actual [SnakeGame] state to the user.
 */
class SnakeView {

  /**
   * Element with id '#snakegame' of the DOM tree.
   * Used to visualize the field of a [SnakeGame] as a HTML table.
   */
  final game = querySelector('#snakegame');

  /**
   * Element with id '#gameover' of the DOM tree.
   * Used to indicate that a game is over.
   */
  final gameover = querySelector('#gameover');

  /**
   * Element with id '#reasons' of the DOM tree.
   * Used to indicate why the game entered the game over state.
   */
  final reasons = querySelector('#reasons');

  /**
   * Element with id '#points' of the DOM tree.
   * Used to indicate how many points a user has actually collected.
   */
  final points = querySelector('#points');

  /**
   * Start button of the game.
   */
  HtmlElement get startButton => querySelector('#start');

  /**
   * Updates the view according to the [model] state.
   *
   * - [startButton] is shown according to the stopped/running state of the [model].
   * - [points] are updated according to the [model] state.
   * - [gameover] is shown when [model] indicates game over state.
   * - Game over [reasons] ([model.snake] tangled or off field) are shown when [model] is in game over state.
   * - Field is shown according to actual field state of [model].
   */
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
          switch (field[row][col]) {
            case #mouse: td.classes.add('mouse'); break;
            case #snake: td.classes.add('mouse'); break;
            case #empty: td.classes.add('empty'); break;
          }
        }
      }
    }
  }

  /**
   * Generates the field according to [model] state.
   * A HTML table (n x n) is generated and inserted
   * into the [game] element of the DOM tree.
   */
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