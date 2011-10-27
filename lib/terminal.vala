using Gtk;
using GLib;

public class Gemini.Terminal : Vte.Terminal {

  public signal void selection (bool active);
  int child_pid;

  public Terminal (string? working_dir=null) {
    child_pid = fork_command (null, null, null, working_dir, false, false, false);
  }

  construct {
    set_size_request (0, 0);
    set_size (80, 24);
    show ();
    button_release_event.connect (button_release_event_cb);
    get_working_dir ();

    set_audible_bell (Gemini.configuration.audible_bell);
    set_visible_bell (Gemini.configuration.visible_bell);
    set_allow_bold (Gemini.configuration.allow_bold);
    set_scroll_on_output (Gemini.configuration.scroll_on_output);
    set_scroll_on_keystroke (Gemini.configuration.scroll_on_keystroke);
    set_cursor_blinks (Gemini.configuration.cursor_blinks);
    set_opacity ((uint16)Gemini.configuration.opacity);
    set_scrollback_lines (Gemini.configuration.scrollback_lines);
    set_font_from_string (Gemini.configuration.font);
    set_colors (Gemini.configuration.foreground_color, Gemini.configuration.background_color, Gemini.configuration.color_palette);
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

  bool button_release_event_cb (Gtk.Widget sender, Gdk.EventButton button) {
    if (button.type == Gdk.EventType.BUTTON_RELEASE &&
        button.button == 1) {
      selection (get_has_selection ());
    }
    return false;
  }
}
