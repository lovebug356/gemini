using GLib;
using Gee;
using Gtk;

namespace Gemini {
  public abstract class Layout : Gtk.VBox {
    public string name {get; set;}
    public string title {get; set;}

    public virtual bool terminal_add (Gemini.Terminal terminal, uint position) {return false;}
    public virtual bool terminal_move (Gemini.Terminal terminal, uint new_position) {return false;}
    public virtual bool terminal_remove (Gemini.Terminal terminal) {return false;}
    public virtual bool all_terminals_add (ArrayList<Gemini.Terminal> terminals) {return false;}
    public virtual bool all_terminals_remove () {return false;}
    public virtual void width_change (int delta) {}
    public virtual void height_change (int delta) {}

    public virtual void terminal_grab_focus (Gemini.Terminal terminal) {
      terminal.grab_focus ();
    }
  }
}
