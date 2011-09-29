using GLib;
using Gee;
using Gemini;

void test_hauler_copy () {
  var f = new Freighter ();
  var h = new Hauler (typeof (TileLayout));
  f.hauler_add (h);

  /* initial position */
  assert (f.size == 1);
  assert (f.terminal_size == 0);
  assert (f.active_hauler == h);

  var t1 = new Terminal ();
  var t2 = new Terminal ();
  var t3 = new Terminal ();

  /* 3 terminals are added to the first hauler and are in the freighter */
  f.terminal_add (t1);
  f.terminal_add (t2);
  f.terminal_add (t3);

  assert (f.terminal_size == 3);
  assert (h.size == 3);

  /* make a copy of the current hauler and add it too the freighter */
  var h2 = h.copy ();
  f.hauler_add (h2);
  f.hauler_show (h2);

  assert (f.size == 2);
  assert (f.terminal_size == 3);
  assert (f.active_hauler == h2);
  assert (h2.size == h.size);

}

public static void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Gemini.configuration = new Gemini.Configuration ();

  Test.add_func ("/Gemini/Freighter/HaulerCopy", test_hauler_copy);

  Test.run ();
}
