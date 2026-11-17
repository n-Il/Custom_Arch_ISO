structure Main =
   struct
      fun dosomething i = print("hi")
   end

val _ = Main.dosomething (valOf (Int.fromString (hd (CommandLine.arguments ()))))
