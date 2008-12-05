using GLib;
using Gee;
using Gemini;

namespace Gemini {
  public class Hauler : GLib.Object {
    public Layout layout;
    public string title;
    public ArrayList<Terminal> terminals;
    Gemini.Terminal focus_terminal;

    public Hauler (GLib.Type layout_type) {
      layout = get_layout (layout_type);
    }

    bool _visible;
    public bool visible {
      get {
        return _visible;
      }
      set {
        lock (terminals) {
          if (value) {
            layout.all_terminals_add (terminals);
          } else {
            layout.all_terminals_remove ();
          }
        }
      }
    }

    Gemini.Layout get_layout (GLib.Type layout_type) {

      if (layout_type is Gemini.TileLayout) {
          return new Gemini.TileLayout ();
      }

      return new Gemini.TileLayout ();
    }

    construct {
      title = "";
      terminals = new ArrayList<Terminal> ();
      _visible = false;
      focus_terminal = null;
    }

    public Hauler copy () {
      int counter = 0;
      var hp = new Hauler (layout.get_type ());
      hp.title = title;
      foreach (Gemini.Terminal terminal in terminals) {
        hp.terminal_add (terminal, counter++);
      }
      return hp;
    }

    public bool terminal_add (Gemini.Terminal terminal, int position) {
      lock (terminals) {
        terminals.insert (position, terminal);

        if (visible)
          layout.terminal_add (terminal, position);
      }
      return true;
    }

    public bool set_terminal_focus (Gemini.Terminal terminal) {
      bool ret = false;
      lock (terminals) {
        if (terminal in terminals) {
          focus_terminal = terminal;
          ret = true;
        }
      }
      return ret;
    }

    public Gemini.Terminal get_terminal_focus () {
      return focus_terminal;
    }

    public bool layout_switch (GLib.Type new_layout_type) {
      if (new_layout_type != layout.get_type ()) {
        return true;
      }
      return false;
    }

    public int terminal_get_position (Gemini.Terminal terminal) {
      int position = -1;
      lock (terminals) {
        if (terminal in terminals) {
          position = terminals.index_of (terminal);
        }
      }
      return position;
    }

    public void terminal_move (Gemini.Terminal terminal, int new_position) {
      lock (terminals) {
        terminals.remove (terminal);
        terminals.insert (new_position, terminal);
        if (visible)
          layout.terminal_move (terminal, new_position);
      }
    }

    public void terminal_remove (Gemini.Terminal terminal) {
      lock (terminals) {
        terminals.remove (terminal);
        if (visible)
          layout.terminal_remove (terminal);
      }
    }

    public void terminal_zoom (Gemini.Terminal terminal) {
      terminal_move (terminal, 0);
    }
  }
}
