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
with ada.text_io;           use ada.text_io;
with interfaces.c;          use interfaces.c;
with interfaces.c.strings;  use interfaces.c.strings;
with fat.types;             use fat.types;

package fat.io is

   package byte_io is new modular_io (byte);

   type file_descriptor is new int;
   type pipe is array (0 .. 1) of int;

   type coprocess is record
      to_child        : file_descriptor;
      from_child      : file_descriptor;
      child_pid       : int;
      parent_to_child : pipe;
      child_to_parent : pipe;
   end record;

   pipe_error  : exception;
   dup2_error  : exception;
   execv_error : exception;
   read_error  : exception;

   function  create_coprocess (target_executable : in chars_ptr;
                               arguments         : in string_array) return coprocess;
   function  hex (input : in byte) return string;

   function  kill (target : in coprocess) return int;
   procedure kill (target : in coprocess);

   procedure put_hex (input : in byte);
   procedure put_hex (input     : in word;
                      seperator : in string := "");
   procedure put_hex (input     : in byte_array;
                      seperator : in string := " ");

   function  read_bytes (source            : coprocess;
                         max_bytes_to_read : integer) return byte_array;

   function  read_string (source            : coprocess;
                          max_bytes_to_read : integer) return string;

   procedure write (destination   : in  coprocess;
                    data          : in  byte_array;
                    result        : out long);
   procedure write (destination   : in  coprocess;
                    data          : in  string;
                    result        : out long);
end fat.io;
