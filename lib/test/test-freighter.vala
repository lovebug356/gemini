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

  f.hauler_new (typeof (Gemini.TileLayout));

  assert (f.size == 2);
  var h2 = f.hauler_get (1);
  assert (h2 != null);
  assert (f.active_hauler == h1);
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

public static void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/Gemini/Freighter/Create", test_freighter_create);
  Test.add_func ("/Gemini/Freighter/AddHauler", test_freighter_add_hauler);
  Test.add_func ("/Gemini/Freighter/HaulerRemove", test_freighter_remove_hauler);

  Test.run ();
}
