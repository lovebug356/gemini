using GLib;
using Gee;

namespace Gemini {
  public class TileLayout : Gemini.Layout {
    Gemini.Terminal zoom_terminal;
    Gtk.HBox hbox;
    Gtk.VBox stack;
    
    construct {
      this.name = "tile";
      zoom_terminal = null;

      hbox = new Gtk.HBox (false, 0);
      add (hbox);

      stack = new Gtk.VBox (false, 0);
      hbox.pack_end (stack, false, false, 0);
      hbox.reorder_child (stack, 1);

      hbox.show ();
      show ();
    }

    void terminal_push (Gemini.Terminal terminal) {
      stack.pack_end (terminal, false, false, 0);
    }

    public void terminal_add_on_top (Gemini.Terminal terminal) {
      if (terminal != zoom_terminal) {
        if (zoom_terminal != null) {
          hbox.remove (zoom_terminal);
          terminal_push (zoom_terminal);
        }
        hbox.pack_end (terminal, false, false, 0);
        zoom_terminal = terminal;
      }
    }

    public override bool terminal_move (Gemini.Terminal terminal, uint position) {
      if (position == 0 && terminal != zoom_terminal) {
        stack.remove (terminal);
        terminal_add_on_top (terminal);
      } else {
      }
      return true;
    }

    public override bool terminal_add (Gemini.Terminal terminal, uint position) {
      if (position == 0) {
        terminal_add_on_top (terminal);
      } else {
        stack.pack_end (terminal, false, false, 0);
        stack.reorder_child (terminal, (int)position - 1);
      }
      terminal.show ();
      return true;
    }
  }
}