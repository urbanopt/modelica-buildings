within Buildings.Applications.DHC.CentralPlants.Heating.Generation1.Subsystems;
model BoilerSubsystem
  "Boiler subsystem containing parallel boilers and economizers"
  extends Buildings.Fluid.Interfaces.PartialTwoPortInterface;

  replaceable parameter Buildings.Fluid.Movers.Data.Generic perFan
    constrainedby Buildings.Fluid.Movers.Data.Generic
    "Performance data of fan"
    annotation (Dialog(group="Fan"),choicesAllMatching=true,
      Placement(transformation(extent={{-78,62},{-62,78}})));

  Fluid.Boilers.SteamBoilerFourPort boi[num]
    annotation (Placement(transformation(extent={{20,-12},{40,10}})));
  Fluid.HeatExchangers.PlateHeatExchangerEffectivenessNTU hex[num]
    annotation (Placement(transformation(extent={{-20,-16},{0,4}})));
  Fluid.Sources.Boundary_pT airSou "Air source"
    annotation (Placement(transformation(extent={{80,-60},{60,-40}})));
  Fluid.Sources.Boundary_pT airSin "Air sink"
    annotation (Placement(transformation(extent={{-90,-60},{-70,-40}})));
  Fluid.Movers.SpeedControlled_y fan[num]
    annotation (Placement(transformation(extent={{50,-60},{30,-40}})));
  Fluid.Actuators.Valves.TwoWayEqualPercentage val[num]
    annotation (Placement(transformation(extent={{-74,-10},{-54,10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort[num]
    "Heat port, can be used to connect to ambient"
    annotation (Placement(transformation(extent={{-10,90},{10,110}})));
  Modelica.Blocks.Interfaces.RealOutput EFue_flow[num](
    final quantity="EnergyFlowRate",
    final unit="W",
    displayUnit="kW") "Energy flow rate(s) of fuel to the boiler(s)"
    annotation (Placement(transformation(extent={{100,80},{120,100}}),
        iconTransformation(extent={{100,80},{120,100}})));
  Modelica.Blocks.Interfaces.RealOutput PFan_flow[num](
    final quantity="Power",
    final unit="W",
    displayUnit="kW") "Electric power of the fan(s)" annotation (Placement(
        transformation(extent={{100,50},{120,70}}), iconTransformation(extent={{
            100,50},{120,70}})));
equation
  connect(boi.heatPort, heatPort) annotation (Line(points={{30,10},{30,70},{0,70},
          {0,100}}, color={191,0,0}));
  connect(val.port_b, hex.port_a1) annotation (Line(points={{-54,0},{-38,0},{
          -38,0},{-20,0}}, color={0,127,255}));
  connect(hex.port_b1, boi.port_a1)
    annotation (Line(points={{0,0},{20,0}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-80,56},{80,44}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-80,-44},{80,-56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{8,80},{68,20}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
      Line(
        points={{64,78},{54,72},{64,64},{56,58}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
        Ellipse(
          extent={{26,60},{50,36}},
          fillColor={127,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
      Line(
        points={{56,78},{46,72},{56,64},{48,58}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
      Line(
        points={{30,78},{20,72},{30,64},{22,58}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
      Line(
        points={{22,78},{12,72},{22,64},{14,58}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
                              Rectangle(
          extent={{-68,80},{-8,20}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-62,74},{-56,24}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-56,74},{-48,24}},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-48,74},{-42,24}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-34,74},{-28,24}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-42,74},{-34,24}},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-28,74},{-20,24}},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-20,74},{-14,24}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{8,-20},{68,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
      Line(
        points={{64,-22},{54,-28},{64,-36},{56,-42}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
        Ellipse(
          extent={{26,-40},{50,-64}},
          fillColor={127,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
      Line(
        points={{56,-22},{46,-28},{56,-36},{48,-42}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
      Line(
        points={{30,-22},{20,-28},{30,-36},{22,-42}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
      Line(
        points={{22,-22},{12,-28},{22,-36},{14,-42}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
                              Rectangle(
          extent={{-68,-20},{-8,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-62,-26},{-56,-76}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-56,-26},{-48,-76}},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-48,-26},{-42,-76}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-34,-26},{-28,-76}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-42,-26},{-34,-76}},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-28,-26},{-20,-76}},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-20,-26},{-14,-76}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{80,6},{99,-5}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,6},{-80,-6}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{74,56},{86,-56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-86,56},{-74,-56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-149,-114},{151,-154}},
          lineColor={0,0,255},
          textString="%name"),
        Line(points={{10,100},{14,100},{36,100},{36,80}}, color={238,46,47}),
        Line(points={{0,40},{0,-10},{36,-10},{36,-20}}, color={238,46,47}),
        Line(points={{0,60},{0,76},{0,90}}, color={238,46,47})}),Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end BoilerSubsystem;
