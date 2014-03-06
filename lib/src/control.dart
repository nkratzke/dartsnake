part of dartsnake;

void eventHandling() {

  final game = querySelector('#snakegame');
  final subtitle = querySelector('#subtitle');


  var gameState = "stopped";

  final model = new SnakeGame(gamesize);
  final view = new SnakeView();

  // Game is started/restarted by user
  view.startButton.onClick.listen((_) {
    game.innerHtml = new Iterable.generate(gamesize, (row) {
      return "<tr>${new Iterable.generate(gamesize, (col) => "<td id='field_${row}_${col}'></td>").join()}</tr>";
    }).join();
    subtitle.remove();
    view.startButton.innerHtml = "Restart";
    view.update(model.field);
    gameState = "started";
  });




}