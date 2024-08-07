------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                         S Y S T E M . M E M O R Y                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--           Copyright (C) 2013-2022, Free Software Foundation, Inc.        --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  Simple implementation for use with Ravenscar Minimal. This implementation
--  is based on a simple static buffer (whose bounds are defined in the linker
--  script), and allocation is performed through a protected object to
--  protect against concurrency.

pragma Restrictions (No_Elaboration_Code);
--  This unit may be linked without being with'ed, so we need to ensure
--  there is no elaboration code (since this code might not be executed).

with System.Atomic_Primitives; use System.Atomic_Primitives;
with System.Storage_Elements;

package body System.Memory is
   use System.Storage_Elements;

   Heap_Start : Character;
   for Heap_Start'Alignment use Standard'Maximum_Alignment;
   pragma Import (C, Heap_Start, "__heap_start");
   --  The address of the variable is the start of the heap

   Heap_End : Character;
   pragma Import (C, Heap_End, "__heap_end");
   --  The address of the variable is the end of the heap

   Top : aliased Address := Heap_Start'Address;
   --  First not used address (always aligned to the maximum alignment).

   -----------
   -- Alloc --
   -----------

   function Alloc (Size : size_t) return System.Address
   is
      function Atomic_Compare_Exchange
        (Ptr           : Address;
         Expected      : Address;
         Desired       : Integer_Address;
         Weak          : Boolean   := False;
         Success_Model : Mem_Model := Seq_Cst;
         Failure_Model : Mem_Model := Seq_Cst) return Boolean;
      pragma Import (Intrinsic, Atomic_Compare_Exchange,
                     "__atomic_compare_exchange_" &
                       (case System.Word_Size is
                          when 32 => "4",
                          when 64 => "8",
                          when others => "unexpected"));
      Max_Align : constant := Standard'Maximum_Alignment;
      Max_Size  : Storage_Count;
      Res       : Address;

   begin
      if Size = 0 then

         --  Change size from zero to non-zero. We still want a proper pointer
         --  for the zero case because pointers to zero length objects have to
         --  be distinct.

         Max_Size := Max_Align;

      else
         --  Detect overflow in the addition below. Note that we know that
         --  upper bound of size_t is bigger than the upper bound of
         --  Storage_Count.

         if Size > size_t (Storage_Count'Last - Max_Align) then
            raise Storage_Error;
         end if;

         --  Compute aligned size

         Max_Size :=
           ((Storage_Count (Size) + Max_Align - 1) / Max_Align) * Max_Align;
      end if;

      loop
         Res := Top;

         --  Detect too large allocation

         if Max_Size >= Storage_Count'(Heap_End'Address - Res) then
            raise Storage_Error;
         end if;

         --  Atomically update the top of the heap. Restart in case of
         --  failure (concurrent allocation).

         exit when Atomic_Compare_Exchange
           (Top'Address,
            Expected => Res'Address,
            Desired  => Integer_Address (Res + Max_Size));
      end loop;

      return Res;
   end Alloc;

   ----------
   -- Free --
   ----------

   procedure Free (Ptr : System.Address) is
      pragma Unreferenced (Ptr);
   begin
      null;
   end Free;

end System.Memory;
