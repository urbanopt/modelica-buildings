within Buildings.Fluid.HeatExchangers.DXCoils.Data.BaseClasses;
record Generic "Generic data record for DX coil"
  extends Modelica.Icons.Record;
  // fixme: check why spe is used. In particular the single speed coil should not
  // require this parameter
  parameter Modelica.SIunits.AngularVelocity spe(displayUnit="1/min")
    "Rotational speed";
  parameter
    Buildings.Fluid.HeatExchangers.DXCoils.Data.BaseClasses.NominalValues nomVal
    "Nominal values"
    annotation (Placement(transformation(extent={{60,60},{80,80}})));
  parameter
    Buildings.Fluid.HeatExchangers.DXCoils.Data.PerformanceCurves.BaseClasses.Generic
                                                                          perCur
    "Performance curves"
    annotation (choicesAllMatching = true, Placement(transformation(extent={{60,20},{80,40}})));
annotation (defaultComponentName="per",
              preferedView="info",
  Documentation(info="<html>
This is the base record for DX cooling coil model at a compressor speed. 
</html>",
revisions="<html>
<ul>
<li>
August 13, 2012 by Kaustubh Phalak:<br>
First implementation.
</li>
</ul>
</html>"));
end Generic;
