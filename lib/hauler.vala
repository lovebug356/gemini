using GLib;
using Gee;
using Gemini;

namespace Gemini {
  public class Hauler : GLib.Object {
    public Layout layout;
    public string title;
    public ArrayList<Terminal> terminals;
    public ArrayList<Terminal> focus_terminals;

    public signal void all_terminals_exited ();
    public signal void layout_changed ();

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
          if (value != _visible) {
            if (value) {
              layout.all_terminals_add (terminals);
              if (get_focus_terminal () != null) {
                terminal_set_focus (get_focus_terminal ());
              } else if (terminals.size > 0)
                terminal_set_focus (terminals.get (0));
            } else {
              layout.all_terminals_remove ();
            }
            _visible = value;
          }
        }
      }
    }

    public int size {
      get {
        return terminals.size;
      }
    }

    public Gemini.Terminal get_focus_terminal () {
      Gemini.Terminal temp = null;
      if (focus_terminals.size != 0) {
        temp = focus_terminals.get (0);
      }
      return temp;
    }

    public void set_focus_terminal (Gemini.Terminal? focus_terminal) {
      if (focus_terminal != null) {
        if (focus_terminal in focus_terminals) {
          focus_terminals.remove (focus_terminal);
        }
        focus_terminals.insert (0, focus_terminal);
      }
    }

    Gemini.Layout get_layout (GLib.Type layout_type) {

      if (layout_type == typeof (Gemini.TileLayout)) {
        return new Gemini.TileLayout ();
      } else if (layout_type == typeof (Gemini.FullscreenLayout)) {
        return new Gemini.FullscreenLayout ();
      }

      return new Gemini.TileLayout ();
    }

    public bool layout_switch (GLib.Type new_layout_type) {
      bool ret = false;
      lock (terminals) {
        if (new_layout_type != layout.get_type ()) {
          visible = false;
          layout = get_layout (new_layout_type);
          layout_changed ();
          ret = true;
        }
      }
      return ret;
    }

    construct {
      title = "";
      terminals = new ArrayList<Terminal> ();
      focus_terminals = new ArrayList<Terminal> ();
      _visible = false;
    }

    public Hauler copy () {
      int counter = 0;
      var hp = new Hauler (layout.get_type ());
      hp.title = title;
      lock (terminals) {
        /*hp.set_focus_terminal (get_focus_terminal ());*/
        foreach (Gemini.Terminal terminal in terminals) {
          hp.terminal_add (terminal, counter++);
        }
        for (int i=focus_terminals.size; i>0; i--) {
          hp.set_focus_terminal (focus_terminals[i-1]);
        }
      }
      return hp;
    }

    public bool terminal_add (Gemini.Terminal terminal, int position) {
      lock (terminals) {
        terminals.insert (position, terminal);

        if (visible) {
          layout.terminal_add (terminal, position);
          if (get_focus_terminal () == null)
            terminal_set_focus (terminal);
        }
      }
      return true;
    }

    public bool terminal_set_focus (Gemini.Terminal terminal) {
      bool ret = false;
      lock (terminals) {
        if (terminal in terminals) {
          set_focus_terminal (terminal);
          layout.terminal_grab_focus (terminal);
          ret = true;
        }
      }
      return ret;
    }

    public void terminal_refocus () {
      lock (terminals) {
        if (get_focus_terminal () != null)
          layout.terminal_grab_focus (get_focus_terminal ());
      }
    }

    public Gemini.Terminal terminal_get_focus () {
      return get_focus_terminal ();
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

        if (terminal == get_focus_terminal ()) {
          focus_terminals.remove (terminal);
          if (focus_terminals.size > 0) {
            terminal_set_focus (focus_terminals.get (0));
          } else if (terminals.size > 0) {
            terminal_set_focus (terminals.get (0));
          }
        } else if (terminal in focus_terminals) {
          focus_terminals.remove (terminal);
        }

        if (terminals.size == 0)
          all_terminals_exited ();
      }
    }

    public void terminal_zoom (Gemini.Terminal terminal) {
      terminal_move (terminal, 0);
      terminal_set_focus (terminal);
    }

    public void terminal_focus_down () {
      lock (terminals) {
        var index = terminals.index_of (get_focus_terminal ());
        if (index < (terminals.size-1)) {
          terminal_set_focus (terminals.get (index + 1));
        } else if (index == terminals.size - 1) {
          terminal_set_focus (terminals.get (0));
        }
      }
    }

    public void terminal_focus_up () {
      lock (terminals) {
        var index = terminals.index_of (get_focus_terminal ());
        if (index > 0) {
          terminal_set_focus (terminals.get (index - 1));
        } else if (index == 0) {
          terminal_set_focus (terminals.get (terminals.size - 1));
        }
      }
    }
  }
}
