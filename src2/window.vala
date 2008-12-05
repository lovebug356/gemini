using Gtk;
using GLib;

namespace Gemini {
  public class GeminiTile : Gtk.Window {
    Gemini.Freighter freighter;
    Gemini.Layout layout;

    construct {
      layout = null;
      freighter = new Gemini.Freighter ();
      freighter.hauler_change += hauler_change_cb;
      freighter.hauler_new (typeof (Gemini.TileLayout));

      terminal_new ();

      set_default_size (640, 480);
      show ();
    }

    void terminal_new () {
      lock (freighter) {
        var terminal = new Gemini.Terminal ();
        terminal.key_press_event += key_press_event_cb;
        freighter.terminal_add (terminal);
      }
    }

    void hauler_change_cb (Gemini.Freighter f) {
      lock (freighter) {
        if (freighter.active_hauler.layout != layout) {
          if (layout != null) {
            remove (layout);
          }
          layout = freighter.active_hauler.layout;
          add (layout);
        }
      }
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
            terminal_new ();
            break;
            /*case "Return":*/
            /*layout.virt_terminal_zoom (terminal);*/
            /*break;*/
            /*case "x":*/
            /*layout.terminal_close (terminal);*/
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
