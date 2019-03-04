within Buildings.Experimental.Templates.Commercial.VAV.AHUs.Data;
record CoolingCoil "Data record for cooling coil"
  extends Modelica.Icons.Record;

  parameter Modelica.SIunits.Temperature TAirIn_nominal=313.15
    "Nominal air inlet temperature"
    annotation(Dialog(group="Air"));
  parameter Modelica.SIunits.Temperature TAirOut_nominal=291.15
    "Nominal water outlet temperature"
    annotation(Dialog(group="Air"));
  parameter Modelica.SIunits.MassFraction X_vIn_nominal=0.00
    "Nominal air inlet absolute humidity"
    annotation(Dialog(group="Air"));
  parameter Modelica.SIunits.MassFraction X_vOut_nominal=0.00
    "Nominal water outlet absolute humidity"
    annotation(Dialog(group="Air"));

  parameter Modelica.SIunits.Temperature TWatIn_nominal=281.65
    "Nominal air inlet temperature cooling coil"
   annotation(Dialog(group="Water"));

  parameter Modelica.SIunits.MassFlowRate mWat_flow_nominal
    "Nominal water mass flow rate"
      annotation(Dialog(group="Hydraulics"));
  parameter Modelica.SIunits.PressureDifference dpWat_nominal(
    min=0,
    displayUnit="Pa") = 3000
    "Water-side pressure drop"
    annotation(Dialog(group="Hydraulics"));

  parameter Modelica.SIunits.PressureDifference dpAir_nominal(
    min=0,
    displayUnit="Pa") = 200
    "Air-side pressure drop"
    annotation(Dialog(group="Hydraulics"));
  annotation (
    defaultComponentPrefixes = "parameter",
    defaultComponentName = "datCooCoi",
  Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>
Data record for cooling coil.
</p>
</html>", revisions="<html>
<ul>
<li>
March 4, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end CoolingCoil;
