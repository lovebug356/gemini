using GLib;
using Gee;

namespace Gemini {
  public class TileLayout : Gemini.Layout {
    Gemini.Terminal zoom_terminal;
    Gtk.HBox hbox;
    Gtk.VBox stack;
    ArrayList<Gemini.Terminal> stack_terminals;
    int stack_width;
    
    public int size {
      get {
        return stack_terminals.size;
      }
    }
    
    construct {
      this.name = "tile";
      zoom_terminal = null;

      hbox = new Gtk.HBox (false, 0);
      hbox.set_homogeneous (false);
      hbox.size_allocate += size_allocate_cb;
      pack_start (hbox, true, true, 0);

      stack_width = 40;
      stack = new Gtk.VBox (true, 0);
      hbox.pack_end (stack, false, false, 0);
      stack.set_size_request (0, 0);

      stack_terminals = new ArrayList<Gemini.Terminal> ();

      stack.show ();
      hbox.show ();
      show ();
    }

    void size_allocate_cb (Gtk.Widget wdg, Gdk.Rectangle alloc) {
      if (stack_width > 95) {
        stack_width = 95;
      }
      stack.set_size_request ((stack_terminals.size > 1 ? (allocation.width * stack_width) / 100: 0), 0);
    }

    void stack_push (Gemini.Terminal terminal) {
      stack.pack_end (terminal, true, true, 0);
      stack_terminals.insert (1, terminal);
      stack.reorder_child (terminal, stack_terminals.size - 1);
    }

    Gemini.Terminal? stack_pop () {
      if (stack_terminals.size <= 1)
        return null;

      var terminal = stack_terminals.get (1);

      if (terminal != null) {
        stack.remove (terminal);
        stack_terminals.remove (terminal);
      }
      return terminal;
    }

    void terminal_set_zoom (Gemini.Terminal? terminal) {
      if (terminal == null)
        return;

      stack_terminals.insert (0, terminal);

      if (zoom_terminal != null) {
        hbox.remove (zoom_terminal);
        stack_terminals.remove (zoom_terminal);
        stack_push (zoom_terminal);
      }

      hbox.pack_end (terminal, true, true, 0);
      zoom_terminal = terminal;
    }

    public override bool terminal_move (Gemini.Terminal terminal, uint position) {
      if (position >= stack_terminals.size) {
        position = stack_terminals.size - 1;
      }

      if ((terminal == zoom_terminal && position == 0) ||
          (position > 0 && terminal == stack_terminals.get ((int)position)))
        return true;

      if (position == 0) {
        stack.remove (terminal);
        stack_terminals.remove (terminal);
        terminal_set_zoom (terminal);
      } else {
        if (terminal == zoom_terminal) {
          var zoom = stack_pop ();
          terminal_set_zoom (zoom);
        }
        stack_terminals.remove (terminal);
        stack_terminals.insert ((int)position, terminal);

        uint new_pos = (stack_terminals.size - 1) - (int)position;
        stack.reorder_child (terminal, (int)new_pos);
      }
      return true;
    }

    public override bool terminal_add (Gemini.Terminal terminal, uint position) {
      if (position == 0) {
        terminal_set_zoom (terminal);
      } else {
        int stack_pos = (stack_terminals.size) - (int)position;
        stack.pack_end (terminal, false, false, 0);
        stack_terminals.insert ((int)position, terminal);
        stack.reorder_child (terminal, stack_pos);
      }
      terminal.show ();
      return true;
    }

    public override bool terminal_remove (Gemini.Terminal terminal) {
      if (!(terminal in stack_terminals) && terminal != zoom_terminal)
        return false;

      if (terminal == zoom_terminal) {
        var zoom = stack_pop ();
        hbox.remove (zoom_terminal);
        zoom_terminal = null;
        stack_terminals.remove (terminal);
        if (zoom != null)
          terminal_set_zoom (zoom);
      } else {
        stack_terminals.remove (terminal);
        stack.remove (terminal);
      }
      return true;
    }

    public override bool all_terminals_add (ArrayList<Gemini.Terminal> list) {
      int position = stack_terminals.size;
      foreach (Gemini.Terminal terminal in list) {
        terminal_add (terminal, position);
        position += 1;
      }
      return true;
    }

    public override bool all_terminals_remove () {
      while (size > 0) {
        var terminal = stack_terminals.get (0);
        terminal_remove (terminal);
      }
      return true;
    }
  }
}
