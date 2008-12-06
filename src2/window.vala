using Gtk;
using GLib;

namespace Gemini {
  public class GeminiTile : Gtk.Window {
    Gemini.Freighter freighter;
    Gemini.Layout layout;
    Gdk.Pixbuf gemini_logo;

    construct {
      layout = null;
      freighter = new Gemini.Freighter ();
      freighter.hauler_change += hauler_change_cb;
      freighter.hauler_new (typeof (Gemini.TileLayout));
      freighter.all_terminals_exited += all_terminals_exited_cb;

      terminal_new ();

      set_default_size (640, 480);
      string filename = Gemini.File.pixmaps ("gemini.svg");
      try {
        gemini_logo = new Gdk.Pixbuf.from_file (filename);
        set_icon (gemini_logo);
      } catch (Error e) {
        gemini_logo = null;
      }
      show ();
    }

    /*void about_action_cb (Gtk.Action action) {*/
    /*var dialog = new AboutDialog ();*/
    /*dialog.set_logo (gemini_logo);                                                                                                       */
    /*dialog.set_icon (gemini_logo);*/
    /*dialog.set_copyright ("Copyright (c) 2008 Thijs Vermeir");*/
    /*dialog.set_program_name ("Gemini Terminal");*/
    /**//* FIXME the version number needs to come from the build system */
    /*dialog.set_version (Gemini.version);*/
    /*dialog.set_website ("http://lovebug356.blogspot.com");*/
    /*dialog.run ();*/
    /*dialog.hide ();*/
    /*dialog.destroy ();*/
    /*}*/

    void all_terminals_exited_cb (Gemini.Freighter f) {
      Gtk.main_quit ();
    }

    void terminal_new () {
      lock (freighter) {
        string working_dir = null;
        if (freighter.active_hauler != null && freighter.active_hauler.size > 0)
          working_dir = freighter.active_hauler.terminal_get_focus ().get_working_dir ();
        var terminal = new Gemini.Terminal (working_dir);
        terminal.key_press_event += key_press_event_cb;
        terminal.child_exited += terminal_child_exited_cb;
        terminal.focus_in_event += terminal_focus_in_event_cb;
        freighter.terminal_add (terminal);
        freighter.active_hauler.terminal_set_focus (terminal);
      }
    }

    bool terminal_focus_in_event_cb (Gemini.Terminal terminal, Gdk.EventFocus focus) {
      lock (freighter) {
        freighter.active_hauler.terminal_set_focus (terminal);
      }
      return false;
    }

    void terminal_child_exited_cb (Gemini.Terminal terminal) {
      lock (freighter) {
        freighter.terminal_remove (terminal);
      }
    }

    void hauler_show (uint position) {
      lock (freighter) {
        if (freighter.size >= position) {
          freighter.hauler_show (freighter.hauler_get (position));
        }
      }
    }

    void hauler_change_cb (Gemini.Freighter f) {
      lock (freighter) {
        if (freighter.active_hauler == null) {
          all_terminals_exited_cb (f);
        } else if (freighter.active_hauler.layout != layout) {
          if (layout != null) {
            remove (layout);
          }
          layout = freighter.active_hauler.layout;
          add (layout);
        }
      }
    }

    bool key_press_event_cb (Gemini.Terminal terminal, Gdk.EventKey event_key) {
      bool valid = true;
      if ((event_key.state & Gdk.ModifierType.MOD1_MASK) == Gdk.ModifierType.MOD1_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "Return":
            lock (freighter) {
              freighter.active_hauler.terminal_focus_up ();
            }
            break;
          case "h":
            lock (freighter) {
              freighter.active_hauler.layout.width_change (5);
            }
            break;
          case "l":
            lock (freighter) {
              freighter.active_hauler.layout.width_change (-5);
            }
            break;
          default:
            valid = false;
            break;
        }
      } else if ((event_key.state & Gdk.ModifierType.MOD4_MASK) == Gdk.ModifierType.MOD4_MASK)
      {
        string name = Gdk.keyval_name (event_key.keyval);
        switch (name) {
          case "o":
            terminal_new ();
            break;
          case "x":
            lock (freighter) {
              freighter.terminal_close (freighter.active_hauler.terminal_get_focus ());
            }
            break;
          case "Return":
            lock (freighter) {
              if (freighter.active_hauler.size > 1) {
                var t1 = freighter.active_hauler.terminals.get (0);
                var t2 = freighter.active_hauler.terminals.get (1);
                var active = freighter.active_hauler.terminal_get_focus ();

                if (t1 == active)
                  freighter.active_hauler.terminal_zoom (t2);
                else
                  freighter.active_hauler.terminal_zoom (active);
              }
            }
            break;
          case "k":
            lock (freighter) {
              freighter.active_hauler.terminal_focus_up ();
            }
            break;
          case "j":
            lock (freighter) {
              freighter.active_hauler.terminal_focus_down ();
            }
            break;
          case "h":
            lock (freighter) {
              freighter.active_hauler.terminal_focus_left ();
            }
            break;
          case "l":
            lock (freighter) {
              freighter.active_hauler.terminal_focus_right ();
            }
            break;
          case "c":
            lock (freighter) {
              var new_hauler = freighter.active_hauler.copy ();
              freighter.hauler_add (new_hauler);
              freighter.hauler_show (new_hauler);
            }
            break;
          case "n":
            lock (freighter) {
              var new_hauler = new Gemini.Hauler (typeof (Gemini.TileLayout));
              freighter.hauler_add (new_hauler);
              freighter.hauler_show (new_hauler);
              terminal_new ();
            }
            break;
          case "1":
            hauler_show (0);
            break;
          case "2":
            hauler_show (1);
            break;
          case "3":
            hauler_show (2);
            break;
          case "4":
            hauler_show (3);
            break;
          case "5":
            hauler_show (4);
            break;
          case "6":
            hauler_show (5);
            break;
          case "7":
            hauler_show (6);
            break;
          case "8":
            hauler_show (7);
            break;
          case "9":
            hauler_show (8);
            break;
            /*case "l":*/
            /*layout.virt_terminal_resize (terminal, 30, 0);*/
            /*break;*/
            /*case "h":*/
            /*layout.virt_terminal_resize (terminal, -30, 0);*/
            /*break;*/
            /*case "j":*/
            /*layout.virt_terminal_resize (terminal, 0, -30);*/
            /*break;*/
            /*case "k":*/
            /*layout.virt_terminal_resize (terminal, 0, 30);*/
            /*break;*/
            /*case "f":*/
            /*change_layout (typeof (FullscreenLayout));*/
            /*layout.virt_terminal_focus (terminal);*/
            /*break;*/
            /*case "space":*/
            /*change_layout (typeof (TileLayout));*/
            /*layout.virt_terminal_focus (terminal);*/
            /*break;*/
            /*case "b":*/
            /*layout.terminal_focus_back ();*/
            /*break;*/
          default:
            valid = false;
            break;
        }
      } else
        valid = false;
      return valid;
    }
  }

  public static void main (string[] args) {
    Gtk.init (ref args);
    var gemini = new Gemini.GeminiTile ();
    Gtk.main ();
  }
}
