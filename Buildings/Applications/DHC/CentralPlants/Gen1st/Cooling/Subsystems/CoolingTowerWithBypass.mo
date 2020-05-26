within Buildings.Applications.DHC.CentralPlants.Gen1st.Cooling.Subsystems;
model CoolingTowerWithBypass "Cooling tower system with bypass valve"

  replaceable package Medium=Buildings.Media.Water
    "Condenser water medium";

  parameter Integer num(min=1)=2 "Number of cooling towers";

  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Equations"));

  parameter Modelica.SIunits.MassFlowRate m_flow_nominal
    "Total nominal mass flow rate of condenser water"
    annotation (Dialog(group="Nominal condition"));

  parameter Modelica.SIunits.Pressure dp_nominal
    "Nominal pressure difference of the tower"
    annotation (Dialog(group="Nominal condition"));

  parameter Real ratWatAir_nominal(min=0, unit="1")=0.625
    "Design water-to-air ratio"
    annotation (Dialog(group="Nominal condition"));

  parameter Modelica.SIunits.Temperature TAirInWB_nominal
    "Nominal outdoor (air inlet) wetbulb temperature"
    annotation (Dialog(group="Heat transfer"));

  parameter Modelica.SIunits.Temperature TWatIn_nominal
    "Nominal water inlet temperature"
    annotation (Dialog(group="Heat transfer"));

  parameter Modelica.SIunits.TemperatureDifference dT_nominal
    "Temperature difference between inlet and outlet of the tower"
     annotation (Dialog(group="Heat transfer"));

  parameter Modelica.SIunits.Power PFan_nominal
    "Fan power"
    annotation (Dialog(group="Fan"));

  parameter Modelica.SIunits.TemperatureDifference dTApp=3
    "Approach temperature"
    annotation (Dialog(group="Control Settings"));

  parameter Modelica.SIunits.Temperature TMin
    "Minimum allowed water temperature entering chiller"
    annotation (Dialog(group="Control Settings"));

  parameter Real k
    "Gain of the tower PID controller"
    annotation (Dialog(group="Control Settings"));

  parameter Real Ti
    "Integrator time constant of the tower PID controller"
    annotation (Dialog(group="Control Settings"));

  parameter Real Td
    "Derivative time constant of the tower PID controller"
    annotation (Dialog(group="Control Settings"));

  Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium=Medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));

  Modelica.Fluid.Interfaces.FluidPort_b port_b(redeclare package Medium=Medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));

  Modelica.Blocks.Interfaces.RealInput on[num](
    min=0, max=1, unit="1") "On signal for cooling towers"
    annotation (Placement(transformation(extent={{-140,20},{-100,60}})));

  Modelica.Blocks.Interfaces.RealInput TWetBul(
    final unit="K",
    displayUnit="degC")
    "Entering air wetbulb temperature"
    annotation (Placement(transformation(extent={{-140,-60},{-100,-20}})));

  Modelica.Blocks.Interfaces.RealOutput PFan[num](
    final quantity="Power",
    final unit="W")
    "Electric power consumed by fan"
    annotation (Placement(transformation(extent={{100,50},{120,70}})));

  Modelica.Blocks.Interfaces.RealOutput TLvg[num](
    final unit="K",
    displayUnit="degC")
    "Leaving water temperature"
    annotation (Placement(transformation(extent={{100,20},{120,40}})));

  Buildings.Applications.DHC.CentralPlants.Gen1st.Cooling.Subsystems.CoolingTowerParellel cooTowSys(
    redeclare package Medium = Medium,
    num=num,
    m_flow_nominal=m_flow_nominal/num,
    dp_nominal=dp_nominal,
    ratWatAir_nominal=ratWatAir_nominal,
    TAirInWB_nominal=TAirInWB_nominal,
    TWatIn_nominal=TWatIn_nominal,
    dT_nominal=dT_nominal,
    PFan_nominal=PFan_nominal,
    energyDynamics=energyDynamics) "Cooling tower system"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));

  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valByp(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=dp_nominal) "Condenser water bypass valve"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={0,-40})));

  Buildings.Fluid.Sensors.TemperatureTwoPort senTCWSup(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    T_start=Medium.T_default)
    annotation (Placement(transformation(extent={{60,10},{80,-10}})));

  Modelica.Blocks.Sources.RealExpression TSetCWSup(y=TWetBul + dTApp)
    "Condenser water supply temperature setpoint"
    annotation (Placement(transformation(extent={{-60,50},{-40,70}})));

  Modelica.Blocks.Sources.Constant TSetByPas(k=TMin)
    "Bypass loop temperature setpoint"
    annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));

  Buildings.Controls.Continuous.LimPID bypValCon(
    controllerType=Modelica.Blocks.Types.SimpleController.PID,
    k=1,
    Ti=60) "Bypass valve controller"
    annotation (Placement(transformation(extent={{-60,-80},{-40,-60}})));

  Buildings.Controls.Continuous.LimPID cooTowSpeCon(
    final reverseAction=true,
    controllerType=Modelica.Blocks.Types.SimpleController.PID,
    k=k,
    Ti=Ti,
    Td=Td,
    reset=Buildings.Types.Reset.Disabled) "Cooling tower fan speed controller"
    annotation (Placement(transformation(extent={{-10,50},{10,70}})));

equation
  connect(cooTowSys.TWetBul, TWetBul) annotation (Line(points={{-12,-6},{-40,-6},
          {-40,-40},{-120,-40}}, color={0,0,127}));
  connect(on, cooTowSys.on) annotation (Line(points={{-120,40},{-40,40},{-40,6},
          {-12,6}},   color={0,0,127}));
  connect(port_a, cooTowSys.port_a) annotation (Line(points={{-100,0},{-10,0}}, color={0,127,255}));
  connect(cooTowSys.port_b, senTCWSup.port_a) annotation (Line(points={{10,0},{60,0}}, color={0,127,255}));
  connect(senTCWSup.port_b, port_b) annotation (Line(points={{80,0},{100,0}}, color={0,127,255}));
  connect(TSetByPas.y, bypValCon.u_s) annotation (Line(points={{-79,-70},{-62,-70}}, color={0,0,127}));
  connect(senTCWSup.T, bypValCon.u_m) annotation (Line(points={{70,-11},{70,-90},
          {-50,-90},{-50,-82}},
                            color={0,0,127}));
  connect(valByp.port_a, cooTowSys.port_a) annotation (Line(points={{-10,-40},{-30,
          -40},{-30,0},{-10,0}}, color={0,127,255}));
  connect(valByp.port_b, senTCWSup.port_a) annotation (Line(points={{10,-40},{30,-40},{30,0},{60,0}}, color={0,127,255}));
  connect(TSetCWSup.y, cooTowSpeCon.u_s) annotation (Line(points={{-39,60},{-12,60}}, color={0,0,127}));
  connect(senTCWSup.T, cooTowSpeCon.u_m) annotation (Line(points={{70,-11},{70,
          -20},{50,-20},{50,40},{0,40},{0,48}}, color={0,0,127}));
  connect(cooTowSpeCon.y, cooTowSys.speFan) annotation (Line(points={{11,60},{20,
          60},{20,20},{-20,20},{-20,2},{-12,2}}, color={0,0,127}));
  connect(cooTowSys.PFan, PFan) annotation (Line(points={{11,6},{40,6},{40,60},{
          110,60}}, color={0,0,127}));
  connect(cooTowSys.TLvg, TLvg) annotation (Line(points={{11,3},{44,3},{44,30},{
          110,30}}, color={0,0,127}));
  connect(bypValCon.y, valByp.y) annotation (Line(points={{-39,-70},{-20,-70},{-20,
          -20},{0,-20},{0,-28}}, color={0,0,127}));

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}})),           Icon(coordinateSystem(
          preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
        Polygon(
          points={{0,-80},{-10,-72},{-10,-88},{0,-80}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{0,-80},{10,-72},{10,-88},{0,-80}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-149,-114},{151,-154}},
          lineColor={0,0,255},
          textString="%name"),
        Rectangle(
          extent={{-30,94},{30,20}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-22,88},{0,80}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{0,88},{22,80}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{16,70},{22,58}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{0,70},{6,58}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{0,70},{-6,58}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{16,70},{10,58}},
          color={255,0,0},
          thickness=0.5),
        Rectangle(
          extent={{-30,8},{30,-66}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-22,2},{0,-6}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{0,2},{22,-6}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-16,-16},{-22,-28}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{-16,-16},{-10,-28}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{0,-16},{-6,-28}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{0,-16},{6,-28}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{16,-16},{10,-28}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{16,-16},{22,-28}},
          color={255,0,0},
          thickness=0.5),
        Rectangle(
          extent={{30,24},{60,20}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{30,-62},{60,-66}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{62,2},{92,-2}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{58,-80},{62,24}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-90,2},{-60,-2}},
          lineColor={238,46,47},
          pattern=LinePattern.None,
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-64,-82},{-60,74}},
          lineColor={238,46,47},
          pattern=LinePattern.None,
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,-12},{16,-16}},
          lineColor={238,46,47},
          pattern=LinePattern.None,
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,74},{16,70}},
          lineColor={238,46,47},
          pattern=LinePattern.None,
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-16,70},{-22,58}},
          color={255,0,0},
          thickness=0.5),
        Line(
          points={{-16,70},{-10,58}},
          color={255,0,0},
          thickness=0.5),
        Rectangle(
          extent={{-60,-78},{-10,-82}},
          lineColor={238,46,47},
          pattern=LinePattern.None,
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,-78},{62,-82}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid)}),
    Documentation(revisions="<html>
<ul>
<li>
March 30, 2014 by Sen Huang:<br/>
First implementation.
</li>
</ul>
</html>"));
end CoolingTowerWithBypass;
