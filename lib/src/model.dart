part of dartsnake;

class Snake {
  final SnakeGame _field;
  var _body = [];

  int _dr;
  int _dc;

  Snake.on(this._field) {
    final s = _field.size;
    _body = [{ 'row' : s / 2, 'col' : s / 2 }];
  }

  void move() {
    _body.insert(0, { 'row' : head['row'] + _dr, 'col' : head['col'] + _dc });
    _body.remove(tail);
  }

  void headUp()    { _dr = -1; _dc =  0; }
  void headDown()  { _dr =  1; _dc =  0; }
  void headLeft()  { _dr =  0; _dc = -1; }
  void headRight() { _dr =  0; _dc =  1; }

  int get length => _body.length;
  Map get head => _body.first;
  Map get tail => _body.last;
  List<Map> get body => _body;

}

class Mouse {
  final SnakeGame _field;
  int _row;
  int _col;
  int _dr;
  int _dc;

  Mouse.staticOn(this._field, this._row, this._col) {
    _dr = 0;
    _dc = 0;
  }

  Mouse.movingOn(this._field, this._row, this._col) {
    final r = new Random();
    _dr = -1 + r.nextInt(2);
    _dc = -1 + r.nextInt(2);
  }

  int get row => _row;
  int get col => _col;
  Map get pos => {'row' : _row, 'col' : _col };

  void headUp()    { _dr = -1; _dc =  0; }
  void headDown()  { _dr =  1; _dc =  0; }
  void headLeft()  { _dr =  0; _dc = -1; }
  void headRight() { _dr =  0; _dc =  1; }

  void move() {
    if (_dr < 0 && row == 0) _dr *= -1;
    if (_dc < 0 && col == 0) _dc *= -1;
    if (_dr > 0 && row == _field.size - 1) _dr *= -1;
    if (_dc > 0 && col == _field.size - 1) _dr *= -1;
    _row += _dr;
    _col += _dc;
  }
}

class SnakeGame {

  Snake _snake;
  var _mice = [];
  final int _size;

  SnakeGame(this._size) {
    _snake = new Snake.on(this);
    _mice.add(new Mouse.staticOn(this, 3, 3));
  }

  void nextStep() {
    snake.move();
    if (!gameOver) mice.forEach((mouse) => mouse.move());
  }

  bool get gameOver {
    return snake.head['row'] < 0 ||
           snake.head['row'] >= size ||
           snake.head['col'] < 0 ||
           snake.head['col'] >= size;
  }

  Snake get snake => _snake;
  List<Mouse> get mice => _mice;
  List<List<String>> get field {
    var _field = new Iterable.generate(_size, (row) {
      return new Iterable.generate(_size, (col) => "empty");
    });
    mice.forEach((m) => _field[m.row][m.col] = "mouse");
    snake.body.forEach((s) => _field[s['row']][s['col']] = "snake");
    return _field;
  }

  int get size => _size;

  String toString() => field.map((row) => row.join(" ")).join("\n");
}