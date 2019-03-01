within Buildings.Examples.VAVReheat.BaseClasses;
connector ControlInput "Input connector for control signal"
  extends RealInput(
    min=0,
    max=1,
    unit="1");
end ControlInput;
