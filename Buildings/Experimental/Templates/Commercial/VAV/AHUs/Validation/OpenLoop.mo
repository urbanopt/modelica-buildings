within Buildings.Experimental.Templates.Commercial.VAV.AHUs.Validation;
model OpenLoop "Open loop test for air handler unit"
  extends Modelica.Icons.Example;
  CoolingCoilHeatingCoilEconomizerNoReturnFan ahu
    annotation (Placement(transformation(extent={{-40,-40},{40,40}})));
  Fluid.Sources.Boundary_pT out(nPorts=2) "Outside conditions"
    annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
equation
  connect(out.ports[1], ahu.port_freAir) annotation (Line(points={{-70,2},{-56,
          2},{-56,4},{-40,4}}, color={0,127,255}));
  connect(out.ports[2], ahu.port_exhAir) annotation (Line(points={{-70,-2},{-56,
          -2},{-56,-4},{-40,-4}}, color={0,127,255}));
end OpenLoop;
