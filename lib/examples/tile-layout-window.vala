using Gtk;
using GLib;

namespace Gemini {
  public class GeminiTile : Gtk.Window {
    Gemini.Layout layout;

    construct {
      layout = new Gemini.TileLayout ();
      layout.terminal_add (new_terminal (), 0);
      layout.terminal_add (new_terminal (), 0);
      layout.terminal_add (new_terminal (), 0);

      add (layout);
      set_default_size (640, 480);
      show ();
    }

    Gemini.Terminal new_terminal () {
      var terminal = new Gemini.Terminal ();
      terminal.key_press_event += key_press_event_cb;
      return terminal;
    }

    bool key_press_event_cb (Gemini.Terminal terminal, Gdk.EventKey event_key) {
      bool valid = true;
      if ((event_key.state & Gdk.ModifierType.MOD1_MASK) == Gdk.ModifierType.MOD1_MASK)
      {
        /*string name = Gdk.keyval_name (event_key.keyval);*/
        /*switch (name) {*/
        /*case "Return":*/
        /*layout.terminal_focus_next (terminal);*/
        /*break;*/
        /*default:*/
        /*valid = false;*/
        /*break;*/
        /*}*/

      } else if ((event_key.state & Gdk.ModifierType.MOD4_MASK) == Gdk.ModifierType.MOD4_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "o":
            layout.terminal_add (new_terminal (), 0);
            break;
          case "x":
            layout.terminal_remove (terminal);
            break;
            /*case "Return":*/
            /*layout.virt_terminal_zoom (terminal);*/
            /*break;*/
            /*case "l":*/
            /*layout.virt_terminal_resize (terminal, 30, 0);*/
            /*break;*/
            /*case "h":*/
            /*layout.virt_terminal_resize (terminal, -30, 0);*/
            /*break;*/
            /*case "j":*/
            /*layout.virt_terminal_resize (terminal, 0, -30);*/
            /*break;*/
            /*case "k":*/
            /*layout.virt_terminal_resize (terminal, 0, 30);*/
            /*break;*/
            /*case "f":*/
            /*change_layout (typeof (FullscreenLayout));*/
            /*layout.virt_terminal_focus (terminal);*/
            /*break;*/
            /*case "space":*/
            /*change_layout (typeof (TileLayout));*/
            /*layout.virt_terminal_focus (terminal);*/
            /*break;*/
            /*case "b":*/
            /*layout.terminal_focus_back ();*/
            /*break;*/
          default:
            valid = false;
            break;
        }
      } else
        valid = false;
      return valid;
    }
  }

  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.GeminiTile ();
    Gtk.main ();
  }
}
