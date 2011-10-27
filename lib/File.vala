using GLib;

namespace Gemini {
  public class File : Object {
    
    public static string pixmaps (string filename) {
      /* check in the build folder */
      string full_filename = "share/" + filename;
      if (FileUtils.test (full_filename, FileTest.EXISTS)) {
        return full_filename;
      }
      /* check in the xdg data dirs */
      string xdg_data = Environment.get_variable ("XDG_DATA_DIRS");
      if (xdg_data != null && xdg_data != "") {
        string[] xdg_data_list = xdg_data.split (":");
        foreach (string folder in xdg_data_list) {
          full_filename = folder + "/pixmaps/" + filename;
          if (FileUtils.test (full_filename, FileTest.EXISTS)) {
            return full_filename;
          }
        }
      }
      /* check on the default location */
      full_filename = "/usr/share/pixmaps/" + filename;
      if (FileUtils.test (full_filename, FileTest.EXISTS)) {
        return full_filename;
      }
      return "";
    }

    static string? check_filename (string filepath) {
      if (filepath == null || filepath == "")
        return null;

      string filename = Path.build_filename (filepath, "gemini", "gemini.rc");
      if (FileUtils.test (filename, FileTest.EXISTS)) {
        return filename;
      }

      return null;
    }

    public static string configuration_file () {
      /* check in the build folder */
      string full_filename = "share/gemini.rc";
      if (FileUtils.test (full_filename, FileTest.EXISTS)) {
        return full_filename;
      }

      /* check in the xdg configuration of the user */
      full_filename = check_filename (Environment.get_variable ("XDG_CONFIG_HOME"));
      if (full_filename != null)
        return full_filename;

      /* check in the xdg data dirs */
      string xdg_data = Environment.get_variable ("XDG_CONFIG_DIRS");
      if (xdg_data != null && xdg_data != "") {
        string[] xdg_data_list = xdg_data.split (":");
        foreach (string folder in xdg_data_list) {
          full_filename = check_filename (folder);
          if (full_filename != null)
            return full_filename;
        }
      }

      /* check on the default location */
      full_filename = "/usr/share/gemini/gemini.rc";
      if (FileUtils.test (full_filename, FileTest.EXISTS)) {
        return full_filename;
      }

      return "";
    }
  }
}

