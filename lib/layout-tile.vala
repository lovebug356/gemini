using GLib;
using Gee;

namespace Gemini {
  public class TileLayout : Gemini.Layout {
    Gemini.Terminal zoom_terminal;
    Gtk.HBox hbox;
    Gtk.VBox stack;
    ArrayList<Gemini.Terminal> stack_terminals;
    
    construct {
      this.name = "tile";
      zoom_terminal = null;

      hbox = new Gtk.HBox (false, 0);
      add (hbox);

      stack = new Gtk.VBox (false, 0);
      hbox.pack_end (stack, false, false, 0);
      hbox.reorder_child (stack, 1);

      stack_terminals = new ArrayList<Gemini.Terminal> ();

      hbox.show ();
      show ();
    }

    void terminal_push (Gemini.Terminal terminal) {
      stack.pack_end (terminal, false, false, 0);
      stack_terminals.insert (0, terminal);
      stack.reorder_child (terminal, stack_terminals.size - 1);
    }

    void terminal_pop () {
      var terminal = stack_terminals.get (0);

      stack.remove (terminal);
      stack_terminals.remove (terminal);

      terminal_add_on_top (terminal);
    }

    void terminal_add_on_top (Gemini.Terminal terminal) {
      if (zoom_terminal != null) {
        hbox.remove (zoom_terminal);
        terminal_push (zoom_terminal);
      }
      hbox.pack_end (terminal, false, false, 0);
      zoom_terminal = terminal;
    }

    public override bool terminal_move (Gemini.Terminal terminal, uint position) {
      if (position > stack_terminals.size) {
        position = stack_terminals.size;
      }

      if ((terminal == zoom_terminal && position == 0) ||
          (position > 0 && terminal == stack_terminals.get ((int)position-1)))
        return true;

      if (position == 0 && terminal != zoom_terminal) {
        stack.remove (terminal);
        terminal_add_on_top (terminal);
      } else {
        if (terminal == zoom_terminal) {
          terminal_pop ();
        }
        stack_terminals.remove (terminal);
        stack_terminals.insert ((int)position -1, terminal);

        int new_pos = stack_terminals.size - (int) position - 1;
        stack.reorder_child (terminal, (int)new_pos);
      }
      return true;
    }

    public override bool terminal_add (Gemini.Terminal terminal, uint position) {
      if (position == 0) {
        terminal_add_on_top (terminal);
      } else {
        int stack_pos = (stack_terminals.size + 1) - (int)position;
        stack.pack_end (terminal, false, false, 0);
        stack_terminals.insert ((int)position-1, terminal);
        stack.reorder_child (terminal, stack_pos);
      }
      terminal.show ();
      return true;
    }
  }
}
