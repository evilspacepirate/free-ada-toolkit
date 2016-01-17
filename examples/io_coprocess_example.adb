--
--  Copyright (c) 2016, John Leimon
--
--  Permission to use, copy, modify, and/or distribute this
--  software for any purpose with or without fee is hereby
--  granted, provided that the above copyright notice and
--  this permission notice appear in all copies.
--
--  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
--  ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
--  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
--  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
--  INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
--  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
--  WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
--  TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
--  USE OR PERFORMANCE OF THIS SOFTWARE.
--
with ada.text_io;          use ada.text_io;
with interfaces.c.strings; use interfaces.c.strings;
with fat.types;            use fat.types;
with fat.io;               use fat.io;

procedure io_coprocess_example is
   echo      : coprocess;
   arguments : string_array(0 .. 0) := (0 => new_string("Hello World!"));

begin

   echo := create_coprocess(new_string("/bin/echo"), arguments);

   loop
     declare
        coprocess_output : string := echo.read_string(1024);
     begin
        if coprocess_output'length > 0 then
           put(coprocess_output);
        else
           exit;
        end if;
     end;
   end loop;

   echo.kill;

end io_coprocess_example;
