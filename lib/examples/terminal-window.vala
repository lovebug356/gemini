using Gtk;
using GLib;

namespace Gemini {
  public class GeminiTile : Gtk.Window {
    construct {
      add (new Gemini.Terminal ());
      set_default_size (640, 480);
      show ();
    }
  }

  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.GeminiTile ();
    Gtk.main ();
  }
}
