using GLib;
using Gee;

namespace Gemini {
  public class Collection : Object {
    ArrayList<Gemini.Terminal> terminals;

    construct {
      terminals = new ArrayList<Gemini.Terminal> ();
    }

    public int size {
      get {
        return terminals.size;
      }
    }

    public void add (Gemini.Terminal terminal) {
      terminals.add (terminal);
    }

    public void remove (Gemini.Terminal terminal) {
      terminals.remove (terminal);
    }

    public Gemini.Terminal? get (int i) {
      if (i >= 0 && i < terminals.size)
        return terminals.get (i);
      else
        return null;
    }

    public void zoom (Gemini.Terminal terminal) {
      if (terminals.index_of (terminal) > 0) {
        terminals.remove (terminal);
        terminals.insert (0, terminal);
      }
    }
  }
}
