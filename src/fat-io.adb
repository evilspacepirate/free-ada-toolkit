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
with posix_signal;
with posix_unistd;
with interfaces;   use interfaces;

package body fat.io is

   package signal renames posix_signal;
   package unistd renames posix_unistd;

   -------------------------
   function create_coprocess
      (target_executable : in chars_ptr;
       arguments         : in string_array) return coprocess
   is
      pid    : int;
      output : coprocess;
   begin

      --    Parent                            Child (coprocess)
      --  ___________                            ___________
      --  |         |   Pipe: child_to_parent    |         |
      --  |         |<---------------------------| stdout  |
      --  |         |   Pipe: parent_to_child    |         |
      --  |         |--------------------------->| stdin   |
      --  |_________|                            |_________|

      -- Create two pipes for bidirectional communication
      -- between processes

      if unistd.pipe(output.parent_to_child'address) < 0 or
         unistd.pipe(output.child_to_parent'address) < 0 then
         raise pipe_error;
      end if;

      pid := unistd.fork;

      if pid > 0 then
        -- Setup coprocess interface as parent
        unistd.close(output.parent_to_child(0));
        unistd.close(output.child_to_parent(1));
        output.to_child   := file_descriptor(output.parent_to_child(1));
        output.from_child := file_descriptor(output.child_to_parent(0));
      else
        -- Setup coprocess interface as child
        unistd.close(output.parent_to_child(1));
        unistd.close(output.child_to_parent(0));

        -- Connect child stdin to 'parent_to_child' pipe
        if output.parent_to_child(0) /= unistd.stdin then
           if unistd.dup2(output.parent_to_child(0), unistd.stdin) = -1 then
              raise dup2_error;
           end if;
           unistd.close(output.parent_to_child(0));
        end if;

        -- Connect child stdout to parent process pipe --
        if output.child_to_parent(1) /= unistd.stdout then
           if unistd.dup2(output.child_to_parent(1), unistd.stdout) = -1 then
              raise dup2_error;
           end if;
           unistd.close(output.child_to_parent(1));
        end if;

        -- Replace the child process with the target executable
        declare
           exec_args : unistd.string_array (1 .. arguments'length + 2);
           result    : int;
        begin
           unistd.close(output.parent_to_child(1));
           unistd.close(output.child_to_parent(0));

           -- Connect child stdin to 'parent_to_child' pipe
           if output.parent_to_child(0) /= unistd.stdin then
              if unistd.dup2(output.parent_to_child(0), unistd.stdin) = -1 then
                 raise dup2_error;
              end if;
              unistd.close(output.parent_to_child(0));
           end if;

           -- Connect child stdout to 'child_to_parent' pipe
           if output.child_to_parent(1) /= unistd.stdout then
              if unistd.dup2(output.child_to_parent(1), unistd.stdout) = -1 then
                 raise dup2_error;
              end if;
              unistd.close(output.child_to_parent(1));
           end if;

           exec_args(exec_args'first) := target_executable;
           exec_args(exec_args'last)  := null_ptr;

           if arguments'length > 0 then
              for index in exec_args'first + 1 .. exec_args'last - 1 loop
                 exec_args(index) := arguments(arguments'first + index - exec_args'first - 1);
              end loop;
           end if;

           -- Process conversion to executable target
           result := unistd.execv(target_executable, exec_args);

           if result = -1 then
              raise execv_error;
           end if;
        end;
      end if;

      return output;
   end create_coprocess;

   ------------
   function hex
      (input : byte) return string
   is
      start  : integer;
      length : integer;
      buffer : string (1 .. 6);
      output : string (1 .. 2);
   begin
      byte_io.put(to   => buffer,
                  item => input,
                  base => 16);

      for index in 1 .. 6 loop
        if buffer(index) = '#' then
          start := index + 1;
          exit;
        end if;
      end loop;

      output := "00";
      length := 6 - start;
      output(3 - length .. 2) := buffer(6 - length .. 5);

      return output;
   end hex;

   --------------
   procedure kill
      (target : in coprocess)
   is
      dont_care : int;
   begin
      dont_care := signal.kill(target.child_pid,
                               signal.SIGINT);
   end kill;

   --------------
   function kill
      (target : in coprocess) return int
   is
   begin
      return signal.kill(target.child_pid,
                         signal.SIGINT);
   end kill;

   -----------------
   procedure put_hex
      (input : byte)
   is
      start  : integer;
      length : integer;
      buffer : string (1 .. 6);
      output : string (1 .. 2);
   begin
      byte_io.put(to   => buffer,
                  item => input,
                  base => 16);

      for index in 1 .. 6 loop
        if buffer(index) = '#' then
          start := index + 1;
          exit;
        end if;
      end loop;

      output := "00";
      length := 6 - start;
      output(3 - length .. 2) := buffer(6 - length .. 5);

      put(output);
   end put_hex;

   -----------------
   procedure put_hex
      (input     : word;
       seperator : string := "")
   is
   begin
      put_hex(byte(shift_right(unsigned_16(input), 8)));
      put(seperator);
      put_hex(byte(input and 16#FF#));
   end put_hex;

   -----------------
   procedure put_hex
      (input     : byte_array;
       seperator : string := " ")
   is
   begin
      for index in input'range loop
         put_hex(input(index));
         if index /= input'last then
            put(seperator);
         end if;
      end loop;
   end put_hex;

   -------------------
   function read_bytes
      (source            : coprocess;
       max_bytes_to_read : integer) return byte_array
   is
      bytes_read : long;
      output     : byte_array(1 .. max_bytes_to_read);
   begin bytes_read := unistd.read(int(source.from_child),
                                output'address,
                                unsigned_long(max_bytes_to_read));
      if bytes_read = -1 then
         raise read_error;
      end if;

      return output(1 .. integer(bytes_read));
   end read_bytes;

   --------------------
   function read_string
      (source            : coprocess;
       max_bytes_to_read : integer) return string
   is
      bytes_read : long;
      output     : string (1 .. max_bytes_to_read);
   begin
      bytes_read := unistd.read(int(source.from_child),
                                output'address,
                                unsigned_long(max_bytes_to_read));
      if bytes_read = -1 then
         raise read_error;
      end if;

      return output(1 .. integer(bytes_read));
   end read_string;

   ---------------
   procedure write
      (destination   : in  coprocess;
       data          : in  byte_array;
       result        : out long)
   is
   begin
      result := unistd.write(int(destination.to_child),
                             data'address,
                             data'length);
   end write;

   ---------------
   procedure write
      (destination   : in  coprocess;
       data          : in  string;
       result        : out long)
   is
   begin
      result := unistd.write(int(destination.to_child),
                             data'address,
                             data'length);
   end write;

end fat.io;
