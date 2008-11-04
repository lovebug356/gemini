using GLib;
using Gee;

void test_terminal_create () {
  var terminal = new Gemini.Terminal ();
  assert (terminal != null);
}

void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/Gemini/Terminal/Create", test_terminal_create);

  Test.run ();
}
