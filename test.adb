with raylib;
with raylib.UI;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Interfaces.C.Extensions;

procedure test is
   use raylib;
   use raylib.input;

   package FS renames Ada.Strings.Fixed;
   package TIO renames Ada.Text_IO;

   FPS : constant := 30;
   BOTTOM_MSG_CENTER, BOTTOM_MSG_Y : Float;
   BOTTOM_MSG_FONT_SIZE : constant int := 24;

   padding : constant int := 10;
   font_size : constant int := 18;

   type tests is (Lines, Perspective, GUI);
   current_test : tests := GUI;
   procedure select_next_test is
   begin
      current_test := (if current_test = tests'Last
                       then tests'First
                       else tests'Succ (current_test));
   end select_next_test;

   gui_ctrl_toggle : Boolean := False;
   gui_ctrl_checkbox : Boolean := True;
   gui_ctrl_textbox : Boolean := False;
   gui_value_textbox : String (1 .. 25);

   is_editing_text_area : Boolean := False;
   cursor_text_area : Vector2;
   buffer_text_area : String (1 .. 1024);

   use type raylib.UI.Control_State;
   use type Interfaces.C.Extensions.bool;

   function bottom_msg_text return String is
      ("Press [TAB] to change test - " & current_test'Img);
begin
   Ada.Strings.Fixed.Move ("Hello !", gui_value_textbox);

   raylib.window.init (800, 400, "raylib Ada binding - tests");

   raylib.window.set_target_FPS (FPS);
   --  raylib.window.hide_cursor;
   raylib.UI.set_alpha (0.90);

   BOTTOM_MSG_CENTER := Float(window.get_render_width)/2.0;
   BOTTOM_MSG_Y := Float(window.get_render_height) - 32.0;

   while not window.should_close loop

      if input.is_key_pressed (raylib.KEY_TAB) then
         select_next_test;
      end if;

      raylib.window.begin_drawing;
      raylib.window.clear_background (raylib.RAYWHITE);

      text.draw_pro (
         F        => text.get_font_default,
         text     => bottom_msg_text,
         position => Vector2'(BOTTOM_MSG_CENTER, BOTTOM_MSG_Y),
         origin   => (Float(text.measure (bottom_msg_text,BOTTOM_MSG_FONT_SIZE))/2.0, 0.0),
         rotation => 0.0,
         fontSize => Float(BOTTOM_MSG_FONT_SIZE),
         spacing  => 1.0,
         tint     => BROWN);

      case current_test is
      when Lines =>
         text.draw (
            "raylib.shapes.draw_line",
            padding,
             10,
             font_size,
             raylib.BLACK);
        
         shapes.draw_line (
            start_posX => padding,
            start_posY => 28,
            end_posX   => 300,
            end_posy   => 28,
            c => raylib.RED);
         --
         text.draw ("raylib.shapes.draw_line_v", padding, 38, font_size, BLACK);
         raylib.shapes.draw_line_v (
            start_pos => (Float (padding), 56.0),
            end_pos   => (300.0, 56.0),
            c => raylib.RED);

         --
         text.draw ("raylib.shapes.draw_line_ex", padding, 66, font_size, BLACK);
         raylib.shapes.draw_line_ex (
            start_pos => (Float (padding), 84.0),
            end_pos   => (300.0, 84.0),
            thick => 2.5,
            c => RED);
      
      when Perspective =>
         text.draw ("Perspective test not yet implemented", 1, 38, font_size, BLACK);
      when GUI =>
         if Boolean(is_key_pressed (raylib.KEY_D)) then
            if raylib.UI.get_state = raylib.UI.NORMAL
            then raylib.UI.set_state (raylib.UI.DISABLED);
            else raylib.UI.set_state (raylib.UI.NORMAL);
            end if;
         end if;

         declare
            --  type Cell is record
            --     bounds : Rectangle;
            --     pos   : Vector2;
            --     size  : Vector2;
            --  end record;
            --  Cells : array (1 .. 10) of Cell; 

            --
            Left_Align      : constant Float := 100.0;
            Vertical_Margin : constant Float := 4.0;
            Cell_Height     : constant Float := 32.0;
            Cell_Spacing    : constant Float := Cell_Height + Vertical_Margin;

            status_area : Rectangle := (0.0, 0.0, 800.0, 32.0);
            toggle_area    : Rectangle := (Left_Align, Cell_Spacing, 140.0, Cell_Height);
            button_area    : Rectangle := (Left_Align, Cell_Spacing * 2.0, 120.0, Cell_Height);
            checkbox_area  : Rectangle := (Left_Align, Cell_Spacing * 3.0, Cell_Height, Cell_Height);
            textbox_area   : Rectangle := (Left_Align, Cell_Spacing * 4.0, 80.0, Cell_Height);
            textarea_area  : Rectangle := (Left_Align, Cell_Spacing * 5.0, 200.0, Cell_Spacing * 5.0);
         begin 
            UI.statusbar (status_area, "UI test, press key 'D' to disable");
            UI.toggle (toggle_area, (if gui_ctrl_toggle then "Active button" else "Deacticated button"), gui_ctrl_toggle);
            UI.panel ((400.0, 48.0, 100.0, 36.0));
            if raylib.UI.button (button_area, "Next test")
         then select_next_test;
         end if;
            raylib.UI.checkbox (
               bounds  => checkbox_area,
                             text    => (if gui_ctrl_checkbox then "Checked" else "Unchecked"),
                             checked => gui_ctrl_checkbox);
            gui_ctrl_textbox := UI.textbox (textbox_area, gui_value_textbox, gui_ctrl_textbox);
            cursor_text_area := UI.textbox_multi (textarea_area, buffer_text_area, is_editing_text_area);
         end;
      end case;

      raylib.window.end_drawing;
   end loop;

   raylib.window.close;

end test;
