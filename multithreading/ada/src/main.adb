with Ada.Command_Line;
with Ada.IO_Exceptions;
with Ada.Text_IO;

procedure Main is
   use Ada.Command_Line;
   use Ada.Text_IO;

   type Integer_List is array (Positive range <>) of Integer;

   procedure Read_Values (Line : String; Values : out Integer_List) is
      Position : Positive := Line'First;

      procedure Skip_Whitespace is
      begin
         while Position <= Line'Last
           and then Line (Position) in ' ' | ASCII.HT | ASCII.CR
         loop
            Position := Position + 1;
         end loop;
      end Skip_Whitespace;
   begin
      for Index in Values'Range loop
         Skip_Whitespace;
         declare
            First : constant Positive := Position;
         begin
            while Position <= Line'Last
              and then Line (Position) not in ' ' | ASCII.HT | ASCII.CR
            loop
               Position := Position + 1;
            end loop;
            Values (Index) := Integer'Value (Line (First .. Position - 1));
         end;
      end loop;

      Skip_Whitespace;
      if Position <= Line'Last then
         raise Ada.IO_Exceptions.Data_Error;
      end if;
   end Read_Values;

   Input : File_Type;
   Header : Integer_List (1 .. 1);
begin
   if Argument_Count /= 1 then
      Put_Line (Standard_Error, "Использование: main ФАЙЛ");
      Set_Exit_Status (Failure);
      return;
   end if;

   Open (Input, In_File, Argument (1));
   Read_Values (Get_Line (Input), Header);

   declare
      N : constant Positive := Header (1);
      subtype Row is Integer_List (1 .. N);
      type Matrix is array (Positive range 1 .. N) of Row;
      Grid : Matrix;
      Rows_Valid, Columns_Valid : Boolean := False;

      function Check_Sequences (By_Column : Boolean) return Boolean is
      begin
         for Outer in 1 .. N loop
            declare
               Seen : array (1 .. N) of Boolean := (others => False);
            begin
               for Inner in 1 .. N loop
                  declare
                     Value : constant Integer :=
                       (if By_Column then Grid (Inner) (Outer)
                        else Grid (Outer) (Inner));
                  begin
                     if Value not in 1 .. N or else Seen (Value) then
                        return False;
                     end if;
                     Seen (Value) := True;
                  end;
               end loop;
            end;
         end loop;
         return True;
      end Check_Sequences;
   begin
      for Index in Grid'Range loop
         Read_Values (Get_Line (Input), Grid (Index));
      end loop;
      while not End_Of_File (Input) loop
         declare
            Empty_Row : Integer_List (1 .. 0);
         begin
            Read_Values (Get_Line (Input), Empty_Row);
         end;
      end loop;
      Close (Input);

      declare
         task Check_Rows;
         task Check_Columns;

         task body Check_Rows is
         begin
            Rows_Valid := Check_Sequences (By_Column => False);
         end Check_Rows;

         task body Check_Columns is
         begin
            Columns_Valid := Check_Sequences (By_Column => True);
         end Check_Columns;
      begin
         null;
      end;

      if Rows_Valid and Columns_Valid then
         Put_Line ("Матрица является латинским квадратом.");
      else
         Put_Line ("Матрица не является латинским квадратом.");
      end if;
   end;
exception
   when Ada.IO_Exceptions.Name_Error | Ada.IO_Exceptions.Use_Error =>
      Put_Line (Standard_Error, "Не удалось открыть входной файл.");
      Set_Exit_Status (Failure);
   when Ada.IO_Exceptions.End_Error | Ada.IO_Exceptions.Data_Error |
        Constraint_Error =>
      if Is_Open (Input) then
         Close (Input);
      end if;
      Put_Line (Standard_Error, "Ожидалось N и ровно N строк по N целых чисел.");
      Set_Exit_Status (Failure);
end Main;
