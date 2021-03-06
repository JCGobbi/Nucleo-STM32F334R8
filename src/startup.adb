with Ada.Real_Time; use Ada.Real_Time;

with STM_Board;     use STM_Board;
with Inverter_ADC;  use Inverter_ADC;
with Inverter_PWM;  use Inverter_PWM;

package body Startup is

   --  procedure Wait_Until_V_Battery;
   --  Wait until battery voltage is between minimum and maximum.
   --  Enable this routine only when the hardware is connected.

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      --  Initialize GPIO ports
      Initialize_GPIO;

      --  Select the AC frequency of the inverter
      if Read_Input (AC_Frequency_Pin) then -- 50 Hz
         PWM_Frequency_Hz := 25_000.0;
      else -- 60 Hz
         PWM_Frequency_Hz := 30_000.0;
      end if;

      --  Select gain = 1.0 to see only sine table sinusoid
      Set_Sine_Gain (1.0);

      --  Initialize sensors ADC
      Initialize_ADC;

      --  Do not start while the battery voltage is outside maximum and minimum
      --  Wait_Until_V_Battery;

      --  Disable PWM gate drivers because some gate drivers enable with
      --  low level.
      Set_PWM_Gate_Power (False);

      --  Initialize PWM generator
      Initialize_PWM (Frequency => PWM_Frequency_Hz,
                      Deadtime  => PWM_Deadtime,
                      Alignment => Center);

      Initialized :=
         STM_Board.Is_Initialized and
         Inverter_ADC.Is_Initialized and
         Inverter_PWM.Is_Initialized;

   end Initialize;

   --------------------
   -- Start_Inverter --
   --------------------

   procedure Start_Inverter is
   begin
      --  Test if all peripherals are correctly initialized
      while not Initialized  loop
         Set_Toggle (Green_LED);
         delay until Clock + Milliseconds (1);  -- arbitrary
      end loop;

      --  Enable PWM gate drivers
      Inverter_PWM.Set_PWM_Gate_Power (True);

      --  Start generating the sinusoid
      Inverter_PWM.Start_PWM;

   end Start_Inverter;

   --------------------------
   -- Wait_Until_V_Battery --
   --------------------------

   --  procedure Wait_Until_V_Battery is
   --     Period : constant Time_Span := Milliseconds (1);
   --     Next_Release : Time := Clock;
   --     Counter : Integer := 0;
   --  begin
   --     loop
   --        exit when Test_V_Battery;
   --        Next_Release := Next_Release + Period;
   --        delay until Next_Release;
   --        Counter := Counter + 1;
   --        if (Counter > 1_000) then
   --           Set_Toggle (Red_LED);
   --           Counter := 0;
   --        end if;
   --     end loop;
   --     Turn_Off (Red_LED);
   --  end Wait_Until_V_Battery;

   --------------------
   -- Is_Initialized --
   --------------------

   function Is_Initialized return Boolean is
   begin
      return Initialized;
   end Is_Initialized;

end Startup;
