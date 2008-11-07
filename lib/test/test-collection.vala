using GLib;
using Gee;

void test_collection_create () {
  var collection = new Gemini.Collection ();
  assert (collection != null);
}

void test_collection_add () {
  var collection = new Gemini.Collection ();
  var layout = new Gemini.TileLayout ();
  collection.set_layout (layout);
  collection.add (new Gemini.Terminal ());
  assert (collection.size == 1);
  collection.add (new Gemini.Terminal ());
  assert (collection.size == 2);
}

void test_collection_add_new_terminal () {
  var collection = new Gemini.Collection ();
  var layout = new Gemini.TileLayout ();
  collection.set_layout (layout);
  collection.add_new_terminal ();
  assert (collection.size == 1);
  collection.add_new_terminal ();
  assert (collection.size == 2);
}

void test_collection_add_without_layout () {
  var collection = new Gemini.Collection ();
  assert (collection.add_new_terminal () == false);
  var layout = new Gemini.TileLayout ();
  collection.set_layout (layout);
  assert (collection.size == 0);
  assert (collection.add_new_terminal () == true);
  assert (collection.size == 1);
}

void test_collection_remove () {
  var collection = new Gemini.Collection ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var layout = new Gemini.TileLayout ();
  collection.set_layout (layout);
  collection.add (terminal1);
  collection.add (terminal2);
  collection.remove (terminal1);
  assert (collection.size == 1);
  assert (collection.get (0) == terminal2);
  collection.add (terminal1);
  collection.remove (terminal1);
  assert (collection.size == 1);
  assert (collection.get (0) == terminal2);
}

void test_collection_get () {
  var collection = new Gemini.Collection ();
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  var layout = new Gemini.TileLayout ();
  collection.set_layout (layout);
  collection.add (terminal1);
  collection.add (terminal2);
  collection.add (terminal3);
  assert (collection.get (0) == terminal1);
  assert (collection.get (1) == terminal2);
  assert (collection.get (2) == terminal3);
  assert (collection.get (3) == null);
}

void test_collection_zoom () {
  var collection = new Gemini.Collection ();
  var layout = new Gemini.TileLayout ();
  collection.set_layout (layout);
  var terminal1 = new Gemini.Terminal ();
  var terminal2 = new Gemini.Terminal ();
  var terminal3 = new Gemini.Terminal ();
  collection.add (terminal1);
  collection.add (terminal2);
  collection.add (terminal3);
  collection.zoom (terminal2);
  assert (collection.get (0) == terminal2);
  assert (collection.get (1) == terminal1);
  assert (collection.get (2) == terminal3);
  assert (collection.get (3) == null);
}

void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/Gemini/Collection/Create", test_collection_create);
  Test.add_func ("/Gemini/Collection/Add", test_collection_add);
  Test.add_func ("/Gemini/Collection/AddNewTerminal", test_collection_add_new_terminal);
  Test.add_func ("/Gemini/Collection/AddWithoutLayout", test_collection_add_without_layout);
  Test.add_func ("/Gemini/Collection/Remove", test_collection_remove);
  Test.add_func ("/Gemini/Collection/Get", test_collection_get);
  Test.add_func ("/Gemini/Collection/Zoom", test_collection_zoom);

  Test.run ();
}
