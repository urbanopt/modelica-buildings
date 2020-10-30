within Buildings.Applications.DHC.CentralPlants.Heating.Generation1.Subsystems;
model BoilerSubsystem
  "Boiler subsystem containing parallel boilers and economizers"
  extends Buildings.Fluid.Interfaces.PartialTwoPortTwoMedium(
    redeclare replaceable package Medium_b =
      IBPSA.Media.Interfaces.PartialPureSubstanceWithSat);

  replaceable package MediumAir = Buildings.Media.Air "Air medium model";

  parameter Integer num=2 "The number of boilers";

  parameter Modelica.SIunits.Power QBoi_flow_nominal
    "Nominal heating power of boiler"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.Power QHex_flow_nominal
    "Nominal heating power of economizer"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dpValve_nominal(displayUnit="Pa")
    "Pressure drop at nominal mass flow rate"
    annotation(Dialog(group = "Nominal condition"));

  replaceable parameter Buildings.Fluid.Movers.Data.Generic perFan
    constrainedby Buildings.Fluid.Movers.Data.Generic
    "Performance data of fan"
    annotation (Dialog(group="Fan"),choicesAllMatching=true,
      Placement(transformation(extent={{62,62},{78,78}})));

  Buildings.Fluid.Boilers.SteamBoilerFourPort boi[num](
    redeclare package MediumWat = Medium_a,
    redeclare package MediumSte = Medium_b,
    each Q_flow_nominal=QBoi_flow_nominal,
    each fue= Fluid.Data.Fuels.NaturalGasHigherHeatingValue(),
    redeclare package MediumAir = MediumAir)                      "Boiler"
    annotation (Placement(transformation(extent={{-10,-16},{10,4}})));
  Buildings.Fluid.HeatExchangers.PlateHeatExchangerEffectivenessNTU hex[num](
    redeclare package Medium1 = Medium_a,
    redeclare package Medium2 = MediumAir,
    each Q_flow_nominal=QHex_flow_nominal)  "Economizing heat exchanger"
    annotation (Placement(transformation(extent={{-40,-16},{-20,4}})));
  Buildings.Fluid.Sources.Boundary_pT airSou(redeclare package Medium = MediumAir,
                                   nPorts=1)  "Air source"
    annotation (Placement(transformation(extent={{80,-80},{60,-60}})));
  Buildings.Fluid.Sources.Boundary_pT airSin(redeclare package Medium = MediumAir,
                                   nPorts=1)  "Air sink"
    annotation (Placement(transformation(extent={{-90,-80},{-70,-60}})));
  Buildings.Fluid.Movers.SpeedControlled_y fan[num](redeclare package Medium = MediumAir,
      per=fill(perFan,num))                          "Fan"
    annotation (Placement(transformation(extent={{50,-80},{30,-60}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage val[num](redeclare
      package
      Medium = Medium_a,
    each dpValve_nominal=dpValve_nominal)  "Control valve"
    annotation (Placement(transformation(extent={{-70,-10},{-50,10}})));
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


  Modelica.Blocks.Interfaces.RealInput yFan[num](
    each final unit="1",
    each max=1,
    each min=0) "Continuous input signal for the fan" annotation (Placement(
        transformation(extent={{-140,60},{-100,100}}), iconTransformation(
          extent={{-140,60},{-100,100}})));
  Modelica.Blocks.Interfaces.RealInput yVal[num](
    each final unit="1",
    each max=1,
    each min=0) "Continuous input signal for the control valve" annotation (
      Placement(transformation(extent={{-140,20},{-100,60}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
equation
  for i in 1:num loop
    connect(fan[i].port_a, airSou.ports[i])
      annotation (Line(points={{50,-70},{60,-70}}, color={0,127,255}));
    connect(hex[i].port_b2, airSin.ports[i])
      annotation (Line(points={{-40,-12},{-50,-12},{-50,-70},{-70,-70}}, color={0,127,255}));
    connect(port_a, val[i].port_a)
      annotation (Line(points={{-100,0},{-70,0}}, color={0,127,255}));
  connect(port_b, boi[i].port_b1)
      annotation (Line(points={{100,0},{10,0}}, color={0,127,255}));
  end for;

  connect(boi.heatPort, heatPort)
    annotation (Line(points={{0,5},{0,100}},color={191,0,0}));
  connect(val.port_b, hex.port_a1)
    annotation (Line(points={{-50,0},{-40,0}},color={0,127,255}));
  connect(hex.port_b1, boi.port_a1)
    annotation (Line(points={{-20,0},{-10,0}},color={0,127,255}));
  connect(fan.port_b, boi.port_a2)
    annotation (Line(points={{30,-70},{20,-70},{20,-12},{10,-12}}, color={0,127,255}));
  connect(boi.port_b2, hex.port_a2)
    annotation (Line(points={{-10,-12},{-20,-12}}, color={0,127,255}));
  connect(val.y, yVal)
    annotation (Line(points={{-60,12},{-60,40},{-120,40}}, color={0,0,127}));
  connect(fan.y, yFan)
    annotation (Line(points={{40,-58},{40,80},{-120,80}}, color={0,0,127}));
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
