using GLib;
using Gee;

void test_freighter_create () {
  var f = new Gemini.Freighter ();
  assert (f != null);
  assert (f is Gemini.Freighter);
  assert (f.size == 0);
  assert (f.hauler_get (0) == null);
  assert (f.active_hauler == null);
}

void test_freighter_add_hauler () {
  var f = new Gemini.Freighter ();
  f.hauler_new (typeof (Gemini.TileLayout));

  assert (f.size == 1);
  var h1 = f.hauler_get (0);
  assert (h1 != null);
  assert (f.active_hauler == h1);
  assert (f.active_hauler.visible == true);

  f.hauler_new (typeof (Gemini.TileLayout));
  assert (f.size == 2);
  var h2 = f.hauler_get (1);
  assert (h2 != null);
  assert (f.active_hauler == h1);
  assert (f.active_hauler.visible == true);
}

void test_freighter_remove_hauler () {
  var f = new Gemini.Freighter ();
  f.hauler_new (typeof (Gemini.TileLayout));
  f.hauler_new (typeof (Gemini.TileLayout));
  f.hauler_new (typeof (Gemini.TileLayout));

  var h1 = f.hauler_get (0);
  var h2 = f.hauler_get (1);
  var h3 = f.hauler_get (2);

  f.hauler_remove (h1);
  assert (f.size == 2);
  assert (f.active_hauler == h2);

  f.hauler_remove (h3);
  assert (f.size == 1);
  assert (f.active_hauler == h2);

  f.hauler_remove (h2);
  assert (f.size == 0);
  assert (f.active_hauler == null);
}

void test_freighter_hauler_move () {
  var f = new Gemini.Freighter ();
  f.hauler_new (typeof (Gemini.TileLayout));
  f.hauler_new (typeof (Gemini.TileLayout));
  f.hauler_new (typeof (Gemini.TileLayout));

  var h1 = f.hauler_get (0);
  var h2 = f.hauler_get (1);
  var h3 = f.hauler_get (2);

  f.hauler_move (h1, 0);
  assert (f.hauler_get (0) == h1);
  assert (f.hauler_get (1) == h2);
  assert (f.hauler_get (2) == h3);

  f.hauler_move (h1, 1);
  assert (f.hauler_get (0) == h2);
  assert (f.hauler_get (1) == h1);
  assert (f.hauler_get (2) == h3);
}

void test_freighter_hauler_show () {
  var f = new Gemini.Freighter ();
  f.hauler_new (typeof (Gemini.TileLayout));
  f.hauler_new (typeof (Gemini.TileLayout));
  f.hauler_new (typeof (Gemini.TileLayout));

  var h1 = f.hauler_get (0);
  var h2 = f.hauler_get (1);
  var h3 = f.hauler_get (2);

  assert (f.active_hauler == h1);
  f.hauler_show (h1);
  assert (f.active_hauler == h1);
  f.hauler_show (h2);
  assert (f.active_hauler == h2);
  f.hauler_show (h3);
  assert (f.active_hauler == h3);
}

void test_freighter_terminal_add () {
  var f = new Gemini.Freighter ();
  f.hauler_new (typeof (Gemini.TileLayout));
  var h1 = f.hauler_get (0);

  var t = new Gemini.Terminal ();

  f.terminal_add (t);
  assert (f.active_hauler.terminal_get_position (t) == 0);
}

void test_freighter_terminal_remove () {
  var f = new Gemini.Freighter ();
  f.hauler_new (typeof (Gemini.TileLayout));

  var t = new Gemini.Terminal ();
  var t2 = new Gemini.Terminal ();
  f.terminal_add (t);
  f.active_hauler.terminal_set_focus (t);
  f.terminal_add (t2);

  f.terminal_remove (t);
  assert (f.active_hauler.terminal_get_position (t) == -1);
  assert (f.active_hauler.terminal_get_focus () == t2);
}

void test_freighter_terminal_close () {
  var f = new Gemini.Freighter ();
  f.hauler_new (typeof (Gemini.TileLayout));
  f.hauler_new (typeof (Gemini.TileLayout));

  var h1 = f.hauler_get (0);
  var h2 = f.hauler_get (1);
  var t = new Gemini.Terminal ();
  var t2 = new Gemini.Terminal ();

  f.hauler_show (h1);
  f.terminal_add (t);
  f.terminal_add (t2);
  f.hauler_show (h2);
  f.terminal_add (t);
  f.hauler_show (h1);

  assert (f.terminal_size == 2);
  f.terminal_close (t);
  assert (f.terminal_size == 2);
  f.terminal_close (t2);
  assert (f.terminal_size == 1);
}

public static void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/Gemini/Freighter/Create", test_freighter_create);
  Test.add_func ("/Gemini/Freighter/AddHauler", test_freighter_add_hauler);
  Test.add_func ("/Gemini/Freighter/HaulerRemove", test_freighter_remove_hauler);
  Test.add_func ("/Gemini/Freighter/HaulerMove", test_freighter_hauler_move);
  Test.add_func ("/Gemini/Freighter/HaulerShow", test_freighter_hauler_show);
  Test.add_func ("/Gemini/Freighter/TerminalAdd", test_freighter_terminal_add);
  Test.add_func ("/Gemini/Freighter/TerminalRemove", test_freighter_terminal_remove);
  Test.add_func ("/Gemini/Freighter/TerminalClose", test_freighter_terminal_close);

  Test.run ();
}
