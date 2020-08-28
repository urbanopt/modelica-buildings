within Buildings.Fluid.Boilers;
model SteamBoilerTwoPort
  "Steam boiler model with two ports for water flow with phase change"
  extends Buildings.Fluid.Interfaces.PartialTwoPortTwoMedium;
  extends Buildings.Fluid.Boilers.BaseClasses.PartialSteamBoiler(eva(
        m_flow_nominal=m_flow_nominal, pSte_nominal=pBoi_nominal));

equation
  connect(temSen_out.port_b, port_b) annotation (Line(points={{90,0},{90,0},{90,
          0},{100,0}}, color={0,127,255}));
  connect(port_a, senMasFlo.port_a)
    annotation (Line(points={{-100,0},{-90,0},{-90,0},{-80,0}},
                                                color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics={
        Rectangle(
          extent={{-101,5},{-40,-4}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{40,-4},{100,5}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid)}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}})));
end SteamBoilerTwoPort;
