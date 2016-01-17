pragma Ada_2005;
with interfaces.c; use interfaces.c;

package POSIX_signal is

   SIGHUP   : constant int :=  1;
   SIGINT   : constant int :=  2;
   SIGQUIT  : constant int :=  3;
   SIGILL   : constant int :=  4;
   SIGABRT  : constant int :=  6;
   SIGFPE   : constant int :=  8;
   SIGKILL  : constant int :=  9;
   SIGSEGV  : constant int := 11;
   SIGPIPE  : constant int := 13;
   SIGALRM  : constant int := 14;
   SIGTERM  : constant int := 15;

   function kill (uu_pid : int; uu_sig : int) return int;  -- /usr/include/signal.h:127
   pragma Import (C, kill, "kill");

end POSIX_signal;
