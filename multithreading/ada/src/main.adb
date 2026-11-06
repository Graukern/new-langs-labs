with Ada.Command_Line;
with Ada.Text_IO;

procedure Main is
   Worker_Count : constant Positive := 4;
   type Number_Type is range -(2 ** 63) .. (2 ** 63) - 1;

   protected type Accumulator is
      procedure Add (Value : Number_Type);
      function Total return Number_Type;
   private
      Value : Number_Type := 0;
   end Accumulator;

   protected body Accumulator is
      procedure Add (Value : Number_Type) is
      begin
         Accumulator.Value := Accumulator.Value + Value;
      end Add;

      function Total return Number_Type is
      begin
         return Value;
      end Total;
   end Accumulator;

   task type Worker
     (First  : Positive;
      Last   : Positive;
      Result : access Accumulator);

   task body Worker is
      Partial : Number_Type := 0;
   begin
      for Number in First .. Last loop
         Partial := Partial + Number_Type (Number) * Number_Type (Number);
      end loop;

      Result.Add (Partial);
   end Worker;

   Limit : Positive := 100;
   Shared_Result : aliased Accumulator;
begin
   if Ada.Command_Line.Argument_Count = 1 then
      Limit := Positive'Value (Ada.Command_Line.Argument (1));
   elsif Ada.Command_Line.Argument_Count > 1 then
      Ada.Text_IO.Put_Line ("Usage: main [positive-limit]");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   if Limit < Worker_Count then
      Ada.Text_IO.Put_Line ("The limit must be at least 4.");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   declare
      Chunk : constant Positive := Limit / Worker_Count;
      Worker_1 : Worker (1, Chunk, Shared_Result'Access);
      Worker_2 : Worker (Chunk + 1, 2 * Chunk, Shared_Result'Access);
      Worker_3 : Worker (2 * Chunk + 1, 3 * Chunk, Shared_Result'Access);
      Worker_4 : Worker (3 * Chunk + 1, Limit, Shared_Result'Access);
   begin
      null;
   end;

   Ada.Text_IO.Put_Line
     ("Sum of squares from 1 to" & Positive'Image (Limit) & ":"
      & Number_Type'Image (Shared_Result.Total));
end Main;
