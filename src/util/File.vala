using GLib;

namespace Gemini {
  public class File : Object {
    
    public static string pixbufs (string filename) {
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
          full_filename = folder + "/pixbufs/" + filename;
          if (FileUtils.test (full_filename, FileTest.EXISTS)) {
            return full_filename;
          }
        }
      }
      /* check on the default location */
      full_filename = "/usr/share/pixbufs/" + filename;
      if (FileUtils.test (full_filename, FileTest.EXISTS)) {
        return full_filename;
      }
      return "";
    }
  }
}

