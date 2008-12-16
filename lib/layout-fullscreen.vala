using GLib;
using Gee;
using Gemini;

namespace Gemini {
  public class FullscreenLayout : Layout {
    ArrayList<Terminal> terminals;
    Terminal fullscreen;

    construct {
      name = "fullscreen";
      terminals = new ArrayList<Terminal> ();
      show ();
    }

    /* ONLY for debugging */
    public int size {
      get {
        return terminals.size;
      }
    }

    /* always called under the terminals lock */
    void terminal_fullscreen (Terminal? terminal) {
      if (fullscreen != terminal) {
        if (fullscreen != null) {
          remove (fullscreen);
        }
        fullscreen = terminal;
        if (fullscreen != null) {
          pack_start (terminal, true, true, 0);
          terminal.show ();
        }
      }
    }

    public override void terminal_grab_focus (Terminal terminal) {
      lock (terminals) {
        if (fullscreen != terminal &&
          terminal in terminals) {
          terminal_fullscreen (terminal);
        }
      }
    }

    public override bool terminal_add (Terminal terminal, uint position) {
      lock (terminals) {
        terminals.insert ((int)position, terminal);
        if (fullscreen == null)
          terminal_fullscreen (terminal);
      }
      return true;
    }
    
    public override bool terminal_move (Terminal terminal, uint position) {
      lock (terminals) {
        if (terminal in terminals) {
          terminals.remove (terminal);
          terminals.insert ((int)position, terminal);
        }
      }
      return true;
    }

    public override bool terminal_remove (Terminal terminal) {
      lock (terminals) {
        if (terminal in terminals) {
          terminals.remove (terminal);
          if (terminal == fullscreen) {
            if (terminals.size > 0)
              terminal_fullscreen (terminals.get (0));
            else
              terminal_fullscreen (null);
          }
        }
      }
      return true;
    }

    public override bool all_terminals_add (ArrayList<Gemini.Terminal> terminals) {
      lock (this.terminals) {
        foreach (Terminal t in terminals) {
          terminal_add (t, this.terminals.size);
        }
      }
      return true;
    }

    public override bool all_terminals_remove () {
      lock (terminals) {
        while (terminals.size > 0) {
          terminal_remove (terminals.get (0));
        }
      }
      return true;
    }
  }
}
