using GLib;
using Gee;
using Gemini;

namespace Gemini {
  public class Tag : GLib.Object {
    public Layout layout;
    public GLib.Type layout_type {get; construct;}
    public string title;
    ArrayList<Terminal> terminals;

    public Tag (GLib.Type layout_type) {
      this.layout_type = layout_type;
      /* FIXME do this based on the type */
      layout = new Gemini.TileLayout ();
    }

    construct {
      layout = null;
      title = "";
      terminals = new ArrayList<Terminal> ();
    }

    public Tag copy () {
      Tag tag_copy = new Tag (layout_type);
      tag_copy.title = title;
      return tag_copy;
    }

    public void layout_hide () {
      layout.all_terminals_remove ();
    }

    public void layout_show () {
      layout.all_terminals_add (terminals);
    }

    public void layout_switch (GLib.Type layout_type) {
      layout.all_terminals_remove ();
      // this.layout_type = layout_type;
      layout = new Gemini.TileLayout ();
      layout_show ();
    }

    public void terminal_add (Gemini.Terminal terminal, int position) {
    }
  }
}
