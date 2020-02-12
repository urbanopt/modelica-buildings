﻿within Buildings.Applications.DHC.Loads.BaseClasses;
model SimpleRoomODE
  "Simplified first order ODE model for computing indoor temperature"
  extends Modelica.Blocks.Icons.Block;
  parameter Modelica.SIunits.Temperature TOutHea_nominal(final displayUnit="degC")
    "Outdoor air temperature at heating nominal conditions"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.Temperature TIndHea_nominal(final displayUnit="degC")
    "Indoor air temperature at heating nominal conditions"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal(min=0)
    "Heating heat flow rate (for TInd=TIndHea_nominal, TOut=TOutHea_nominal,
    with no internal gains, no solar radiation)"
    annotation(Dialog(group = "Nominal condition"));
  parameter Boolean steadyStateInitial = false
    "true initializes T with dT(0)/dt=0, false initializes T with T(0)=TIndHea_nominal"
     annotation (Dialog(group="Initialization"), Evaluate=true);
  parameter Modelica.SIunits.Time tau = 1800
    "Time constant of the indoor temperature";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSet(
    final quantity="ThermodynamicTemperature",
    final unit="K", final displayUnit="degC")
    "Temperature set point for heating or cooling"
    annotation (Placement(transformation(extent={{-140,60},{-100,100}}),
      iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QReq_flow(
    final quantity="HeatFlowRate")
    "Required heat flow rate to meet temperature set point (>=0 for heating)"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}}),
      iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QAct_flow(
    final quantity="HeatFlowRate")
    "Actual heating or cooling heat flow rate (>=0 for heating)"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}}),
      iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAir(
    final quantity="ThermodynamicTemperature",
    final unit="K", final displayUnit="degC")
    "Room air temperature"
    annotation (Placement(transformation(extent={{100,-20},{140,20}})));
protected
  parameter Modelica.SIunits.ThermalConductance G=
    -QHea_flow_nominal / (TOutHea_nominal - TIndHea_nominal)
    "Lumped thermal conductance representing all temperature dependent heat transfer mechanisms";
initial equation
  if steadyStateInitial then
    der(TAir) = 0;
  else
    TAir = TIndHea_nominal;
  end if;
equation
  der(TAir) * tau = (QAct_flow - QReq_flow) / G + TSet -TAir;
  assert(TAir >= 273.15, "In " + getInstanceName() +
    ": The computed indoor temperature is below 0°C.");
  annotation (
  defaultComponentName="rooOde",
  Documentation(info="<html>
  <p>
  This is a first order ODE model for assessing the indoor temperature based on the difference between the 
  required and actual heating or cooling heat flow rate and a minimum set of parameters at nominal conditions.
  </p>
  <p>
  The lumped thermal conductance <i>G</i> representing all heat transfer mechanisms that depend on the 
  temperature difference with the outside (transmission, infiltration and ventilation) is assessed from
  the steady-state energy balance at heating nominal conditions:
  </p>
  <p align=\"center\" style=\"font-style:italic;\">
  0 = Q&#775;<sub>heating, nom</sub> + G * (T<sub>out, heating, nom</sub> - T<sub>ind, heating, nom</sub>)
  </p>
  <p>
  This coefficient is then considered constant for all operating conditions.
  </p>
  <p>
  The required heating or cooling heat flow rate <i>Q&#775;<sub>heat_cool, req</sub></i> corresponds to 
  a steady-state control error equal to zero:
  </p>
  <p align=\"center\" style=\"font-style:italic;\">
  0 = Q&#775;<sub>heat_cool, req</sub> +
  G * (T<sub>out</sub> - T<sub>ind, set</sub>) +
  Q&#775;<sub>various</sub>
  </p>
  <p>
  where <i>Q&#775;<sub>various</sub></i> represent the miscellaneous heat gains.
  The indoor temperature variation rate due to an unmet load is given by:
  </p>
  <p align=\"center\" style=\"font-style:italic;\">
  C * &part;T<sub>ind</sub> / &part;t = Q&#775;<sub>heat_cool, act</sub> +
  G * (T<sub>out</sub> - T<sub>ind</sub>) + Q&#775;<sub>various</sub>
  </p>
  <p>
  where
  <i>Q&#775;<sub>heat_cool, act</sub></i> is the actual heating or cooling heat flow rate and
  <i>C</i> (J/K) is the thermal capacitance of the indoor volume.
  The two previous equations lead to:
  </p>
  <p align=\"center\" style=\"font-style:italic;\">
  &tau; * &part;T<sub>ind</sub> / &part;t = (Q&#775;<sub>heat_cool, act</sub> - Q&#775;<sub>heat_cool, req</sub>) / G
  - T<sub>ind</sub> + T<sub>ind, set</sub>
  </p>
  <p>
  where <i>&tau; = C / G</i> (s) is the time constant of the indoor temperature.
  </p>
  </html>"),
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));
end SimpleRoomODE;