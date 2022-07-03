with HAL; use HAL;

package body Inverter_PWM is

   --------------------
   -- Initialize_PWM --
   --------------------

   procedure Initialize_PWM (Frequency : Frequency_Hz;
                             Deadtime  : Deadtime_Range;
                             Alignment : PWM_Alignment)
   is
      Counter_Mode : constant Timer_Counter_Alignment_Mode :=
         (case Alignment is
             when Edge   => Up,
             when Center => Center_Aligned2);
   begin
      Configure_PWM_Timer (Generator => PWM_Timer_Ref,
                           Frequency => UInt32 (Frequency));

      Set_Counter_Mode (This => PWM_Timer_Ref.all,
                        Value => Counter_Mode);

      Configure_Deadtime (This => PWM_Timer_Ref.all,
                          Time => Deadtime);

      Set_BDTR_Lock (This => PWM_Timer_Ref.all,
                     Lock => Level_1);

      for P in PWM_Phase'Range loop
         Modulators (P).Attach_PWM_Channel
           (Generator                => PWM_Timer_Ref,
            Channel                  => Gate_Phase_Settings (P).Channel,
            Point                    => Gate_Phase_Settings (P).Pin_H,
            Complementary_Point      => Gate_Phase_Settings (P).Pin_L,
            PWM_AF                   => Gate_Phase_Settings (P).Pin_AF,
            Polarity                 => High,
            Idle_State               => Disable,
            Complementary_Polarity   => High,
            Complementary_Idle_State => Disable);

         Set_Output_Preload_Enable
           (This    => PWM_Timer_Ref.all,
            Channel => Gate_Phase_Settings (P).Channel,
            Enabled => True);
      end loop;

      Initialized := True;
   end Initialize_PWM;

   ------------------
   -- Enable_Phase --
   ------------------

   procedure Enable_Phase (This : PWM_Phase) is
   begin
      Modulators (This).Enable_Output;
      Modulators (This).Enable_Complementary_Output;
   end Enable_Phase;

   -------------------
   -- Disable_Phase --
   -------------------

   procedure Disable_Phase (This : PWM_Phase) is
   begin
      Modulators (This).Disable_Output;
      Modulators (This).Disable_Complementary_Output;
   end Disable_Phase;

   ---------------
   -- Start_PWM --
   ---------------

   procedure Start_PWM is
   begin
      Reset_Sine_Step;
      for P in PWM_Phase'Range loop
         Set_Duty_Cycle (This  => P,
                         Value => 0.0);
         Enable_Phase (P);
      end loop;
      Enable_Interrupt (This   => PWM_Timer_Ref.all,
                        Source => Timer_Update_Interrupt);
   end Start_PWM;

   --------------
   -- Stop_PWM --
   --------------

   procedure Stop_PWM is
   begin
      Disable_Interrupt (This   => PWM_Timer_Ref.all,
                         Source => Timer_Update_Interrupt);
      for P in PWM_Phase'Range loop
         Disable_Phase (P);
         Set_Duty_Cycle (This  => P,
                         Value => 0.0);
      end loop;
      Reset_Sine_Step;
   end Stop_PWM;

   -------------------------
   -- Get_Duty_Resolution --
   -------------------------

   function Get_Duty_Resolution return Duty_Cycle is
   begin
      return Duty_Cycle (100.0 / Float (Current_Autoreload (PWM_Timer_Ref.all)));
   end Get_Duty_Resolution;

   --------------------
   -- Set_Duty_Cycle --
   --------------------

   procedure Set_Duty_Cycle (This  : PWM_Phase;
                             Value : Duty_Cycle)
   is
      Pulse : UInt16;
   begin
      Pulse := UInt16 (Value * Float (Current_Autoreload (PWM_Timer_Ref.all)) / 100.0);
      Set_Compare_Value
        (This    => PWM_Timer_Ref.all,
         Channel => Gate_Phase_Settings (This).Channel,
         Value   => Pulse);
   end Set_Duty_Cycle;

   --------------------
   -- Set_Duty_Cycle --
   --------------------

   procedure Set_Duty_Cycle (This      : PWM_Phase;
                             Amplitude : Table_Amplitude;
                             Gain      : Inverter_ADC.Gain_Range)
   is
      Pulse : UInt16;
   begin
      Pulse := UInt16 (Gain * Float (Amplitude) / Float (Table_Amplitude'Last) *
                       Float (Current_Autoreload (PWM_Timer_Ref.all)));
      Set_Compare_Value
        (This => PWM_Timer_Ref.all,
         Channel => Gate_Phase_Settings (This).Channel,
         Value => Pulse);
   end Set_Duty_Cycle;

   ------------------------
   -- Set_PWM_Gate_Power --
   ------------------------
   --  This depends on the driver electronic circuit. Actually it is
   --  programmed to turn ON the gates driver with a low level.

   procedure Set_PWM_Gate_Power (Enabled : in Boolean) is
   begin
      if Enabled then
         PWM_Gate_Power.Clear;
      else
         PWM_Gate_Power.Set;
      end if;
   end Set_PWM_Gate_Power;

   ---------------------
   -- Reset_Sine_Step --
   ---------------------

   procedure Reset_Sine_Step is
   begin
      Sine_Step := 250;
   end Reset_Sine_Step;

   ----------------
   -- Safe_State --
   ----------------

   procedure Safe_State is
   begin
      Set_PWM_Gate_Power (Enabled => False);
      Stop_PWM;
   end Safe_State;

   --------------------
   -- Is_Initialized --
   --------------------

   function Is_Initialized
      return Boolean is (Initialized);

   -----------------
   -- PWM_Handler --
   -----------------

   protected body PWM_Handler is

      ---------------------
      -- PWM_ISR_Handler --
      ---------------------

      procedure PWM_ISR_Handler is
      begin
         if Status (PWM_Timer, Timer_Update_Indicated) then
            if Interrupt_Enabled (PWM_Timer, Timer_Update_Interrupt) then
               Clear_Pending_Interrupt (PWM_Timer, Timer_Update_Interrupt);

               if (Semi_Senoid = False) then --  First half cycle
                  Set_Duty_Cycle (This      => A,
                                  Amplitude => Sine_Table (Sine_Step),
                                  Gain      => Inverter_ADC.Sine_Gain);
                  --  Not necessary because the last value of B amplitude was 0
                  --  Set_Duty_Cycle (This      => B,
                  --                  Amplitude => Table_Amplitude'Last, --  Value 0
                  --                  Gain      => Inverter_ADC.Gain_Range'First); --  Value 0
               else --  Second half cycle
                  Set_Duty_Cycle (This      => B,
                                  Amplitude => Sine_Table (Sine_Step),
                                  Gain      => Inverter_ADC.Sine_Gain);
                  --  Not necessary because the last value of A amplitude was 0
                  --  Set_Duty_Cycle (This      => A,
                  --                  Amplitude => Table_Amplitude'Last, --  Value 0
                  --                  Gain      => Inverter_ADC.Gain_Range'First); --  Value 0
               end if;

               if (Sine_Step + 1) > Sine_Step_Range'Last then
                  Sine_Step := 1;
                  Semi_Senoid := not Semi_Senoid;
               else
                  Sine_Step := Sine_Step + 1;
               end if;

               --  Testing the 30 kHz output with 1 Hz LED blinking.
               --  if Counter = 15_000 then
               --     Set_Toggle (Green_LED);
               --     Counter := 0;
               --  end if;
               --  Counter := Counter + 1;

            end if;
         end if;
      end PWM_ISR_Handler;

   end PWM_Handler;

end Inverter_PWM;
