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
with ada.text_io; use ada.text_io;
with fat.types;   use fat.types;
with fat.io;      use fat.io;

procedure io_put_example is
   A : byte := 16#2F#;
   B : word := 16#700F#;
   C : byte_array (1 .. 5) := ( 255, 254, 253, 252, 1 );
begin

   put("A = ");
   put_hex(A);
   put(" = ");
   put(hex(A));
   new_line;

   put("B = ");
   put_hex(B);
   new_line;

   put("C = ");
   put_hex(C);
   new_line;

end io_put_example;
