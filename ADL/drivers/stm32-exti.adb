------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2015, AdaCore                           --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of STMicroelectronics nor the names of its       --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
--                                                                          --
--  This file is based on:                                                  --
--                                                                          --
--   @file    stm32f407xx.h   et al.                                        --
--   @author  MCD Application Team                                          --
--   @version V1.1.0                                                        --
--   @date    19-June-2014                                                  --
--   @brief   CMSIS STM32F407xx Device Peripheral Access Layer Header File. --
--                                                                          --
--   COPYRIGHT(c) 2014 STMicroelectronics                                   --
------------------------------------------------------------------------------

--  This file provides register definitions for the STM32F4 (ARM Cortex M4F)
--  microcontrollers from ST Microelectronics.

with STM32_SVD.EXTI; use STM32_SVD.EXTI;

package body STM32.EXTI is

   -------------------------------
   -- Enable_External_Interrupt --
   -------------------------------

   procedure Enable_External_Interrupt
     (Line    : External_Line_Number;
      Trigger : Interrupt_Triggers)
   is
      Index : constant Natural := External_Line_Number'Enum_Rep (Line);
   begin
      case Index is
         when 0 .. 17 =>
            EXTI_Periph.IMR1.MR.Arr (Index) := True;
            EXTI_Periph.RTSR1.TR.Arr (Index) :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR.Arr (Index) :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 19 .. 20 =>
            EXTI_Periph.IMR1.MR_1.Arr (Index) := True;
            EXTI_Periph.RTSR1.TR_1.Arr (Index) :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR_1.Arr (Index) :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 22 =>
            EXTI_Periph.IMR1.MR_2.Arr (Index) := True;
            EXTI_Periph.RTSR1.TR22 :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR22 :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 23 =>
            EXTI_Periph.IMR1.MR_2.Arr (Index) := True;
         when 25 =>
            EXTI_Periph.IMR1.MR25 := True;
         when 30 =>
            EXTI_Periph.IMR1.MR30 := True;
            EXTI_Periph.RTSR1.TR30 :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR30 :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 32 =>
            EXTI_Periph.IMR2.MR32 := True;
            EXTI_Periph.RTSR2.TR32 :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR2.TR32 :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when others =>
            null;
      end case;
   end Enable_External_Interrupt;

   --------------------------------
   -- Disable_External_Interrupt --
   --------------------------------

   procedure Disable_External_Interrupt (Line : External_Line_Number) is
      Index : constant Natural := External_Line_Number'Enum_Rep (Line);
   begin
      case Index is
         when 0 .. 17 =>
            EXTI_Periph.IMR1.MR.Arr (Index) := False;
            EXTI_Periph.RTSR1.TR.Arr (Index) := False;
            EXTI_Periph.FTSR1.TR.Arr (Index) := False;
         when 19 .. 20 =>
            EXTI_Periph.IMR1.MR_1.Arr (Index) := False;
            EXTI_Periph.RTSR1.TR_1.Arr (Index) := False;
            EXTI_Periph.FTSR1.TR_1.Arr (Index) := False;
         when 22 =>
            EXTI_Periph.IMR1.MR_2.Arr (Index) := False;
            EXTI_Periph.RTSR1.TR22 := False;
            EXTI_Periph.FTSR1.TR22 := False;
         when 23 =>
            EXTI_Periph.IMR1.MR_2.Arr (Index) := False;
         when 25 =>
            EXTI_Periph.IMR1.MR25 := False;
         when 30 =>
            EXTI_Periph.IMR1.MR30 := False;
            EXTI_Periph.RTSR1.TR30 := False;
            EXTI_Periph.FTSR1.TR30 := False;
         when 32 =>
            EXTI_Periph.IMR2.MR32 := False;
            EXTI_Periph.RTSR2.TR32 := False;
            EXTI_Periph.FTSR2.TR32 := False;
         when others =>
            null;
      end case;
   end Disable_External_Interrupt;

   ---------------------------
   -- Enable_External_Event --
   ---------------------------

   procedure Enable_External_Event
     (Line    : External_Line_Number;
      Trigger : Event_Triggers)
   is
      Index : constant Natural := External_Line_Number'Enum_Rep (Line);
   begin
      case Index is
         when 0 .. 17 =>
            EXTI_Periph.EMR1.MR.Arr (Index) := True;
            EXTI_Periph.RTSR1.TR.Arr (Index) :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR.Arr (Index) :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 19 .. 20 =>
            EXTI_Periph.EMR1.MR_1.Arr (Index) := True;
            EXTI_Periph.RTSR1.TR_1.Arr (Index) :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR_1.Arr (Index) :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 22 =>
            EXTI_Periph.EMR1.MR_2.Arr (Index) := True;
            EXTI_Periph.RTSR1.TR22 :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR22 :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 23 =>
            EXTI_Periph.EMR1.MR_2.Arr (Index) := True;
         when 25 =>
            EXTI_Periph.EMR1.MR25 := True;
         when 30 =>
            EXTI_Periph.EMR1.MR30 := True;
            EXTI_Periph.RTSR1.TR30 :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR1.TR30 :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when 32 =>
            EXTI_Periph.EMR2.MR32 := True;
            EXTI_Periph.RTSR2.TR32 :=
              Trigger in Interrupt_Rising_Edge  | Interrupt_Rising_Falling_Edge;
            EXTI_Periph.FTSR2.TR32 :=
              Trigger in Interrupt_Falling_Edge | Interrupt_Rising_Falling_Edge;
         when others =>
            null;
      end case;
   end Enable_External_Event;

   ----------------------------
   -- Disable_External_Event --
   ----------------------------

   procedure Disable_External_Event (Line : External_Line_Number) is
      Index : constant Natural := External_Line_Number'Enum_Rep (Line);
   begin
      case Index is
         when 0 .. 17 =>
            EXTI_Periph.EMR1.MR.Arr (Index) := False;
            EXTI_Periph.RTSR1.TR.Arr (Index) := False;
            EXTI_Periph.FTSR1.TR.Arr (Index) := False;
         when 19 .. 20 =>
            EXTI_Periph.EMR1.MR_1.Arr (Index) := False;
            EXTI_Periph.RTSR1.TR_1.Arr (Index) := False;
            EXTI_Periph.FTSR1.TR_1.Arr (Index) := False;
         when 22 =>
            EXTI_Periph.EMR1.MR_2.Arr (Index) := False;
            EXTI_Periph.RTSR1.TR22 := False;
            EXTI_Periph.FTSR1.TR22 := False;
         when 23 =>
            EXTI_Periph.EMR1.MR_2.Arr (Index) := False;
         when 25 =>
            EXTI_Periph.EMR1.MR25 := False;
         when 30 =>
            EXTI_Periph.EMR1.MR30 := False;
            EXTI_Periph.RTSR1.TR30 := False;
            EXTI_Periph.FTSR1.TR30 := False;
         when 32 =>
            EXTI_Periph.EMR2.MR32 := False;
            EXTI_Periph.RTSR2.TR32 := False;
            EXTI_Periph.FTSR2.TR32 := False;
         when others =>
            null;
      end case;
   end Disable_External_Event;

   ------------------
   -- Generate_SWI --
   ------------------

   procedure Generate_SWI (Line : External_Line_Number) is
      Index : constant Natural := External_Line_Number'Enum_Rep (Line);
   begin
      case Index is
         when 0 .. 17 =>
            EXTI_Periph.SWIER1.SWIER.Arr (Index) := True;
         when 19 .. 20 =>
            EXTI_Periph.SWIER1.SWIER_1.Arr (Index) := True;
         when 22 =>
            EXTI_Periph.SWIER1.SWIER22 := True;
         when 30 =>
            EXTI_Periph.SWIER1.SWIER30 := True;
         when 32 =>
            EXTI_Periph.SWIER2.SWIER32 := True;
         when others =>
            null;
      end case;
   end Generate_SWI;

   --------------------------------
   -- External_Interrupt_Pending --
   --------------------------------

   function External_Interrupt_Pending (Line : External_Line_Number)
     return Boolean
   is
      Index : constant Natural := External_Line_Number'Enum_Rep (Line);
   begin
      case Index is
         when 0 .. 17 =>
            return EXTI_Periph.PR1.PR.Arr (Index);
         when 19 .. 20 =>
            return EXTI_Periph.PR1.PR_1.Arr (Index);
         when 22 =>
            return EXTI_Periph.PR1.PR22;
         when 30 =>
            return EXTI_Periph.PR1.PR30;
         when 32 =>
            return EXTI_Periph.PR2.PR32;
         when others =>
            return False;
      end case;
   end External_Interrupt_Pending;

   ------------------------------
   -- Clear_External_Interrupt --
   ------------------------------

   procedure Clear_External_Interrupt (Line : External_Line_Number) is
      --  yes, one to clear
      Index : constant Natural := External_Line_Number'Enum_Rep (Line);
   begin
      case Index is
         when 0 .. 17 =>
            EXTI_Periph.PR1.PR.Arr (Index) := True;
         when 19 .. 20 =>
            EXTI_Periph.PR1.PR_1.Arr (Index) := True;
         when 22 =>
            EXTI_Periph.PR1.PR22 := True;
         when 30 =>
            EXTI_Periph.PR1.PR30 := True;
         when 32 =>
            EXTI_Periph.PR2.PR32 := True;
         when others =>
            null;
      end case;
   end Clear_External_Interrupt;

end STM32.EXTI;
