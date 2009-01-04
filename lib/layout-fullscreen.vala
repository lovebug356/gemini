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

    /* always called under the terminals lock */
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
          t.hide ();
        }
      }
      return true;
    }

    public override bool all_terminals_remove () {
      lock (fullscreen) {
        GLib.List<unowned Terminal> children = get_children ();
        foreach (Terminal t in children) {
          remove (t);
        }
      }
      return true;
    }
  }
}
