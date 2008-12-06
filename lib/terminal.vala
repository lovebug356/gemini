using Gtk;
using GLib;

namespace Gemini {
  public class Terminal : Vte.Terminal {

    public signal void selection (bool active);
    int child_pid;

    public Terminal (string? working_dir) {
      child_pid = fork_command (null, null, null, working_dir, false, false, false);
    }

    construct {
      set_size_request (0, 0);
      set_size (80, 24);
      show ();
      button_release_event += button_release_event_cb;
      get_working_dir ();
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
