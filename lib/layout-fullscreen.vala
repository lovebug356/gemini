using GLib;
using Gee;
using Gemini;

namespace Gemini {
  public class FullscreenLayout : Layout {
    Terminal fullscreen;

    construct {
      name = "fullscreen";
      fullscreen = null;
      show ();
    }

    /* ONLY for debugging */
    public int size {
      get {
        var temp = get_children ();
        return (int) temp.length ();
      }
    }

    void terminal_fullscreen (Terminal? terminal) {
      lock (fullscreen) {
        if (fullscreen != terminal) {
          if (fullscreen != null) {
            fullscreen.hide ();
          }
          fullscreen = terminal;
          if (fullscreen != null) {
            terminal.show ();
            terminal.grab_focus ();
          }
        }
      }
    }

    public override void terminal_grab_focus (Terminal terminal) {
      terminal_fullscreen (terminal);
    }

    public override bool terminal_add (Terminal terminal, uint position) {
      lock (fullscreen) {
        pack_start (terminal, true, true, 0);
        if (get_children ().length () != 1) {
          terminal.hide ();
        } else {
          terminal_fullscreen (terminal);
        }
      }
      return true;
    }
    
    public override bool terminal_move (Terminal terminal, uint position) {
      return true;
    }

    public override bool terminal_remove (Terminal terminal) {
      lock (fullscreen) {
        remove (terminal);
      }
      return true;
    }

    public override bool all_terminals_add (ArrayList<Gemini.Terminal> terminals) {
      lock (fullscreen) {
        foreach (Terminal t in terminals) {
          terminal_add (t, 0);
        }
      }
      return true;
    }

    public override bool all_terminals_remove () {
      lock (fullscreen) {
        GLib.List<weak Gtk.Widget> children = get_children ();
        foreach (Gtk.Widget w in children) {
          Terminal t = (Terminal) w;
          remove (t);
        }
        fullscreen = null;
      }
      return true;
    }
  }
}
