namespace Gemini {
  public abstract class Search : GLib.Object {
    public void do_search (Gemini.Terminal terminal) {
      terminal.copy_clipboard ();
      var clipboard = terminal.get_clipboard (Gdk.SELECTION_CLIPBOARD);
      clipboard.request_text (request_text_cb);
    }

    public void request_text_cb (Gtk.Clipboard clipboard, string selection) {
      try {
        Process.spawn_command_line_async (get_command (selection.strip ()));
      } catch (GLib.SpawnError err) {}
    }

    public virtual string get_command (string selection) {
      return "";
    }
  }

  public class GnomeSearch : Search {
    public override string get_command (string selection) {
      return "gnome-search-tool --named=\"" + selection + "\" --start";
    }
  }

  public class DevHelpSearch : Search {
    public override string get_command (string selection) {
      return "devhelp -s \"" + selection + "\"";
    }
  }
}
