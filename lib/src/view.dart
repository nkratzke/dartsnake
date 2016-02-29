part of dartsnake;

/**
 * A [SnakeView] object interacts with the DOM tree
 * to reflect actual [SnakeGame] state to the user.
 */
class SnakeView {

  /**
   * Element with id '#warningoverlay' of the DOM tree.
   * Used to display general warnings
   * (e.g. connection to gamekey service could not be established).
   */
  final warningoverlay = querySelector("#warningoverlay");

  /**
   * Element with id '#overlay' of the DOM tree.
   * Used to display overlay forms.
   */
  final overlay = querySelector("#overlay");

  /**
   * Element with id '#title' of the DOM tree.
   * Shown only if game is not running.
   */
  final title = querySelector("#title");

  /**
   * Element with id '#welcome' of the DOM tree.
   * Shown only if game is not running.
   */
  final welcome = querySelector("#welcome");

  /*
   * Element with id '#highscore' of the DOM tree.
   * Shown only if game is not running.
   */
  final highscore = querySelector("#highscore");

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
   * Contains all TD Elements of the field.
   */
  List<List<HtmlElement>> fields;

  /**
   * Updates the view according to the [model] state.
   *
   * - [startButton] is shown according to the stopped/running state of the [model].
   * - [points] are updated according to the [model] state.
   * - [gameover] is shown when [model] indicates game over state.
   * - Game over [reasons] ([model.snake] tangled or off field) are shown when [model] is in game over state.
   * - Field is shown according to actual field state of [model].
   * - Highscore is presented according to [scores], per default no highscore is shown.
   */
  void update(SnakeGame model, { List<Map> scores: const [] }) {

    welcome.style.display = model.stopped ? "block" : "none";
    // title.style.display = model.stopped? "block" : "none";

    highscore.innerHtml = model.stopped ? generateHighscore(scores) : "";

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
        final td = fields[row][col];
        if (td != null) {
          td.classes.clear();
          if (field[row][col] == #mouse) td.classes.add('mouse');
          else if (field[row][col] == #snake) td.classes.add('snake');
          else if (field[row][col] == #empty) td.classes.add('empty');
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

    // Saves all generated TD elements in field to
    // avoid time intensive querySelector calls in update().
    // Thanks to Johannes Gosch, SoSe 2015.
    fields = new List<List<HtmlElement>>(field.length);
    for (int row = 0; row < field.length; row++) {
      fields[row] = [];
      for (int col = 0; col < field[row].length; col++) {
        fields[row].add(game.querySelector("#field_${row}_${col}"));
      }
    }
  }

  /**
   * Generates HTML snippet to present the highscore.
   */
  String generateHighscore(List<Map> scores, { int score: 0 }) {
    final list = scores.map((entry) => "<li>${entry['name']}: ${entry['score']}</li>").join("");
    final points = "You got $score points";
    return "<div id='scorelist'>${ score == 0 ? "" : points }${ list.isEmpty? "" : "<ul>$list</ul>"}</div>";
  }

  /**
   * Shows the highscore form and save option for the user.
   */
  void showHighscore(SnakeGame model, List<Map> scores) {

    if (overlay.innerHtml != "") return;

    final score = model.miceCounter;

    overlay.innerHtml =
      "<div id='highscore'>"
      "   <h1>Highscore</h1>"
      "</div>"
      "<div id='highscorewarning'></div>";

    if (scores.isEmpty || score > scores.last['score'] || scores.length < 10) {
      overlay.appendHtml(
          this.generateHighscore(scores, score: score) +
          "<form id='highscoreform'>"
          "<input type='text' id='user' placeholder='user'>"
          "<input type='password' id='pwd' placeholder='password'>"
          "<button type='button' id='save'>Save</button>"
          "<button type='button' id='close' class='discard'>Close</button>"
          "</form>"
      );
    } else {
      overlay.appendHtml(this.generateHighscore(scores, score: score));
      overlay.appendHtml("<button type='button' id='close' class='discard'>Close</button>");
    }

  }

  /**
   * Closes a form (e.g. highscore form).
   */
  closeForm() => overlay.innerHtml = "";

  /**
   * Gets the user input from the highscore form.
   */
  String get user => (document.querySelector('#user') as InputElement).value;

  /**
   * Gets the password input from the highscore form.
   */
  String get password => (document.querySelector('#pwd') as InputElement).value;

  /**
   * Sets a warning text in the highscore form.
   */
  void warn(String message) {
    document.querySelector('#highscorewarning').innerHtml = message;
  }
}