pragma Ada_2005;
with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with System;

package posix_unistd is

   stdin  : constant int := 0;
   stdout : constant int := 1;
   stderr : constant int := 2;

   subtype size_t is unsigned_long;
   subtype ssize_t is long;

   procedure close (uu_fd : int);
   pragma Import (C, close, "close");

   function read (uu_fd     : int;
                  uu_buf    : System.Address;
                  uu_nbytes : size_t) return ssize_t;
   pragma Import (C, read, "read");

   function write (uu_fd  : int;
                   uu_buf : System.Address;
                   uu_n   : size_t) return ssize_t;
   pragma Import (C, write, "write");

   function pipe (uu_pipedes : System.Address) return int;
   pragma Import (C, pipe, "pipe");

   function dup2 (uu_fd : int;
                  uu_fd2 : int) return int;
   pragma Import (C, dup2, "dup2");

   type string_array is array(natural range <>) of Interfaces.C.Strings.chars_ptr;

   function execv (uu_path : Interfaces.C.Strings.chars_ptr;
                   uu_argv : string_array) return int;
   pragma Import (C, execv, "execv");

   function fork return int;
   pragma Import (C, fork, "fork");

end posix_unistd;
