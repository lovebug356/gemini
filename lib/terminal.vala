using Gtk;
using GLib;

namespace Gemini {
  public class Terminal : Vte.Terminal {

    public signal void selection (bool active);
    int child_pid;

    public Terminal (string? working_dir=null) {
      child_pid = fork_command (null, null, null, working_dir, false, false, false);
    }

    construct {
      set_size_request (0, 0);
      set_size (80, 24);
      show ();
      button_release_event += button_release_event_cb;
      get_working_dir ();

      /* set the zenburn colors */
      Gdk.Color foreground = Gdk.Color ();
      Gdk.Color background = Gdk.Color ();
      Gdk.Color temp = Gdk.Color ();
      Gdk.Color[] palette = new Gdk.Color[16];

      Gdk.Color.parse ("#dcdccc", out foreground);
      Gdk.Color.parse ("#3f3f3f", out background);

      string palette_colors = "#3F3F3F3F3F3F:#FFFF00000000:#EFEFEFEFEFEF:#E3E3CECEABAB:#DFDFAFAF8F8F:#CCCC93939393:#7F7F9F9F7F7F:#DCDCDCDCCCCC:#3F3F3F3F3F3F:#FFFFCFCFCFCF:#EFEFEFEFEFEF:#E3E3CECEABAB:#DFDFAFAF8F8F:#CCCC93939393:#7F7F9F9F7F7F:#DCDCDCDCCCCC";
      string[] palette_color = palette_colors.split (":");
      for(int i=0; i < 16; i++) {
        Gdk.Color.parse (palette_color[i], out temp);
        palette[i] = temp;
      }
      set_colors (foreground, background, palette);
    }

    public string get_working_dir () {
      string filename = "/proc/%d/cwd".printf (child_pid);
      string content;
      try {
        content = FileUtils.read_link (filename);
      } catch (FileError e) {
        content = null;
      }
      return content;
    }

    bool button_release_event_cb (Gemini.Terminal terminal, Gdk.EventButton button) {
      if (button.type == Gdk.EventType.BUTTON_RELEASE &&
          button.button == 1) {
        selection (get_has_selection ());
      }
      return false;
    }
  }
}
