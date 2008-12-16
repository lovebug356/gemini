using GLib;
using Gee;
using Gemini;

void test_layout_create () {
  var layout = new FullscreenLayout ();

  assert (layout != null);
  assert (layout.name == "fullscreen");
  GLib.List children = layout.get_children ();
  assert (children.length () == 0);
}

Gemini.Terminal get_fullscreen_terminal (Gemini.Layout layout) {
  GLib.List children = layout.get_children ();
  assert (children.length () == 1);
  return (Gemini.Terminal)children.nth_data (0);
}

void test_layout_add_1 () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal = new Gemini.Terminal ();
  layout.terminal_add (terminal, 0);

  /* adding one terminal, should be fullscreen */
  assert (get_fullscreen_terminal (layout) == terminal);
  assert (layout.size == 1);
}

void test_layout_add_2 () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 0);

  /* adding the second one, first still needs to be fullscreen */
  assert (get_fullscreen_terminal (layout) == terminal1);
  assert (layout.size == 2);
}

void test_layout_grab_focus () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 0);

  /* grab the focus of the current terminal */
  layout.terminal_grab_focus (terminal1);
  assert (get_fullscreen_terminal (layout) == terminal1);

  /* grab the focus of a hidden terminal */
  layout.terminal_grab_focus (terminal2);
  assert (get_fullscreen_terminal (layout) == terminal2);

  /* grab the focus of a non existing terminal */
  layout.terminal_grab_focus (new Terminal ());
  assert (get_fullscreen_terminal (layout) == terminal2);

  /* grab the focus of the first one again */
  layout.terminal_grab_focus (terminal1);
  assert (get_fullscreen_terminal (layout) == terminal1);
}

void test_layout_remove () {
  var layout = new Gemini.FullscreenLayout ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal2, 1);
  layout.terminal_add (terminal3, 2);

  /* remove the active terminal */
  layout.terminal_remove (terminal1);
  assert (layout.size == 2);
  assert (get_fullscreen_terminal (layout) == terminal2);

  /* remove a not active terminal */
  layout.terminal_remove (terminal3);
  assert (get_fullscreen_terminal (layout) == terminal2);

  layout.terminal_add (terminal1, 0);
  layout.terminal_add (terminal3, 0);

  /* move the terminals around */
  layout.terminal_move (terminal1, 0);
  layout.terminal_move (terminal3, 2);

  layout.terminal_remove (terminal2);
  assert (get_fullscreen_terminal (layout) == terminal1);
}

void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/Gemini/Layout/Fullscreen/Create", test_layout_create);
  Test.add_func ("/Gemini/Layout/Fullscreen/Add1", test_layout_add_1);
  Test.add_func ("/Gemini/Layout/Fullscreen/Add2", test_layout_add_2);
  Test.add_func ("/Gemini/Layout/Fullscreen/GrabFocus", test_layout_grab_focus);
  Test.add_func ("/Gemini/Layout/Fullscreen/Remove", test_layout_remove);

  Test.run ();
}
