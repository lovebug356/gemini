using Gemini;

namespace Gemini {
  public static Gemini.Configuration configuration;
}

public class Gemini.Configuration : GLib.Object {

  /*freighter */
  public bool statusbar = true;
  public bool menubar = true;
  public bool fullscreen = false;
  
  /* terminal */
  public bool allow_bold = false;
  public bool audible_bell = false;
  public bool cursor_blinks = false;
  public bool scroll_on_keystroke = false;
  public bool scroll_on_output = false;
  public bool visible_bell = false;
  public string font = "";
  public uint opacity = 0;
  public uint scrollback_lines = 1000;

  /* color */
  public string background_color = "";
  public string foreground_color = "";
  public string color_palette = "";

  string configuration_filename;

  public Configuration (string configuration_filename = "") {
    if (configuration_filename == "") {
      this.configuration_filename = Gemini.File.configuration_file ();
    } else {
      this.configuration_filename = configuration_filename;
    }
    if (this.configuration_filename == "") {
      stderr.printf ("WARNING: configuration file not found\n");
    } else {
      stdout.printf ("using configuration file: %s\n", this.configuration_filename);
      load_configuration ();
    }
  }

  string get_string (KeyFile file, string group_name, string key, string default_value) {
    try {
      return file.get_string (group_name, key);
    } catch (KeyFileError err) {
      stderr.printf ("ERROR: reading from configuration: %s\n", err.message);
      return default_value;
    }
  }

  bool get_bool (KeyFile file, string group_name, string key, bool default_value) {
    try {
      return file.get_boolean (group_name, key);
    } catch (KeyFileError err) {
      stderr.printf ("ERROR: reading from configuration: %s\n", err.message);
      return default_value;
    }
  }

  int get_int (KeyFile file, string group_name, string key, int default_value) {
    try {
      return file.get_integer (group_name, key);
    } catch (KeyFileError err) {
      stderr.printf ("ERROR: reading from configuration: %s\n", err.message);
      return default_value;
    }
  }

  void load_configuration () {
    var file = new KeyFile ();
    file.load_from_file (configuration_filename, KeyFileFlags.NONE);

    /* freighter */
    statusbar = get_bool (file, "freighter", "statusbar", true);
    menubar = get_bool (file, "freighter", "menubar", true);
    fullscreen = get_bool (file, "freighter", "fullscreen", false);

    /* terminal */
    allow_bold = get_bool (file, "terminal", "allow_bold", false);
    audible_bell = get_bool (file, "terminal", "audible_bell", false);
    cursor_blinks = get_bool (file, "terminal", "cursor_blinks", false);
    scroll_on_keystroke = get_bool (file, "terminal", "scroll_on_keystroke", false);
    scroll_on_output = get_bool (file, "terminal", "scroll_on_output", false);
    visible_bell = get_bool (file, "terminal", "visible_bell", false);
    font = get_string (file, "terminal", "font", "#000000");
    opacity = get_int (file, "terminal", "opacity", 0);
    scrollback_lines = get_int (file, "terminal", "scrollback_lines", 1000);

    /* color */
    foreground_color = get_string (file, "color", "foreground", "#ffffff");
    background_color = get_string (file, "color", "background", "#000000");
    color_palette = get_string (file, "color", "palette", "#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff:#ffffff");
  }
}
