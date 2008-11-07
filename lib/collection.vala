using GLib;
using Gee;

namespace Gemini {
  public class Collection : Object {
    ArrayList<Gemini.Terminal> terminals;
    Layout layout;

    construct {
      terminals = new ArrayList<Gemini.Terminal> ();
      layout = null;
    }

    public void set_layout (Layout layout) {
      lock (terminals) {
        this.layout = layout;
      }
    }

    public int size {
      get {
        return terminals.size;
      }
    }

    public void add_new_terminal () {
      lock (terminals) {
        terminals.add (new Gemini.Terminal ());
      }
    }

    public void add (Gemini.Terminal terminal) {
      lock (terminals) {
        terminals.add (terminal);
      }
    }

    public void remove (Gemini.Terminal terminal) {
      lock (terminals) {
        terminals.remove (terminal);
      }
    }

    public Gemini.Terminal? get (int i) {
      Gemini.Terminal terminal = null;
      lock (terminals) {
        if (i >= 0 && i < terminals.size)
          terminal = terminals.get (i);
      }
      return terminal;
    }

    public void zoom (Gemini.Terminal terminal) {
      lock (terminals) {
        if (terminals.index_of (terminal) > 0) {
          terminals.remove (terminal);
          terminals.insert (0, terminal);
        }
      }
    }
  }
}
